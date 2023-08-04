%plot traces for Fig. 1
path = 'D:\Carmela NSYN 2020 REST Project\2020\August2021CCwithalldrugs\21.09.21FDCreP34M361\4-Cell';
pathwithexp = [path  '\2-CC.dat'];
[data_dcre, stimulus_dcre, time_dcre, exp_dcre] = hekaload(pathwithexp);

%path = 'D:\Carmela NSYN 2020 REST Project\2020\August2021CCwithalldrugs\07.09.21FCreP34\4-Cell';
%path = 'D:\Carmela NSYN 2020 REST Project\2020\August2021CCwithalldrugs\23.09.21FCreP36M361\1-Cell';
path = 'D:\Carmela NSYN 2020 REST Project\2020\August2021CCwithalldrugs\07.09.21FCreP34\2-Cell';
pathwithexp = [path  '\2-CC.dat'];
[data_cre, stimulus_cre, time_cre, exp_cre] = hekaload(pathwithexp);

%respresentative trace
figure(Name='Representative dcre',Units="centimeters",Position=[10 10 10 5]);
IDsweep = [14];
plot(time_dcre, data_dcre(:,IDsweep)*1000)
xlabel('s')
ylabel('mV')
xlim([0 2])
ylim([-85, 80])
box off
set(gca, 'FontSize', 12)

figure(Name='Representative cre',Units="centimeters",Position=[10 10 10 5]);
IDsweep = [14];
plot(time_cre, data_cre(:,IDsweep)*1000)
xlabel('s')
ylabel('mV')
xlim([0 2])
ylim([-85, 80])
box off
set(gca, 'FontSize', 12)

%single action potential
figure;
IDsweep = [13];
start = floor((0.275)/time_dcre(2));
finish = floor((0.325)/time_dcre(2));
plot(time_dcre(start:finish) - time_dcre(start), data_dcre(start:finish,IDsweep)*1000)
hold on
IDsweep = [5];
start = floor((0.322)/time_cre(2));
finish = floor((0.372)/time_cre(2));
plot(time_cre(start:finish) - time_cre(start), data_cre(start:finish,IDsweep)*1000)
xlabel('s')
ylabel('mV')
ylim([-85, 80])
box off
set(gca, 'FontSize', 12)
legend('\DeltaCre','Cre')

%phase plot
figure(Units = 'centimeters',Position = [5 5 10 10])
lp = designfilt('lowpassiir','FilterOrder', 4, ...
             'PassbandFrequency', 10000, 'PassbandRipple', 1,...
             'SampleRate', 1/time_cre(2));
window_dcre = [14900:15300];
IDsweep = [13];
data_filt = filtfilt(lp, data_dcre);
voltage_rate = diff(data_filt,1,1)/time_dcre(2);
voltage_rate = vertcat(voltage_rate, voltage_rate(end,:));
plot(data_filt(window_dcre,IDsweep), voltage_rate(window_dcre,IDsweep))
hold on
window_cre = [15000:23000];
IDsweep = [4];
data_filt = filtfilt(lp, data_cre);
voltage_rate = diff(data_filt,1,1)/time_cre(2);
voltage_rate = vertcat(voltage_rate, voltage_rate(end,:));
plot(data_filt(window_cre,IDsweep), voltage_rate(window_cre,IDsweep))
hold on
ylim([-200 900])
xlim([-0.055 0.08])
yline(0.01)
ylabel('dV / dt (V/s)')
xlabel('V')
box off
legend('\DeltaCre','Cre')
