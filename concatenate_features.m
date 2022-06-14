clear all
for mybid=1:15
load("PaperFeaturesAcc_B_"+string(mybid)+".mat")
FA=Fnet;
load("PaperFeaturesAcc_B_"+string(mybid)+".mat")
FV = Fnet;
Fnet = [FA,FV];
save("PaperFeaturesFinal_B_"+string(mybid)+".mat",'Fnet')

clear Fnet FA FV
end