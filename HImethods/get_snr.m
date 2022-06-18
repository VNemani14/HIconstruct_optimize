% get modified SNR proposed by 
% Paper:
% Liu, Kaibo, Abdallah Chehade, and Changyue Song. "Optimize the signal
% quality of the composite health index via data fusion for degradation
% modeling and prognostic analysis." IEEE Transactions on Automation
% Science and Engineering 14.3 (2015): 1504-1514.

% Input:
%   HI- Health Index set for multiple units
%   FPT- First Prediction Time set. 
% Output:
%   mysnr- modified SNR
function mysnr = get_snr(HI, FPT)
    [~, Nbearing] = size(HI);
    
    for i=1:Nbearing
        myHI = HI{i}(FPT(i):end);
        endHI(i) =  myHI(end);
    end
    endHI_avg = mean(endHI);
    
    R=0; v=0; sigma_sq=0;
    for i=1:Nbearing
        myHI = HI{i}(FPT(i):end);
        R=R+(myHI(end)-myHI(1))/Nbearing;
        v=v+(myHI(end)-endHI_avg)^2/(Nbearing-1);
        
        HI_smooth = movmean(myHI,[3,0]);
        er = myHI - HI_smooth;
        sigma_sq = sigma_sq + sum(er.^2)/Nbearing;
    
    end
    
    mysnr = R*R/(sigma_sq+v);

end