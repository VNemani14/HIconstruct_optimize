% Paper:
% Integration of Data Fusion Methodology and Degradation Modeling Process to Improve Prognostics
clear all
FPT=[79,55,60,106,26,456,50,316,32,123,2404,2450,343,1420,8]; %these are the first prediction times
Nbearing = 15;
for bid=1:Nbearing % bearing number
    load("PaperFeaturesFinal_B_"+string(bid)+".mat");
    [~,nfeatures] = size(Fnet);
    Fmax_all(bid,:) = max(Fnet);
    Fmin_all(bid,:) = min(Fnet);
    for nf = 1:nfeatures
        AllFeatures{nf,bid}=Fnet(:,nf);
    end
    [mypear_corr(bid,:), mysp_corr(bid,:), old_mon(bid,:), new_mon(bid,:), myrob(bid,:)]=get_metrics(Fnet, FPT(bid));
end

%create test set for the random CV
rng(123)
all_test_combs = nchoosek(1:Nbearing,3);
rand_arr = randperm(length(all_test_combs));
TESTB = all_test_combs(rand_arr,:);
ncv = 100;

parfor cv = 1:ncv
    nlhs = 1000; %number of LHS samples for optimization
    testb =  TESTB(cv,:);
    trainb = setdiff(1:Nbearing,testb);

    %get feature max and min based on training dataset
    Fmax = max(Fmax_all(trainb,:));
    Fmin = min(Fmin_all(trainb,:));

    %feature selection based on training 
    avg_pcorr = mean(mypear_corr(trainb,:));
    avg_oldmon = mean(old_mon(trainb,:));
    avg_rob = mean(myrob(trainb,:));
    cri2 = (avg_pcorr+avg_oldmon+avg_rob)/3;
    select_features = cri2 > 0.3;
    nselect_features = sum(select_features);


    %get feature max and min based on training dataset - for select
    %features
    Fmax = max(Fmax_all(trainb,select_features));
    Fmin = min(Fmin_all(trainb,select_features));
    
    lb = zeros(nselect_features, 1);
    ub = lb+1;
    Wts1=lhsdesignbnd(nlhs,nselect_features,lb,ub,boolean(zeros(1,nselect_features))); %linearly spread samples
    Wts2=lhsdesignbnd(nlhs,nselect_features,lb+1e-8,ub,boolean(ones(1,nselect_features))); %exp spread samples
    Wts=[Wts1;Wts2];   
    nlhs = 2*nlhs;
    pr_corrf=zeros(nlhs,Nbearing); sp_corrf=pr_corrf;  old_monf=pr_corrf; new_monf=pr_corrf; robf=pr_corrf;
    sp_corr_Pr=zeros(nlhs,1); new_mon_Pr = sp_corr_Pr; mysnr=sp_corr_Pr;
    obj1 = zeros(nlhs,1);

    for mylhs = 1:nlhs
        for bid = 1:15
            File = load("PaperFeaturesFinal_B_"+string(bid)+".mat");
            Fnet = File.Fnet;
            Fnorm = (Fnet(:,select_features)-Fmin)./(Fmax-Fmin);
            % weighted HI
            mywt = Wts(mylhs,:);
            mywt = mywt/sum(mywt);
            ALLHI{mylhs, bid} = sum(mywt.*Fnorm,2);
            [pr_corrf(mylhs, bid), sp_corrf(mylhs, bid), old_monf(mylhs, bid), new_monf(mylhs, bid), robf(mylhs, bid)]=get_metrics(ALLHI{mylhs, bid}, FPT(bid));
        end
        obj1(mylhs) = mean(1/3*(pr_corrf(mylhs, trainb)+old_monf(mylhs, trainb)+robf(mylhs, trainb)));
    end
    [max_val,lhs_max_ind] = max(obj1);
    w_best = Wts(lhs_max_ind,:);
    
%     HI_test = ALLHI(lhs_max_ind,testb);
%     save('HI_CHEN','HI_test');    

    ALLHI = cell(Nbearing);
    pr_corrf=zeros(Nbearing); sp_corrf=pr_corrf;  old_monf=pr_corrf; new_monf=pr_corrf; robf=pr_corrf;
    for bid = 1:15
        File = load("PaperFeaturesFinal_B_"+string(bid)+".mat");
        Fnet = File.Fnet;
        Fnorm = (Fnet(:,select_features)-Fmin)./(Fmax-Fmin);
        % weighted HI
        mywt = w_best;
        mywt = mywt/sum(mywt);
        ALLHI{bid} = sum(mywt.*Fnorm,2);
        [pr_corrf(bid), sp_corrf(bid), old_monf(bid), new_monf(bid), robf(bid)]=get_metrics(ALLHI{bid}, FPT(bid));
    end

    HI_save{cv} = ALLHI(testb);

    %get cri - score by averaging pearson and old monotonicity among the test bearings
    trainb_HI_cri(cv) = mean((pr_corrf(trainb)+old_monf(trainb))/2);
    testb_HI_cri(cv) = mean((pr_corrf(testb)+old_monf(testb))/2);

    % More comprehensive approach - evaluate the probability that a test
    % bearing has good metrics.
    %pearson corr
    [pr_corr_Pr_test(cv), pr_cutoff_vec(cv,:), pr_metric_vec(cv,:)]=get_probability(pr_corrf(testb), [0.8, 1.0]);
    %spearman corr
    [sp_corr_Pr_test(cv), sp_cutoff_vec(cv,:), sp_metric_vec(cv,:)]=get_probability(sp_corrf(testb), [0.8, 1.0]);
    %old_mon
    [old_mon_Pr_test(cv), old_mon_cutoff_vec(cv,:), old_mon_metric_vec(cv,:)]=get_probability(old_monf(testb), [0.5, 1.0]);
    %new_mon
    [new_mon_Pr_test(cv), new_mon_cutoff_vec(cv,:), new_mon_metric_vec(cv,:)]=get_probability(new_monf(testb), [0.5, 1.0]);
    %robustness
    [rb_corr_Pr_test(cv), rb_cutoff_vec(cv,:), rb_metric_vec(cv,:)]=get_probability(robf(testb), [0.85, 1.0]);

    %SNR of test HI
    mysnr_test(cv)  = get_snr(ALLHI(testb),FPT(testb));
    cv
   
end
%save data for comparison later
FinalResult{1,1}=pr_corr_Pr_test;   FinalResult{1,2}=pr_cutoff_vec;      FinalResult{1,3}=pr_metric_vec; 
FinalResult{2,1}=sp_corr_Pr_test;   FinalResult{2,2}=sp_cutoff_vec;      FinalResult{2,3}=sp_metric_vec;
FinalResult{3,1}=old_mon_Pr_test;   FinalResult{3,2}=old_mon_cutoff_vec; FinalResult{3,3}=old_mon_metric_vec;
FinalResult{4,1}=new_mon_Pr_test;   FinalResult{4,2}=new_mon_cutoff_vec; FinalResult{4,3}=new_mon_metric_vec;
FinalResult{5,1}=rb_corr_Pr_test;   FinalResult{5,2}=rb_cutoff_vec;      FinalResult{5,3}=rb_metric_vec;
save('optimization_CHEN_LHS_new.mat')

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