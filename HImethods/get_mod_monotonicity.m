% proposed modified monotonicity

function [mymon]=get_mod_monotonicity(myf, mysigma)
% this function gives the modified monotonicity while accounting for noise
% in measurement
% myf is the feature time series
% mysigma is the noise level in the time series measurement
if (myf(end)+myf(end-1))/2>= (myf(1)+myf(2))/2  %generally increasing HI
    myf = myf;
else
    myf = max(myf)-myf; %just inverting to make it monotonically increasing
end

epsilon = 1e-2;
dF=diff(myf);
myalpha=atanh(1-epsilon)/(epsilon+mysigma);
allc=tanh((dF+mysigma)*myalpha);
mymon=sum(allc)/sum(abs(allc));

end

