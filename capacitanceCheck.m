%capacitance check
%07.09.21 1cell 1-vc.dat
clearvars
%plot traces for Fig. 1
%path = 'C:\Users\cvitale\Documents\MATLAB\REST\Epilepsy\EPSCs\September2021\08.09.21Dcre1M293P35\3-Cell';
path = '.';
%path = './11.10.22_P30/1stcell/';
%filename = '3-vc.dat';
filename = ['2024_07_24_0000.abf'];
pathwithexp = [path  filesep filename];
if contains(filename,'.dat')
    [data, stimulus, time, exp] = hekaload(pathwithexp);
    fs=1/time(2);
elseif contains(filename, '.abf')
     [d,si,h] = abfload(pathwithexp);
     data = squeeze(d(:,1,:)/1E12);
     stimulus = squeeze(mean(squeeze(d(:,1,:)),2)/1E3);
     fs = 1/(si*1E-6); %Hz
     time = [0:size(stimulus,1)-1]/fs;
end
%% respresentative trace
%stim is in millivolts and needs to be cut to the same shape
%data is in pA
%cut the stimulus to the same size of the data
nSamples = size(data,1);
stimulusWindowed = stimulus(1:nSamples);
%remove initial baseline
start = ceil(0*fs)+1;
finish = floor(0.3*fs);
baseline = mean(data(start:finish,:),1);
data_centered = data - baseline;
Ts = median(diff(time));
IDplateaux = floor(0.204*fs);
%IDplateaux = floor(0.493*fs);
IDprestep = floor(0.104*fs);
%IDprestep = floor(0.389*fs);
eps = 5E-12;%pA
before = floor(0.017*fs);
figure;
for IDsweep = 1:size(data,2)
    disp(IDsweep)
    current_sweep = data_centered(:,IDsweep);
    Vpleateaux = mean(stimulusWindowed(IDplateaux-1*before:IDplateaux),1);
    Ipleateaux = mean(current_sweep(IDplateaux-1*before:IDplateaux),1);
    Vprestep = mean(stimulusWindowed(IDprestep-2*before:IDprestep),1);
    Iprestep = mean(current_sweep(IDprestep-2*before:IDprestep),1);
    DeltaV = -0.005; %(Vpleateaux - Vprestep); %or DeltaV = 0.005 when axon gives me the stimulus in pA or strange values
    DeltaI = (Ipleateaux - Iprestep);
    Maxloc_min = floor(0.210*fs)
    %Maxloc_min = floor(0.750*fs)
    [Imin, loc_min] = min(current_sweep (1:Maxloc_min));
    DeltaI_peak = Imin - Iprestep;
    RinPlusRs = DeltaV/DeltaI;
    Rs(IDsweep)= DeltaV/DeltaI_peak;
    Rin(IDsweep) = RinPlusRs - Rs(IDsweep);
    time_window = ([loc_min:IDplateaux] - loc_min)'*Ts;   
    f2 = fit(time_window,current_sweep(loc_min:IDplateaux)*1E12, 'exp2','TolFun', 1E-18,...
        'MaxIter',100000,...
        'StartPoint',[-100, -1/0.01, -100, -1/1], ...
        'Upper',[0 0 0 0], ...
        'Robust','Bisquare')
    plot(time_window,current_sweep(loc_min:IDplateaux)*1E12)
    hold on
    plot(f2)
    
    if ((f2.b) > -3500 && f2.b < -100)
        tau(IDsweep) = 1/f2.b;
    elseif ((f2.d) > -3500 && f2.d < -100)
        tau(IDsweep) = 1/f2.d;
    else 
        error ("no tau in the range specified")
    end
end
Rparallel = Rs.*Rin./(Rs + Rin);
C = abs(tau)./Rs;
figure;
subplot(1,3,1)
histfit(C / 1E-12)
title('C_m (pF)')
subplot(1,3,2)
histfit(Rin / 1E6)
title('R_{in} (M\Omega)')
subplot(1,3,3)
histfit(Rs / 1E6)
title('R_s (M\Omega)')
%%
figure;
plot (data_pA (15000:17000,1:11))
%% figure simil paper
figure( Units= 'centimeters', Position= [5 5 12 12])
time_ms= time*1000
data_pA = data*1E12
stimulus_mV = stimulus*1000
plot(time_ms, data_pA, 'DisplayName','data','LineWidth',2) 
box off
ylabel('(pA)','FontSize',12,'FontName','Times')
xlabel('(ms)','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
xlim([320 500])
ylim([-1600 100])
%% figure for cell health
figure( Units= 'centimeters', Position= [5 5 12 12])
time_ms= time*1000
data_pA = data*1E12
stimulus_mV = stimulus*1000
plot(time_ms, data_pA, 'DisplayName','data') 
box off
ylabel('(pA)','FontSize',12,'FontName','Times')
xlabel('(ms)','FontSize',12,'FontName','Times')
xlim([200 800])
ylim([-2000 100])