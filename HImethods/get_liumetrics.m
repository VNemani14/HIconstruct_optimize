% Postprocessing HI to get 
% sigmalEOL: end of life variance
% mon_violation_count: count of violations in monotonicity
% based on % Liu, Kaibo, and Shuai Huang. "Integration of data fusion
% methodology and degradation modeling process to improve prognostics."
% IEEE Transactions on Automation Science and Engineering 13.1 (2014):
% 344-354.

function [sigmaEOL, mon_violation_count] = get_liumetrics(HI, FPT, Fmax, Fmin)
[~, Nbearing] = size(HI);

mon_violation_count = 0;
for i=1:Nbearing
    myHI = HI{i}(FPT(i):end);
    myHI = (myHI-Fmin)/(Fmax-Fmin);
    endHI(i) =  myHI(end);
    for j = 1:length(myHI)-1
        mon_violation_count = mon_violation_count + max(myHI(j)-myHI(j+1),0);
    end    
end
endHI_avg = mean(endHI);

sigmaEOL=0;
for i=1:Nbearing
    sigmaEOL = sigmaEOL + (endHI(i)-endHI_avg)^2/(Nbearing-1);
end

end