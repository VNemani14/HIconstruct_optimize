function myRSF = get_RSFeature(myf)
% gives RS features at t
[t, k] = size(myf);
f_0_tilda = mean(myf(1,:));
f_t_tilda = mean(myf(end,:));

N=0;
D1 = 0; D2 =0;

for i = 1:k
    N = N+(myf(1,i)-f_0_tilda)*(myf(t,i)-f_t_tilda);
    D1 = D1+(myf(1,i)-f_0_tilda).^2;
    D2 = D2+(myf(t,i)-f_t_tilda).^2;
end

myRSF = abs(N)/sqrt(D1*D2);

end