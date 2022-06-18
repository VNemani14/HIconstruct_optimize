% This code is written by Venkat Nemani from ISU
% The code extracts the features from the raw acceleration vibration signal
% in both time and frequency domain

clear all

%Bearing Dimensions for XJTU bearing dataset
d=7.92; %Ball diameter in mm
D=34.55;%Mean bearing diameter
nballs=8;%Number of ball bearings

%operating/ measurement conditions
sf=25.6e3; %sampling frequency
shaftfr=[35*ones(1,5),37.5*ones(1,5),40*ones(1,5)]; %shaft freq in Hz for the 15 bearings

for mybid=1:15
    load("../Raw_Data/bearing"+ num2str(mybid) +'.mat')
    [~,~,ntime]=size(rawnet); %rawnet contains ndatapoints*axis*time
    
    % determine the fault freq
    BPFO=nballs*shaftfr(mybid)/2*(1-d/D);
    BPFI=nballs*shaftfr(mybid)/2*(1+d/D);
    FTF=shaftfr(mybid)/2*(1-d/D);
    BSF=D/2/d*(1-d*d/D/D)*shaftfr(mybid);

    tt=linspace(0,1.28,32768);
    for mytime=1:ntime
            raw=rawnet(:,:,mytime);
            tsize=size(raw);
            ha=raw(:,1); %horizontal axis time-series
            va=raw(:,2); %vertical axis
            vib=ha; % replace with va for other axis
            %time domain features
            FTh(mytime,1)=max(abs(vib));  % max amplitude
            FTh(mytime,2)=rms(vib);       % rms value
            FTh(mytime,3)=kurtosis(vib);  % kurtosis
            FTh(mytime,4)=rms(vib)/mean(abs(vib)); %shape factor
            FTh(mytime,5)=skewness(vib);  % skewness
            FTh(mytime,6)=max(abs(vib))/mean(abs(vib)); %Impulse factor
            FTh(mytime,7)=max(abs(vib))/rms(vib); %crest factor

            [N,edges]= histcounts(abs(vib),'Normalization','probability');
            edges=edges(1:end-1);
            FTh(mytime,8)=sum(N(edges>1).*edges(edges>1));  
            FTh(mytime,9)=sum(N(edges>5).*edges(edges>5));  
            % convert to Frequency domain
            [m,~]=size(vib);
            myf = sf*(0:floor(m/2))/m; % frequency
            df=sf/m;                   % frequency resolution
            Y=fft(abs(vib));
            P2=abs(Y/tsize(1));
            P1=P2(1:tsize(1)/2+1);      % double sided spectrum
            P1(2:end-1)=2*P1(2:end-1);  % single sided spectrum
            
            %BPFO 1x, 2x and 3x si = start index, ei=end index
            % We look at a 5% error around the fault frequency. Then
            % calculate energy in that frequency range using Parseval's
            % theorem
            si=floor(0.95*BPFO/df);ei=floor(1.05*BPFO/df);
            FF(mytime,1)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            si=floor(2*0.95*BPFO/df);ei=floor(2*1.05*BPFO/df);
            FF(mytime,2)=sqrt(sum(P1(si:ei).*P1(si:ei))/2); 
            si=floor(3*0.95*BPFO/df);ei=floor(3*1.05*BPFO/df);
            FF(mytime,3)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);      
            FF(mytime,4)=sqrt(FF(mytime,1)^2+FF(mytime,2)^2+FF(mytime,3)^2);%Energy within first 3 bands
            
            %BPFI 1x, 2x and 3x
            si=floor(0.95*BPFI/df);ei=floor(1.05*BPFI/df);
            FF(mytime,5)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);     
            si=floor(2*0.95*BPFI/df);ei=floor(2*1.05*BPFI/df);
            FF(mytime,6)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);    
            si=floor(3*0.95*BPFI/df);ei=floor(3*1.05*BPFI/df);
            FF(mytime,7)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            FF(mytime,8)=sqrt(FF(mytime,5)^2+FF(mytime,6)^2+FF(mytime,7)^2);%Energy within first 3 bands
            
            %BSF 1x, 2x and 3x
            si=floor(0.95*BSF/df);ei=floor(1.05*BSF/df);
            FF(mytime,9)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            si=floor(2*0.95*BSF/df);ei=floor(2*1.05*BSF/df);
            FF(mytime,10)=sqrt(sum(P1(si:ei).*P1(si:ei))/2); 
            si=floor(3*0.95*BSF/df);ei=floor(3*1.05*BSF/df);
            FF(mytime,11)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            FF(mytime,12)=sqrt(FF(mytime,9)^2+FF(mytime,10)^2+FF(mytime,11)^2);%Energy within first 3 bands

            %overall energy
            si=floor(shaftfr(mybid)*0.8/df);
            FF(mytime,13)=sqrt(sum(P1(si:end).*P1(si:end))/2);
            %bearing related energy
            si=floor(shaftfr(mybid)*2.1/df);
            FF(mytime,14)=sqrt(sum(P1(si:end).*P1(si:end))/2);
            %low freq energy
            si=floor(shaftfr(mybid)*0.5/df);ei=floor(400/df);
            FF(mytime,15)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            si=floor(shaftfr(mybid)*2.1/df);ei=floor(400/df);
            FF(mytime,16)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            FFh=FF;

            %wavelet energies
            P1(1)=0; % removing the DC component
            for nwave = 1:8
                si=floor((nwave-1)*sf/8/df/2)+1;ei=floor((nwave)*sf/8/df/2);
                FFwh(mytime,nwave)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            end
            
            
            % do the same as above for vibration in different axis
            vib=va; % replace with va for other axis
            
            FTv(mytime,1)=max(abs(vib));  % max amplitude
            FTv(mytime,2)=rms(vib);       % rms value
            FTv(mytime,3)=kurtosis(vib);  % kurtosis
            FTv(mytime,4)=rms(vib)/mean(abs(vib)); %shape factor
            FTv(mytime,5)=skewness(vib);  % skewness
            FTv(mytime,6)=max(abs(vib))/mean(abs(vib)); %Impulse factor
            FTv(mytime,7)=max(abs(vib))/rms(vib); %crest factor

            [N,edges]= histcounts(abs(vib),'Normalization','probability');
            edges=edges(1:end-1);
            FTv(mytime,8)=sum(N(edges>1).*edges(edges>1));  % kurtosis
            FTv(mytime,9)=sum(N(edges>2).*edges(edges>2));  % kurtosis
            
            [m,~]=size(vib);
            myf = sf*(0:floor(m/2))/m; % frequency
            df=sf/m;                   % frequency resolution
            Y=fft(abs(vib));
            P2=abs(Y/tsize(1));
            P1=P2(1:tsize(1)/2+1);      % double sided spectrum
            P1(2:end-1)=2*P1(2:end-1);  % single sided spectrum
            
            %BPFO 1x, 2x and 3x
            si=floor(0.95*BPFO/df);ei=floor(1.05*BPFO/df);
            FF(mytime,1)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            si=floor(2*0.95*BPFO/df);ei=floor(2*1.05*BPFO/df);
            FF(mytime,2)=sqrt(sum(P1(si:ei).*P1(si:ei))/2); 
            si=floor(3*0.95*BPFO/df);ei=floor(3*1.05*BPFO/df);
            FF(mytime,3)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);      
            FF(mytime,4)=sqrt(FF(mytime,1)^2+FF(mytime,2)^2+FF(mytime,3)^2);%Energy within first 3 bands
            
            %BPFI 1x, 2x and 3x
            si=floor(0.95*BPFI/df);ei=floor(1.05*BPFI/df);
            FF(mytime,5)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);     
            si=floor(2*0.95*BPFI/df);ei=floor(2*1.05*BPFI/df);
            FF(mytime,6)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);    
            si=floor(3*0.95*BPFI/df);ei=floor(3*1.05*BPFI/df);
            FF(mytime,7)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            FF(mytime,8)=sqrt(FF(mytime,5)^2+FF(mytime,6)^2+FF(mytime,7)^2);%Energy within first 3 bands
            
            %BSF 1x, 2x and 3x
            si=floor(0.95*BSF/df);ei=floor(1.05*BSF/df);
            FF(mytime,9)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            si=floor(2*0.95*BSF/df);ei=floor(2*1.05*BSF/df);
            FF(mytime,10)=sqrt(sum(P1(si:ei).*P1(si:ei))/2); 
            si=floor(3*0.95*BSF/df);ei=floor(3*1.05*BSF/df);
            FF(mytime,11)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            FF(mytime,12)=sqrt(FF(mytime,9)^2+FF(mytime,10)^2+FF(mytime,11)^2);%Energy within first 3 bands

            %overall energy
            si=floor(shaftfr(mybid)*0.8/df);
            FF(mytime,13)=sqrt(sum(P1(si:end).*P1(si:end))/2);
            %bearing related energy
            si=floor(shaftfr(mybid)*2.1/df);
            FF(mytime,14)=sqrt(sum(P1(si:end).*P1(si:end))/2);
            %low freq energy
            si=floor(shaftfr(mybid)*0.5/df);ei=floor(400/df);
            FF(mytime,15)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            si=floor(shaftfr(mybid)*2.1/df);ei=floor(400/df);
            FF(mytime,16)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            FFv=FF;

            %wavelet energies
            P1(1)=0; % removing the DC component
            for nwave = 1:8
                si=floor((nwave-1)*sf/8/df/2)+1;ei=floor((nwave)*sf/8/df/2);
                FFwv(mytime,nwave)=sqrt(sum(P1(si:ei).*P1(si:ei))/2);
            end
            
           Fnet(mytime,:)=[FTh(mytime,:),FFh(mytime,:),FFwh(mytime,:),FTv(mytime,:),FFv(mytime,:),FFwv(mytime,:)]; 
    end
    mybid
    
    save("FeaturesAcc_B_"+string(mybid)+".mat",'Fnet','FTh','FFh','FTv','FFv') %This save file is input in other scripts. 
    clear P1 P2 Y FF myfft df Fnet FF FFv FTh FFh FTv FFv FFwv FFwh
end

