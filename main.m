clearvars
close all
datafolder = 'D:\Ephys_WashU\Chrimson_Chronos\11.23.22\1stcell';
addpath(datafolder);
filenames_raw = ls(datafolder)
for IDfile = 3:size(filenames_raw,1)
    filename = filenames_raw(IDfile,1);
    [d,si,h] = abfload([datafolder '\' filenames_raw(IDfile,:)],'doDisplayInfo',true);

    fs = 10000;
    t = [1:size(d,1)]/fs;

    
    if (filename == 'C')
        figure
        stackedplot(t*1000, d(:,1,:))
        xlabel('ms')
        title(filenames_raw(IDfile,:))

%         figure
%         plot(t*1000, d(:,1,20))
%         xlabel('ms')
    elseif (filename == 'V')

        figure
        stackedplot(t*1000, d(:,1,:))
        xlabel('ms')
        %ylabel('pA')
        %ylim([-500, 100])
        title(filenames_raw(IDfile,:))
    end
    

end




%d time x ephysis x trial
%ephys: 1 = VOLTAGE mV, 2 = CURRENT pA for CC
% inverse for VC



%experiment = HEKA_Importer('1-VCok.dat');
% experiment = HEKA_Importer('1-VCok.dat');
% 
% raw = cell2mat(experiment.RecTable.dataRaw{1});
% stimulus = experiment.RecTable.stimWave{1}.DA_3;
% fs = experiment.RecTable.SR(1);
% t = [1:size(raw,1)] / fs;
% biases = [experiment.trees.dataTree{:,5}];
% bias = [biases(end-25+1:end).TrZeroData];
% 
% figure
% plot(t,raw - bias)
% 
% figure
% plot(stimulus)