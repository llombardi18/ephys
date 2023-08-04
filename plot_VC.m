%plot traces for Fig. 1
path = '.\TracceVC\9.6.21 2cell';
pathwithexp = [path  '/2-s4m.dat'];
[data_dcre, stimulus_dcre, time_dcre, exp_dcre] = hekaload(pathwithexp);

%% respresentative trace
figure(Name='Representative dcre',Units="centimeters",Position=[10 10 10 7]);
IDsweep = [1];
window = [1:1:12e6];

bpf=designfilt('bandpassiir','FilterOrder',50, ...
         'HalfPowerFrequency1',5,'HalfPowerFrequency2',500, ...
         'SampleRate', 1/time_dcre(2));

lpf=designfilt('lowpassiir','FilterOrder', 16, ...
         'HalfPowerFrequency',500,'DesignMethod','butter', ...
         'SampleRate', 1/time_dcre(2));

data_dcre_filt = filtfilt(lpf, data_dcre);
plot(time_dcre(window), data_dcre_filt(window,IDsweep)*1e12,Color= [0.5 0.5 0.5])
xlabel('s')
ylabel('pA')
xlim([0 10]+26)
ylim([0, 120]+390)
%yticks ([-85:20:80])
box off
set(gca, 'FontSize', 12)