% get metrics for healthindex
%   Pearson correlation: mypear_corr
%   Spearman correlation: mysp_corr
%   Original monotonicity: old_mon
%   Modified monotonicity: new_mon
%   Robustness          : myrob

function [mypear_corr, mysp_corr, old_mon, new_mon, myrob] = get_metrics(myf_org, FPT)
    
    myf = myf_org(FPT:end,:);
    [ntime,nfeatures]=size(myf);
    a=(0:ntime-1)';
    
    %calculate correlation - pearson and spearman
    for i=1:nfeatures
       C=corrcoef(myf(:,i),a); %pearson correlation
       mypear_corr(i)=abs(C(2,1));
       C=corr(myf(:,i),a,'Type','Spearman'); %spearman
       mysp_corr(i)=abs(C);
    end
    
    %calculate monotonicity (original definition)
    for i=1:nfeatures
       M=diff(myf(:,i));
       old_mon(i)=abs(sum(M>=0)-sum(M<0))/(ntime-1);
    end
    
    %calculate robustness
    for i=1:nfeatures
       fsmooth=movmean(myf(:,i),[4,0]); %moving average smoothing
       myrob(i)=mean(exp(-abs((myf(:,i)-fsmooth)./myf(:,i))));
    end
    
    %modified monotonicity def
    for i =1:nfeatures
        f_before_fpt=myf_org(FPT-7:FPT-1, i); %time series before FPT
        mysigma=std(f_before_fpt); %calculate sigma from feature before FPT
        new_mon(i)=get_mod_monotonicity(myf(:,i), mysigma); %new definition of monotonicity
    end

    % New SNR defition based on: Liu, Kaibo - DOI: 10.1109/TASE.2015.2446752
    % Optimize the Signal Quality of the Composite Health Index Via Data Fusion for Degradation Modeling and Prognostic Analysis

end
