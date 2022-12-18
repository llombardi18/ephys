function [data, stimulus, time, experiment] = hekaload(filename, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% filename should be a string that contains .dat
% varargin: 'plot';

% d time x ephysis x trial
% ephys: 1 = VOLTAGE mV, 2 = CURRENT pA for CC
% inverse for VC
plotdata = false;
resampling = false;
fs2 = 1;
if (nargin > 1)
    for i = 1:(nargin-1)
        switch varargin{i}
            case 'resample'
                resampling = true;
                fs2 = varargin{i+1};
            case 'plot'
                plotdata = true;
        end
    end
end

experiment = HEKA_Importer(filename);

%extract data and parameters
raw = cell2mat(experiment.RecTable.dataRaw{1});
[nTimepoints, nSweeps] = size(raw);
fs = experiment.RecTable.SR;
biases = [experiment.trees.dataTree{:,5}];
bias = [biases.TrZeroData];
stimulus = experiment.RecTable.stimWave{1}.DA_3;
time = [1:size(raw,1)] / fs;
data = raw - bias;

%filter
lp = designfilt('lowpassiir','FilterOrder', 8, ...
            'PassbandFrequency', 500, 'PassbandRipple', 0.1,...
            'SampleRate', fs);
data = filtfilt(lp, data);

%resampling
if (resampling)
    data = resample(data, 1, floor(fs/fs2));
    time = resample(time, 1, floor(fs/fs2));
end

%plotdata
if plotdata
    figure;
    plot(time,data)
    grid on

end
end