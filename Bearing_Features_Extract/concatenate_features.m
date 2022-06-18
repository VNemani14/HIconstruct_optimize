% Combine features from acceleration domain and velocity domain
% The final feature foe each bearing will be subject to feature fusion

clear all
for mybid=1:15
load("FeaturesAcc_B_"+string(mybid)+".mat")
FA=Fnet;
load("FeaturesVel_B_"+string(mybid)+".mat")
FV = Fnet;
Fnet = [FA,FV];
save("FeaturesFinal_B_"+string(mybid)+".mat",'Fnet')

clear Fnet FA FV
end