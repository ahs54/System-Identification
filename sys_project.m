clearvars
clc
close all
%% Load The Data
% Import the file
load ('-mat', 'C:\Users\hp\Desktop\System ID Project\Load\ausdata.mat');

%% Visual Analysis of the data
figure
plot(data.SYSLoad);title('Half Hourly Sampled Load')
xlabel('Time');ylabel('Load')
figure
plot(data.DryBulb);title('Half Hourly Sampled Temperature')

xlabel('Time');ylabel('Temperature')


%% The relation between temperature and the load from 1/1/2006 to 12/31/2010
scatter(data.DryBulb,data.SYSLoad);title('Load Vs Temperature')
xlabel('Temperature');ylabel('Load')





%% Coherence 
%Power temperature coherence for January 2016
Ts=0.5;
Fs=1/Ts;
figure(49)
mscohere(data.SYSLoad(1:31*48),data.DryBulb(1:31*48),[],[],[],Fs);title('January');
figure(50)
mscohere(data.SYSLoad(1:365*48),data.DryBulb(1:365*48),[],[],[],Fs);title('2016');
%how to specify these parameters?


% %% 
%  M=round(sqrt(365*48));
% [cxyM,w]=cohere(data.SYSLoad(1:365*48),data.DryBulb(1:365*48),M);
% figure(1); clf;
% stem(w/2,cxyM,'*');
% 

%% Crosscorrelation
[C1,lag1]=xcorr(data.SYSLoad(1:31*48),data.DryBulb(1:31*48),'biased');
plot(lag1,C1)
title('Correlation Between the Temperature and the Load')
%this is for January 2016


%% Autocorelation and Partial Autocorrelation to determin the order of the model
subplot(2,1,1);
autocorr(data.DryBulb);
subplot(2,1,2);
parcorr(data.DryBulb);

 %% Covariance
 [C1,lag1]=xcov(data.SYSLoad(1:31*48),data.DryBulb(1:31*48),'biased');
plot(lag1,C1)
title('Covariance Between the Temperature and the Load')
%this is for January 2006


%% Plot for one year

figure
plot(data.SYSLoad(1:365*48));title('Half Hourly Sampled Load for 2016')
xlabel('Time');ylabel('Load')
figure
plot(data.DryBulb(1:365*48));title('Half Hourly Sampled Temperature 2016')

xlabel('Time');ylabel('Temperature')


%% Frequency analysis with the mean removed
% taking the offset out of the output doesn't affect the dynamics of the system and it
% makes the frequency response more clear
load=data.SYSLoad-mean(data.SYSLoad);% subtracting the mean from the output

Fs=2;
Dt=length(data.SYSLoad);
Dt2=10*2^nextpow2(Dt);      %appropriate sampling rate
fx2=fft(load,Dt2);
t2=(1:length(fx2))*Fs/Dt2;
mag=abs(fx2);
figure
plot(t2,mag);grid on;xlabel('Frequency');title('Frequency Content of Power Consumption Data')


%% 
temp=data.DryBulb-mean(data.DryBulb);% subtracting the mean from the input
Fs=2;
Dt=length(temp);
Dt2=10*2^nextpow2(Dt);      %appropriate sampling rate
fx2=fft(temp,Dt2);
t2=(1:length(fx2))*Fs/Dt2;
mag=abs(fx2);
figure
plot(t2,mag)



%% High pass filter for the output

figure
bhi=fir1(300,.04,'high');
out=filter(bhi,1,load);
%freqz(bhi)
subplot(2,1,1)
plot(out)
subplot(2,1,2)
plot(out(1:31*48))
hold on
plot(load(1:31*48))

%% High pass filter for the input
figure
bhi=fir1(300,.04,'high');
in=filter(bhi,1,temp);
%freqz(bhi)

subplot(2,1,1)
plot(in)
subplot(2,1,2)
plot(in(1:31*48))
hold on
plot(temp(1:31*48))

% subtracting the mean from the input
Fs=2;
Dt=length(out);
Dt2=10*2^nextpow2(Dt);      %appropriate sampling rate
fx2=fft(out,Dt2);
t2=(1:length(fx2))*Fs/Dt2;
mag=abs(fx2);
figure
plot(t2,mag)


%% Fitting to Armax model for different days
f=31*48;
z = iddata(out(150:198+f),in(150:198+f),1/Fs);
%sys=armax(z,[8 15 10 1]); for non filtered input
%sys=armax(z,[3 7 6 0]);
%sys=armax(z,[4 4 4 0]);
sys=armax(z,[3 2 1 1]);
compare(z,sys,3)




%% Monthly prediction for different periods
%Is the comparison valid???
f=48;
% z = iddata(out(150:150+f),in(150:150+f),1/Fs);


%sys=armax(z,[8 15 4 1]); 
%sys=armax(z,[3 7 6 0]);
%sys=armax(z,[7 5 4 2]);
%sys=armax(z,[4 4 3 0]);
%sys=armax(z,[5 1 1 2]);
sys=armax(z,[4 4 3 0]);
%sys=armax(z,[15 8 10 123]);
%sys=armax(z,[3 2 1 1]);
% compare(z,sys,3)
out1 = out(150:150+f);
in1 = in(150:150+f);
dat = iddata(out1,in1,1/Fs);
h=1;
vec_aic = 50*ones(1,64);
vec_fpe = 50*ones(1,64);

for k=1:4
    for j=1:4
        for i=1:4
            g = armax(dat,[i j k 1]);
            vec_aic(h) = aic(g);
            vec_fpe(h) = fpe(g);        
            if   vec_aic(h) <= min(vec_aic) 
                opt_order = [i j k];
                FPE = min(vec_fpe);
                AIC = vec_aic(h);
            end 
            h=h+1;
        end
    end 
         
end
% figure;plot(vec_aic);grid on;title('AIC')
% figure;plot(vec_fpe);grid on;title('FPE') 
%% New Code

g = armax(dat,[opt_order 1]);% 90.46% Fitting
w1 = randn(length(in1),1);
yapp1 = filter([0 g.par(5) g.par(6)],[1 g.par(1) g.par(2) g.par(3) g.par(4)],in1)+ filter([1 g.par(7) g.par(8) g.par(9)],[1 g.par(1) g.par(2) g.par(3) g.par(4)],w1);
e = out1- yapp1;
figure(12);plot(yapp1);hold on ;plot(out1);title('Model Vs Output');grid on
figure;resid(dat,g)
figure;plot(yapp1);hold on; plot(out1);grid on;title('Model for 7 days vs Output for 7 days ');grid on
% phi = [-out1(4:end-1), -out1(3:end-2),-out1(2:end-3),-out1(1:end-4),in1(2:end-1), in1(1:end-2), w1(3:end-1),w1(2:end-2),w1(1:end-3)];
% cross_corr = xcorr(phi,e);
% figure;plot(cross_corr);title('Crosscorrelation Between phi and e');grid on

%% NON_parametric
f=48;
out1 = out(150:150+f);
in1 = in(150:150+f);
Sy = fft(xcorr(out1));
Sxy = fft(xcorr(in1,out1));
Sx = fft(xcorr(in1));
H = Sxy/Sx;
Syest = (H.^2)*Sx;
figure;plot(abs(Syest));hold on; plot(abs(Sy));grid on;legend('Freq Estimated Power','Freq Data Power');title('Nonparametric ID Frequency Content')
figure;plot(abs(ifft(Syest)));hold on; plot(abs(ifft(Sy)));grid on;legend('Estimated Power','Data Power');title('Nonparametric ID Time Domain');xlabel('Lags');ylabel('Power in the ACF')