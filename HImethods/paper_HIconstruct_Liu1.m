% Paper:
% Liu, Kaibo, and Shuai Huang. "Integration of data fusion methodology and
% degradation modeling process to improve prognostics." IEEE Transactions
% on Automation Science and Engineering 13.1 (2014): 344-354.

clear all
FPT=[79,55,60,106,26,456,50,316,32,123,2404,2450,343,1420,8]; %these are the first prediction times
Nbearing = 15;
addpath('../Bearing_Features_Extract/')

for bid=1:Nbearing % bearing number
    load("FeaturesFinal_B_"+string(bid)+".mat");
    [~,nfeatures] = size(Fnet);
    Fmax_all(bid,:) = max(Fnet);
    Fmin_all(bid,:) = min(Fnet);
    for nf = 1:nfeatures
        AllFeatures{nf,bid}=Fnet(:,nf);
    end
end

%create test set for the random CV
rng(123)
all_test_combs = nchoosek(1:Nbearing,3);
rand_arr = randperm(length(all_test_combs));
TESTB = all_test_combs(rand_arr,:);
ncv = 100;

parfor cv = 1:ncv
    nlhs = 2000; %number of LHS samples for optimization - we will double it for linearly and exp spaced LHS samples
    testb =  TESTB(cv,:);
    trainb = setdiff(1:Nbearing,testb);

    %get feature max and min based on training dataset
    Fmax = max(Fmax_all(trainb,:));
    Fmin = min(Fmin_all(trainb,:));

    %feature selection based on training 
    %pre feature selection with low violation of monotonicity and sigmaEOL
    sigmaEOL=zeros(nfeatures,1); mon_violation_count=zeros(nfeatures,1);
    for nf = 1:nfeatures
        [sigmaEOL(nf), mon_violation_count(nf)]  = get_liumetrics(AllFeatures(nf,trainb), FPT(trainb), Fmax(nf), Fmin(nf));
    end

    EOL_index = sigmaEOL < quantile(sigmaEOL, 0.6); % top sigmaEOL based features
    mon_violation_count_index = mon_violation_count < quantile(mon_violation_count, 0.6); % top mon violations based features

    select_features = (EOL_index & mon_violation_count_index);
    nselect_features = sum(select_features);

    %get feature max and min based on training dataset - for select
    %features
    Fmax = max(Fmax_all(trainb,select_features));
    Fmin = min(Fmin_all(trainb,select_features));
    
    %LHS wt samples
    lb = zeros(nselect_features, 1);
    ub = lb+1;
    Wts1=lhsdesignbnd(nlhs,nselect_features,lb,ub,boolean(zeros(1,nselect_features))); %linearly spread samples
    Wts2=lhsdesignbnd(nlhs,nselect_features,lb+1e-8,ub,boolean(ones(1,nselect_features))); %exp spread samples
    Wts=[Wts1;Wts2];
    nlhs =2*nlhs; 

    ALLHI = cell(nlhs,Nbearing);
    pr_corrf=zeros(nlhs,Nbearing); sp_corrf=pr_corrf;  old_monf=pr_corrf; new_monf=pr_corrf; rbf=pr_corrf;
    sp_corr_Pr=zeros(nlhs,1); new_mon_Pr = sp_corr_Pr; mysnr=sp_corr_Pr;
    obj1 = zeros(nlhs,1); obj2 = zeros(nlhs,1);
    for mylhs = 1:nlhs
        for bid = 1:15
            File = load("FeaturesFinal_B_"+string(bid)+".mat");
            Fnet = File.Fnet;
            Fnorm = (Fnet(:,select_features)-Fmin)./(Fmax-Fmin);
            % weighted HI
            mywt = Wts(mylhs,:);
            mywt = mywt/sum(mywt);
            ALLHI{mylhs, bid} = sum(mywt.*Fnorm,2);
            [pr_corrf(mylhs, bid), sp_corrf(mylhs, bid), old_monf(mylhs, bid), new_monf(mylhs, bid), rbf(mylhs, bid)]=get_metrics(ALLHI{mylhs, bid}, FPT(bid));
        end
        
        % Get the probabilities for optimization metrics for each LHS sample
        %spearman corr
        [sp_corr_Pr(mylhs),~, ~]=get_metaprobability(sp_corrf(mylhs, trainb), [0.8, 1.0]);
        %new monotonicity
        [new_mon_Pr(mylhs), ~, ~]=get_metaprobability(new_monf(mylhs, trainb), [0.5, 1.0]);
        %SNR
        mysnr(mylhs)  = get_snr(ALLHI(mylhs, trainb), FPT(trainb));

        [obj1(mylhs), obj2(mylhs)]  = get_liumetrics(ALLHI(mylhs,trainb), FPT(trainb), 1, 0);
    end
    
    % find the first index between the two 
    for iter = 1:300
        obj1_index = obj1 < quantile(obj1, iter/300);
        obj2_index = obj2 < quantile(obj2, iter/300);
        if sum(obj1_index & obj2_index)>0
            lhs_max_ind = find((obj1_index & obj2_index)>0);
            lhs_max_ind = lhs_max_ind(1);
            break
        end
    end
