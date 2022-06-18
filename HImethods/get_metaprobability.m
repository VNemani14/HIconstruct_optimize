% Calculates the meta probability
% Input: 
%   mymetric - set of metrics
%   cutoff - lower and upper cutoffs
% Output:
%   Pr - meta probability
%   Cutoff_vec - cutoff vector
%   metric_vec - curve for meta probability

function [Pr,cutoff_vec,metric_vec] = get_metaprobability(mymetric, cutoff)
    Nbearings=length(mymetric);
    cutoff_vec = linspace(cutoff(1), cutoff(2), 100);
    metric_vec = zeros(length(cutoff_vec),1);
    for j=1:length(cutoff_vec)
        metric_vec(j)=sum(mymetric>cutoff_vec(j));
    end
    Pr = trapz(cutoff_vec,metric_vec)/(cutoff(2)-cutoff(1))/Nbearings;
end

