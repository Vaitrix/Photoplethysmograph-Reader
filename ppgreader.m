%% load files
load('PPG.mat','PPG1_LED3','fs_PPG');
PPG=PPG1_LED3;
t_ppg=(0:length(PPG)-1)*1/fs_PPG;
%% highpass filter
fs_PPG = 100;
t_ppg = (0:length(PPG)-1)*1/fs_PPG;
S = abs(fft(PPG))/length(t_ppg);
S = 20* log10(S/max(S));
k = 0:1:length(t_ppg)-1;
f = k*fs_PPG/length(t_ppg);
sel_f = [0, 0.00000005/50, 1/20, 1];
sel_g = [0,0,1,1];
b = fir2(1000, sel_f, sel_g);
fy = filter(b,1,PPG);
Sy = abs(fft(fy))/length(fy);
SSy = 20*log10(Sy/max(Sy));
delay_hp = grpdelay(b, 1, 200,fs_PPG);
%% lowpass filter
sel_f = [0, 1/50, 1.8/50, 1];
sel_g = [1,1,0,0];
b2 = fir2(1000,sel_f, sel_g);
sig_lp = filter(b2,1,fy);
delay_lp = grpdelay(b2,1,200,fs_PPG);
delay = delay_lp+delay_hp;
%% Smoothening of signal
%fwhm = 70; %in ms
%normalized time vector in milliseconds
%k = 10;
%create Gaussian window
%n = length(ppg_sg);
%y(1,n) = 0;
%ii = 0;
%for i = k+1:1:n-k-1
%ii = ii+1;    
%gtime = i-k:1:i+k;
%gauswin = exp((-4*log(2)*gtime.^2)/fwhm.^2);
%gauswin = gauswin/sum(gauswin);
%gauswin = gauswin';
%y(ii) = sum(ppg_sg(gtime).*gauswin);
%end
%figure
%y = y';
%plot(y);
%% Adaptive threshold Detection
ecg_filt = sig_lp;
threshold = 0.01*ecg_filt(1088);
l = length(ecg_filt);
m = [];
i = 1;
for u = 600:1:l-3
   if (ecg_filt(u)> threshold)
       if((ecg_filt(u)> ecg_filt(u-3))&&(ecg_filt(u) > ecg_filt(u+3)))
           if(i <= 2)
                m = [m, u];
                threshold = 0.01*ecg_filt(u);
                i = i+1;
           elseif(u > m(i-1)+60)
               m = [m, u];
               threshold = 0.4*ecg_filt(u);
               i = i+1;
           end
           
       end
   end
  
end
plot(PPG);hold on;
plot((m-26),PPG(m-26), 'o');
plot(ecg_filt);
plot(m, ecg_filt(m), 'o');

legend('raw PPG signal', 'detected heart rate', 'filtered PPG signal', 'detected heart rate');