%     HI_test = ALLHI(lhs_max_ind,testb);
%     save('HI_LIU1','HI_test');
    HI_save{cv} = ALLHI(lhs_max_ind,testb);
    %get cri - score by averaging pearson and old monotonicity among the test bearings
    trainb_HI_cri(cv) = mean((pr_corrf(lhs_max_ind,trainb)+old_monf(lhs_max_ind, trainb))/2);
    testb_HI_cri(cv) = mean((pr_corrf(lhs_max_ind,testb)+old_monf(lhs_max_ind, testb))/2);

    % More comprehensive approach - evaluate the probability that a test
    % bearing has good metrics.
    %pearson corr
    [pr_corr_Pr_test(cv), pr_cutoff_vec(cv,:), pr_metric_vec(cv,:)]=get_metaprobability(pr_corrf(lhs_max_ind,testb), [0.8, 1.0]);
    %spearman corr
    [sp_corr_Pr_test(cv), sp_cutoff_vec(cv,:), sp_metric_vec(cv,:)]=get_metaprobability(sp_corrf(lhs_max_ind,testb), [0.8, 1.0]);
    %old_mon
    [old_mon_Pr_test(cv), old_mon_cutoff_vec(cv,:), old_mon_metric_vec(cv,:)]=get_metaprobability(old_monf(lhs_max_ind,testb), [0.5, 1.0]);
    %new_mon
    [new_mon_Pr_test(cv), new_mon_cutoff_vec(cv,:), new_mon_metric_vec(cv,:)]=get_metaprobability(new_monf(lhs_max_ind,testb), [0.5, 1.0]);
    %robustness
    [rb_corr_Pr_test(cv), rb_cutoff_vec(cv,:), rb_metric_vec(cv,:)]=get_metaprobability(rbf(lhs_max_ind,testb), [0.85, 1.0]);

    %SNR of test HI
    mysnr_test(cv)  = get_snr(ALLHI(lhs_max_ind,testb), FPT(testb));
    cv
   
end
%% postprocess plots
% all_probs = [pr_corr_Pr_test', sp_corr_Pr_test', old_mon_Pr_test',new_mon_Pr_test',rb_corr_Pr_test',testb_HI_cri'];
% figure()
% names = {'Pearson>0.8','Spearman>0.8','Old_mon>0.5','New_mon>0.5','Robustness>0.85', 'Cri_score'};
% h = boxplot(all_probs,'Labels', names);
% xlabel('Metrics')
% ylabel('Probability')
% set(gca,'fontsize', 16)
% 
% figure()
% h_snr = boxplot(mysnr_test, 'Labels','SNR');
% xlabel('Metrics')
% ylabel('SNR')
% set(gca,'fontsize', 16)

%save data for comparison later
% FinalResult{1,1}=pr_corr_Pr_test;   FinalResult{1,2}=pr_cutoff_vec;      FinalResult{1,3}=pr_metric_vec; 
% FinalResult{2,1}=sp_corr_Pr_test;   FinalResult{2,2}=sp_cutoff_vec;      FinalResult{2,3}=sp_metric_vec;
% FinalResult{3,1}=old_mon_Pr_test;   FinalResult{3,2}=old_mon_cutoff_vec; FinalResult{3,3}=old_mon_metric_vec;
% FinalResult{4,1}=new_mon_Pr_test;   FinalResult{4,2}=new_mon_cutoff_vec; FinalResult{4,3}=new_mon_metric_vec;
% FinalResult{5,1}=rb_corr_Pr_test;   FinalResult{5,2}=rb_cutoff_vec;      FinalResult{5,3}=rb_metric_vec;

% save('optimization_LIU1_LHS.mat')

