% This Code finds the HI based on the paper: 
% Guo, Liang, et al. "A recurrent neural network based health indicator for
% remaining useful life prediction of bearings." Neurocomputing 240 (2017):
% 98-109.

clear all
FPT=[79,55,60,106,26,456,50,316,32,123,2404,2450,343,1420,8]; % first prediction times
Nbearing = 15;
addpath('../Bearing_Features_Extract/')

%evaluate the metrics on all the individual features
for bid=1:Nbearing % bearing number
    load("GuoPaperFeaturesAcc_B_"+string(bid)+".mat");
    Fmax_all(bid,:) = max(Fnet);
    Fmin_all(bid,:) = min(Fnet);
    [mypear_corr(bid,:), mysp_corr(bid,:), old_mon(bid,:), new_mon(bid,:), myrob(bid,:)]=get_metrics(Fnet, FPT(bid));

end

%create test set for the random CV
rng(123)
all_test_combs = nchoosek(1:Nbearing,3);
rand_arr = randperm(length(all_test_combs));
TESTB = all_test_combs(rand_arr,:);
ncv = 100;  % number of random validations. 

for cv = 1:ncv
    testb =  TESTB(cv,:);
    trainb = setdiff(1:Nbearing,testb);

    %get feature max and min based on training dataset
    Fmax = max(Fmax_all(trainb,:));
    Fmin = min(Fmin_all(trainb,:));
    avg_pcorr = mean(mypear_corr(trainb,:));
    avg_oldmon = mean(old_mon(trainb,:));
    cri = (avg_pcorr+avg_oldmon)/2;
    select_features = cri > 0.5;

    if sum(select_features)==0      % If not feature is selected
        select_features = cri > 0.4;
        if sum(select_features)==0
            select_features = cri > 0.3;
        end
    end

    for bid = 1:15
        load("GuoPaperFeaturesAcc_B_"+string(bid)+".mat");
        Fnorm = (Fnet(:,select_features)-Fmin(select_features))./(Fmax(select_features)-Fmin(select_features));
        ALLHI{bid} = mean(Fnorm,2);
        [mypr_corrf(bid), mysp_corrf(bid), old_monf(bid), new_monf(bid), myrbf(bid)]=get_metrics(ALLHI{bid}, FPT(bid));
    end
    HI_save{cv} = ALLHI(testb);

    %get cri - score by averaging pearson and old monotonicity def among the test bearings
    trainb_HI_cri(cv) = mean((mypr_corrf(trainb)+old_monf(trainb))/2);
    testb_HI_cri(cv) = mean((mypr_corrf(testb)+old_monf(testb))/2);
    
    RES(cv,1)=cri(1); % max amp
    RES(cv,2)=cri(2); % RMS
    RES(cv,3)=trainb_HI_cri(cv); % train cri
    RES(cv,4)=testb_HI_cri(cv);  % test cri

    % More comprehensive approach - evaluate the probability that a test
    % bearing has good metrics.
    %pearson corr
    [pr_corr_Pr_test(cv), pr_cutoff_vec(cv,:), pr_metric_vec(cv,:)]=get_metaprobability(mypr_corrf(testb), [0.8, 1.0]);
    %spearman corr
    [sp_corr_Pr_test(cv), sp_cutoff_vec(cv,:), sp_metric_vec(cv,:)]=get_metaprobability(mysp_corrf(testb), [0.8, 1.0]);
    %old_mon
    [old_mon_Pr_test(cv), old_mon_cutoff_vec(cv,:), old_mon_metric_vec(cv,:)]=get_metaprobability(old_monf(testb), [0.5, 1.0]);
    %new_mon
    [new_mon_Pr_test(cv), new_mon_cutoff_vec(cv,:), new_mon_metric_vec(cv,:)]=get_metaprobability(new_monf(testb), [0.5, 1.0]);
    %robustness
    [rb_corr_Pr_test(cv), rb_cutoff_vec(cv,:), rb_metric_vec(cv,:)]=get_metaprobability(myrbf(testb), [0.85, 1.0]);

    %SNR of test HI
    mysnr_test(cv)  = get_snr(ALLHI(testb), FPT(testb));
   
end

save('optimization_Guo1.mat')

%save data for comparison later
% FinalResult{1,1}=pr_corr_Pr_test;   FinalResult{1,2}=pr_cutoff_vec;      FinalResult{1,3}=pr_metric_vec; 
% FinalResult{2,1}=sp_corr_Pr_test; FinalResult{2,2}=sp_cutoff_vec;      FinalResult{2,3}=sp_metric_vec;
% FinalResult{3,1}=old_mon_Pr_test;   FinalResult{3,2}=old_mon_cutoff_vec; FinalResult{3,3}=old_mon_metric_vec;
% FinalResult{4,1}=new_mon_Pr_test;   FinalResult{4,2}=new_mon_cutoff_vec; FinalResult{4,3}=new_mon_metric_vec;
% FinalResult{5,1}=rb_corr_Pr_test;   FinalResult{5,2}=rb_cutoff_vec;      FinalResult{5,3}=rb_metric_vec;

%% Postprocess plots
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

