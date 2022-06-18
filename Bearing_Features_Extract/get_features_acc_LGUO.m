% This code is written by VPN from ISU
% The code extracts the features from the raw acceleration vibration signal
% in both time and frequency domain

clear all
%Bearing Dimensions
d=7.92; %Ball diameter in mm
D=34.55;%Mean bearing diameter
nballs=8;

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
            FTh(mytime,1)=max(vib);  % max vibration
            FTh(mytime,2)=rms(vib);       % rms value
            FTh(mytime,3)=kurtosis(vib);  % kurtosis
            FTh(mytime,4)=skewness(vib);  % skewness
            FTh(mytime,5)=abs(max(vib))+ abs(min(vib));  % peak to peak
            FTh(mytime,6)=var(vib);       % variance
            FTh(mytime,7)=entropy(vib);   %entropy
            FTh(mytime,8)=max(abs(vib))/rms(vib); %crest factor
            FTh(mytime,9)=rms(vib)/mean(abs(vib)); %shape factor
            FTh(mytime,10)=max(abs(vib))/mean(abs(vib)); %Impulse factor
            FTh(mytime,11)=max(abs(vib))/(mean(sqrt(abs(vib)))).^2; %Margin factor
            RS(mytime,1) = get_RSFeature(FTh);
            % convert to Frequency domain
            [m,~]=size(vib);
            myf = sf*(0:floor(m/2))/m; % frequency
            df=sf/m;                   % frequency resolution
            Y=fft(abs(vib));
            P2=abs(Y/tsize(1));
            P1=P2(1:tsize(1)/2+1);      % double sided spectrum
            P1(2:end-1)=2*P1(2:end-1);  % single sided spectrum
            ALLP(mytime,:)=P1;
            
            
            RS(mytime,2) = get_RSFeature(ALLP); % 0 - 12.8kHz
            si=1;ei=floor(3200/df);             % 0 - 3200Hz
            RS(mytime,3) = get_RSFeature(ALLP(:,si:ei));
            si=floor(3200/df);ei=floor(6400/df);% 3200 - 6400Hz
            RS(mytime,4) = get_RSFeature(ALLP(:,si:ei));
            si=floor(6400/df);ei=floor(9600/df);% 6400 - 9600Hz
            RS(mytime,5) = get_RSFeature(ALLP(:,si:ei));
            si=floor(9600/df);ei=floor(12800/df);% 9600 - 12800Hz
            RS(mytime,6) = get_RSFeature(ALLP(:,si:ei));

                    
            % do the same as above for vibration in different axis
            vib=va; % replace with va for other axis
            %time domain features
            FTv(mytime,1)=max(vib);  % max vibration
            FTv(mytime,2)=rms(vib);       % rms value
            FTv(mytime,3)=kurtosis(vib);  % kurtosis
            FTv(mytime,4)=skewness(vib);  % skewness
            FTv(mytime,5)=abs(max(vib))+ abs(min(vib));  % peak to peak
            FTv(mytime,6)=var(vib);       % variance
            FTv(mytime,7)=entropy(vib);   %entropy
            FTv(mytime,8)=max(abs(vib))/rms(vib); %crest factor
            FTv(mytime,9)=rms(vib)/mean(abs(vib)); %shape factor
            FTv(mytime,10)=max(abs(vib))/mean(abs(vib)); %Impulse factor
            FTv(mytime,11)=max(abs(vib))/(mean(sqrt(abs(vib)))).^2; %Margin factor
            
            RSv(mytime,1) = get_RSFeature(FTv);
            % convert to Frequency domain
            [m,~]=size(vib);
            myf = sf*(0:floor(m/2))/m; % frequency
            df=sf/m;                   % frequency resolution
            Y=fft(abs(vib));
            P2=abs(Y/tsize(1));
            P1=P2(1:tsize(1)/2+1);      % double sided spectrum
            P1(2:end-1)=2*P1(2:end-1);  % single sided spectrum
            ALLPy(mytime,:)=P1;

            RSv(mytime,2) = get_RSFeature(ALLPy); % 0 - 12.8kHz
            si=1;ei=floor(3200/df);               % 0 - 3200Hz
            RSv(mytime,3) = get_RSFeature(ALLPy(:,si:ei));
            si=floor(3200/df);ei=floor(6400/df);  % 3200 - 6400Hz
            RSv(mytime,4) = get_RSFeature(ALLPy(:,si:ei));
            si=floor(6400/df);ei=floor(9600/df);  % 6400 - 9600Hz
            RSv(mytime,5) = get_RSFeature(ALLPy(:,si:ei));
            si=floor(9600/df);ei=floor(12800/df); % 9600 - 12800Hz
            RSv(mytime,6) = get_RSFeature(ALLPy(:,si:ei));

            
    end
    mybid
    Fnet = [RS, RSv];
    save("GuoPaperFeaturesAcc_B_"+string(mybid)+".mat",'Fnet')
    clear P1 P2 Y FF myfft df FTh RS FTv RSv ALLP ALLPy
end

