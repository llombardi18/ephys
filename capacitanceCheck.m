%capacitance check
%07.09.21 1cell 1-vc.dat

%plot traces for Fig. 1
%path = '.\August2021CCwithalldrugs\07.09.21FCreP34\1-Cell';
path = '.';
%path = './11.10.22_P30/1stcell/';
filename = '1-VCok.dat';
%filename = '23717000.abf';
pathwithexp = [path  filesep filename];
if contains(filename,'.dat')
    [data, stimulus, time, exp] = hekaload(pathwithexp);
    fs = 1/time(2);
elseif contains(filename, '.abf')
     [d,si,h] = abfload(pathwithexp);
     data = squeeze(d(:,1,:)/1E12);
     stimulus = squeeze(mean(squeeze(d(:,2,:)),2)/1E3);
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
finish = floor(0.1*fs);

baseline = mean(data(start:finish,:),1);
data_centered = data - baseline;

Ts = median(diff(time));

IDplateaux = floor(0.48*fs);
IDprestep = floor(0.37*fs);
eps = 5E-12;%pA
before = floor(0.05*fs);

figure;
for IDsweep = 1:size(data,2)
    
    current_sweep = data_centered(:,IDsweep);
    Vpleateaux = mean(stimulusWindowed(IDplateaux-before:IDplateaux),1);
    Ipleateaux = mean(current_sweep(IDplateaux-before:IDplateaux),1);
    Vprestep = mean(stimulusWindowed(IDprestep-before:IDprestep),1);
    Iprestep = mean(current_sweep(IDprestep-before:IDprestep),1);
    
    DeltaV = (Vpleateaux - Vprestep);
    DeltaI = (Ipleateaux - Iprestep);
    [Imin, loc_min] = min(current_sweep);
    DeltaI_peak = Imin - current_sweep(IDprestep);
    
    RinPlusRs = DeltaV/DeltaI;
    Rs(IDsweep)= DeltaV/DeltaI_peak;
    Rin(IDsweep) = RinPlusRs - Rs(IDsweep);
    
    time_window = ([loc_min:IDplateaux] - loc_min)'*Ts;   
    f2 = fit(time_window,current_sweep(loc_min:IDplateaux)*1E12, 'exp2','TolFun', 1E-18,...
        'MaxIter',10000,...
        'StartPoint',[-100, -1/0.01, -100, -1/1], ...
        'Upper',[0 0 0 0], ...
        'Robust','Bisquare')
    plot(time_window,current_sweep(loc_min:IDplateaux)*1E12)
    hold on
    plot(f2)
    
    tau(IDsweep) = 1/f2.b;
    
end

Rparallel = Rs.*Rin./(Rs + Rin);
C = abs(tau)./Rparallel;

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