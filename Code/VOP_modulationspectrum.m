clc;
clear all;
close all;
%% audioread
[y,fs]=audioread('Dont_ask_me_to_carry_an_oily_rag_like_that.wav');
%[y,fs]=audioread('na.wav');
N = length(y);
q=18;
%% filtfilting
p=4000/q;
x(1,:)=bandpass(y(:,1),[15 p],fs);
for i=2:q
    x(i,:)=bandpass(y(:,1),[(i-1)*p i*p],fs);
end
%% half wave rectifier
for i=1:q
    for j=1:N
        if x(i,j)<0
            a(i,j)=0;
        else
            a(i,j)=x(i,j);
        end
    end
end
%% Lowpass filtfilt
for i=1:q
    lp(i,:)=lowpass(a(i,:),28,fs,'Steepness',0.95);
%     lp(i,:)=smooth(lp(i,:),50*fs/1000);
end
%% normalise
for i=1:q
    dw(i,:)=lp(i,:)./max(lp(i,:));
end
%% fft window
ham=hamming(20);
for i=1:q

    temp=dw(i,:);
    temp=buffer(temp,20,19);
    
    temp=temp.*(ham*ones(1,length(temp)));
    
    temp=fft(temp,40);
    
    temp = sum(abs(temp(4:16,:)));
    
    temp1(i,:)=temp;
    
end
temp1=sum(temp1);

temp1=resample(temp1,80,fs);
temp1=resample(temp1,fs,80);
temp1=temp1/max(temp1);

%% enhancement
temp1=filtfilt(hamming(1600),1,temp1);
y1=diff(temp1);
y2=buffer(y1,160,159);

y3=sum(y2);

y4=y3;

y4(y3<0)=0;

Fogd=diff(gausswin(800));

y5=filter(Fogd,1,y4);

%{
subplot(311)
plot(y4);
subplot(312)
plot(Fogd); 
subplot(313); 
plot(y5);
%}

%% Enhancing the VOP and removing close peaks and ploting it with speech signal

y5=y5./max(y5);
y5(y5<0)=0;
y5(y5<0.1)=0;

y5=smooth(y5,320);
[pks, vop]=findpeaks(y5);

subplot(211)
plot(y5)
title('VOP evidence plot');
subplot(212)
plot(y-mean(y))
hold on
stem(vop,ones(size(pks)),'*')
title('VOP in speech signal')