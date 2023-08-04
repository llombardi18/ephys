%plot traces for Fig. 1
path = 'E:\Carmela NSYN 2020 REST Project\2020\REST\2_Febrary2021\07.02.21RestDCreP32Fmother260\2-cell_Toanalyse';
pathwithexp = [path  '\2-CCok.dat'];
[data, stimulus, time_exp, exp] = hekaload(pathwithexp);

%feature extraction for single action potential
[finish, n_sweeps] = size(data);

fs = 1/time_exp(2);
start = floor(0.1*fs);
%finish = floor(0.36*fs);

threshold_voltage = 0;
has_at_least_one_action_potential = false;
for IDsweep = 1:n_sweeps
    
    voltage = data(start:finish, IDsweep);

    %if the voltage goes above zero, there has been an action potential
    if any(voltage > threshold_voltage)
        has_at_least_one_action_potential = true;
    end
    
    if has_at_least_one_action_potential
        
        
        %voltage = data(start:finish, IDsweep+1);

        data_filt = movmean(voltage, 5);
        voltage_rate = diff(data_filt, 1, 1)*fs;
        voltage_rate = vertcat(voltage_rate, voltage_rate(end,:));

        [max_rising_slope, loc_max_slope] = findpeaks(voltage_rate, "NPeaks", 1,"Threshold", 0, "SortStr","descend");
        [max_falling_slope, loc_min_slope] = findpeaks(-voltage_rate, "NPeaks", 1,"Threshold", 0, "SortStr","descend");
        [AP_peak, loc_peak] = findpeaks(data_filt, "NPeaks", 1,"Threshold", 0, "SortStr","descend");

        half_width_around_peak = 1550;%points
        rate_threshold = 5;
        window = loc_peak - half_width_around_peak : loc_peak + half_width_around_peak;
        above_threshold = find(voltage_rate(window) > rate_threshold);
        loc_threshold = loc_peak - half_width_around_peak + above_threshold(1);
        v_threshold = data_filt(loc_threshold);
        
        %half width
        [inv_AP_peak, loc_inv_peak] = findpeaks(-data_filt(window), "NPeaks", 1,"Threshold", 0, "SortStr","descend");
        loc_inv_peak = loc_inv_peak - half_width_around_peak + loc_peak;
        half_height = (AP_peak + inv_AP_peak) / 2;
        locs = find(data_filt(window)> (AP_peak - half_height));
        width = (locs(end) - locs(1))/fs;

        figure;
        plot(time_exp(start:finish)*1000,data_filt,'b.')
        hold on 
        %plot(time,data_filt(:,IDsweep-1))
        plot(time_exp(start+loc_max_slope)*1000, data_filt(loc_max_slope),'rx')
        plot(time_exp(start+loc_min_slope)*1000, data_filt(loc_min_slope),'kx')
        plot(time_exp(start+loc_peak)*1000, data_filt(loc_peak),'bx')
        plot(time_exp(start+loc_threshold)*1000, data_filt(loc_threshold),'cx' )
        plot(time_exp(start+loc_inv_peak)*1000, data_filt(loc_inv_peak),'yx' )
        legend({'trace','max slope','min slope','peak','threshold','trough'})
        plot(time_exp(start+window(1)+locs(1)-1)*1000, data_filt(window(1)+locs(1)-1),'gx')
        plot(time_exp(start+window(1)+locs(end)-1)*1000, data_filt(window(1)+locs(end)-1),'gx')
        
    end

    if has_at_least_one_action_potential
       disp('Rising slope V/s, falling slope V/s, AP_peak V, V_threshold V, width s, trough V, DeltaTpeaktrough s') 
       AP_summary = [max_rising_slope, max_falling_slope, AP_peak, ...
                    v_threshold, width, -inv_AP_peak, (loc_inv_peak-loc_peak)/fs]
       clearvars -except AP_summary
       break
    end
end