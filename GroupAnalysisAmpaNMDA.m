%group analysis script for AMPA NMDA IO, and ratio
close all
clearvars
%point to the file with the preprocessed group analsysis
path_group_analysis_IO_ratio = './Ephys/Christian''s setup/Analysis';
path_with_filename = [path_group_analysis_IO_ratio '/Group_Analysis_IO_and_Ratio.xlsx'];
addpath(path_group_analysis_IO_ratio)
colours = {[0 0.4470 0.7410],[0.9290 0.6940 0.1250],[0.301 0.7450 0.9330],[0.85 0.32 0.09]};
channels = {'AMPA','NMDA'};
%genotypes = {'\DeltaCre', 'Cre'};
genotypes = {'WT', 'KO'};
%% IO analysis
%: Read the excel file
ranges = {'A29:J39','A42:G52';'A59:D69','A73:D83'};
ylims = [0 3000; 0 700];
raw = {}
for IDchannel = 1:length(channels)
    for IDgeno = 1:length(genotypes)
        excel_sheet_name = [channels{IDchannel} 'IO'];
        range = ranges{IDchannel, IDgeno};
        
        raw{IDchannel,IDgeno} = readtable(path_with_filename,'Sheet',excel_sheet_name,...
            'Range',range);
    end
end
for IDchannel = 1:2
    
    x = table2array(raw{IDchannel,1}(:,"Trace_uA")); %any genotype will do, chosen 1
    figure('Name',[channels{IDchannel} 'IO'],'Units','centimeters','Position',[5 5 7 7])
    for IDgeno = 1:2
        tbl = raw{IDchannel,IDgeno}(:, wildcardPattern + "cell" + wildcardPattern);
        data = table2array(tbl);
        
        mean_across_cells = mean(data,2);
        std_across_cells = std(data,0,2);
        sem = std_across_cells/sqrt(size(data,2));
        
        errorbar(x,mean_across_cells,sem, 'Color',colours{IDgeno},...
            'LineWidth',1.5,Marker='o',MarkerFaceColor=colours{IDgeno})
        hold on
    end
    
    box off
    set(gca, "TickDir","out")
    set(gca, "FontSize",12)
    ylabel('EPSC current (pA)', FontSize=12, FontName='Times')
    xlabel('Stimulus Intensity (\muA)', FontSize=12, FontName='Times')
    legend(genotypes)
    set(gca, "FontName","Times")
    xlim([0 120])
    ylim(ylims(IDchannel,:))
    yticks(linspace(ylims(IDchannel,1),ylims(IDchannel,2),6))
    axis square
    
    figure('Name',[channels{IDchannel} 'IOslope'],'Units','centimeters','Position',[5 5 7 7])
    slopes = {};
    mean_slope_across_cells = [];
    sem = [];
    for IDgeno=1:2
        tbl = raw{IDchannel,IDgeno}(:, wildcardPattern + "cell" + wildcardPattern);
        data = table2array(tbl);
        
        %calculate slope using matrix inversion shorthand
        slopes{IDgeno} = x\data;
        mean_slope_across_cells(IDgeno) = mean(slopes{IDgeno})
        std_slope_across_cells = std(slopes{IDgeno},0,2);
        sem(IDgeno) = std_slope_across_cells/sqrt(size(slopes{IDgeno},2))
        
    end
    
    b=bar(1:length(mean_slope_across_cells),mean_slope_across_cells)
    for IDgeno=1:2
        b.FaceColor = 'flat';
        b.CData(IDgeno,:)=colours{IDgeno};
    end    
    hold on
    errorbar(1:length(mean_slope_across_cells),mean_slope_across_cells, ...
        0,sem,Color=colours{size(mean_slope_across_cells,1)})
    
    for IDgeno=1:2 
        scatter(IDgeno,slopes{IDgeno}, 50, [0.5 0.5 0.5],"filled")
        hold on
    end
    %xlim([0 (length(mean_slope_across_cells)+1)])
    xlim([0 3])
    %xticks([1:(length(mean_slope_across_cells)+1)])
    xticks([1:2])
    xticklabels(genotypes)
    box off
    ylabel('IO slope (pA/\muA)','FontSize',12,'FontName','Times')
    set(gca, "TickDir","out")
    set(gca, "FontSize",12)
    set(gca, "FontName",'Times')
end
%% Ratio analysis
raw = {}
data = []
ranges_ratio = {'A14:E16','A20:E22'};
for IDgeno=1:2
    raw{IDgeno} = readtable(path_with_filename, 'Sheet','AMPANMDARATIO', ...
        'Range',ranges_ratio{IDgeno});
    data=table2array(raw{IDgeno}(:, wildcardPattern + "cell" + wildcardPattern));
    
    ratios{IDgeno}= data(2,:)./data(1,:)
end
figure('Name','AMPANMDARatio','Units','centimeters','Position',[5 5 7 7])
for IDgeno=1:2
    mean_ratio_across_cells(IDgeno) = mean(ratios{IDgeno})
    std_ratio_across_cells = std(ratios{IDgeno},0,2);
    sem(IDgeno) = std_ratio_across_cells/sqrt(length(ratios{IDgeno}));
end
b=bar(mean_ratio_across_cells)
for IDgeno=1:2
    b.FaceColor = 'flat';
    b.CData(IDgeno,:)=colours{IDgeno};
end   
hold on
errorbar(1:length(mean_ratio_across_cells),mean_ratio_across_cells, ...
        0,sem,Color=colours{size(mean_ratio_across_cells,1)})
for IDgeno=1:2
    scatter(IDgeno,ratios{IDgeno},50,[0.5 0.5 0.5],"filled")
 
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 3])
ylim([0 1])
%xticks([1:(length(mean_slope_across_cells)+1)])
xticks([1:2])
xticklabels(genotypes)
box off
ylabel('NMDA AMPA Ratio','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
%% AMPA and NMDA EPSC
meanAMPA= []
meanNMDA= []
figure ('Name','AMPAEPSC','Units','centimeters','Position',[5 5 7 7])
for IDgeno=1:2
    data=table2array(raw{IDgeno}(:, wildcardPattern + "cell" + wildcardPattern));
    meanAMPA (IDgeno)= mean(data(1,:))
    std_meanAMPA = std(data(1,:),0,2);
    sem(IDgeno) = std_meanAMPA/sqrt(length(data(1,:)));
end
b=bar(meanAMPA)
for IDgeno=1:2
    b.FaceColor = 'flat';
    b.CData(IDgeno,:)=colours{IDgeno};
end   
hold on
errorbar(1:length(meanAMPA),meanAMPA, ...
        0,sem,Color=colours{size(meanAMPA,1)})
for IDgeno=1:2
    data=table2array(raw{IDgeno}(:, wildcardPattern + "cell" + wildcardPattern));
    scatter(IDgeno,data(1,:),50,[0.5 0.5 0.5],"filled")
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 3])
ylim([0 1500])
%xticks([1:(length(mean_slope_across_cells)+1)])
xticks([1:2])
xticklabels(genotypes)
box off
ylabel('AMPA Ampl. (pA)','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
figure ('Name','NMDAEPSC','Units','centimeters','Position',[5 5 7 7])
for IDgeno=1:2
    data=table2array(raw{IDgeno}(:, wildcardPattern + "cell" + wildcardPattern));
    meanNMDA(IDgeno)= mean(data(2,:))
    std_meanNMDA = std(data(2,:),0,2);
    sem(IDgeno) = std_meanNMDA/sqrt(length(data(2,:)));
end
b=bar(meanNMDA)
for IDgeno=1:2
    b.FaceColor = 'flat';
    b.CData(IDgeno,:)=colours{IDgeno};
end
hold on 
errorbar(1:length (meanNMDA), meanNMDA, ...
        0,sem,Color=colours{size(meanNMDA,1)})
for IDgeno=1:2
    data=table2array(raw{IDgeno}(:, wildcardPattern + "cell" + wildcardPattern));
    scatter(IDgeno,data(2,:),50,[0.5 0.5 0.5],"filled")
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 3])
ylim([0 500])
%xticks([1:(length(mean_slope_across_cells)+1)])
xticks([1:2])
xticklabels(genotypes)
box off
ylabel('NMDA Ampl. (pA)','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
%% PPR
figure('Name','PPR', 'Units','centimeters', Position=[5 5 10 10])
raw = {};
ranges_ppr = {'A2:I7','A10:K15','A40:I45','A48:H53'};
interval=[]
for IDgeno=1:4
    raw{IDgeno} = readtable(path_with_filename, 'Sheet','PPR', ...
        'Range',ranges_ppr{IDgeno});
    
    interval(IDgeno,:)= raw{IDgeno}.Interval_ms;
    ppr{IDgeno}= raw{IDgeno}(:, wildcardPattern + "cell" + wildcardPattern);
end
for IDgeno=1:4
    mean_ppr(IDgeno,:)= mean(table2array(ppr{IDgeno}),2,"omitnan")'
    std_ppr(IDgeno,:)= std(table2array(ppr{IDgeno}),0,2,"omitmissing")'
    sem_ppr(IDgeno,:)= std_ppr(IDgeno,:)/sqrt(size(ppr{IDgeno},2))
    errorbar(interval(IDgeno,:),mean_ppr(IDgeno,:),sem_ppr(IDgeno,:), ...
    'LineWidth',1.5,'Color',colours{IDgeno},Marker='o',MarkerFaceColor=colours{IDgeno})
    hold on
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 600])
ylim([0 2.5])
legend(genotypes)
box off
ylabel('PPR ratio','FontSize',12,'FontName','Times')
xlabel('ISI (ms)')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
%% Passive Properties
figure('Name','Cm', 'Units','centimeters', Position=[5 5 10 10])
raw = {};
ranges_passive = {'N3:Q13','T3:W9'};
for IDgeno=1:2
    raw{IDgeno} = readtable(path_with_filename, 'Sheet','Passive properties', ...
        'Range',ranges_passive{IDgeno});
    
    Cm{IDgeno,:}= raw{IDgeno}.Cm;
    Rs{IDgeno,:}= raw{IDgeno}.Rs;
    Rin{IDgeno,:}= raw{IDgeno}.Rin;
   
end
for IDgeno=1:2
    mean_Cm(IDgeno,:)= mean(Cm{IDgeno},1)
    std_Cm(IDgeno,:)= std(Cm{IDgeno},0,1)
    sem_Cm(IDgeno,:)= std_Cm(IDgeno,:)/sqrt(size(Cm{IDgeno},1))
end
b=bar (mean_Cm)
for IDgeno=1:2
    b.FaceColor = 'flat';
    b.CData(IDgeno,:)=colours{IDgeno};
end    
hold on 
errorbar([1, 2],mean_Cm, ...
        [0 0],sem_Cm,".",Color=colours{size(mean_Cm,1)});
for IDgeno=1:2
    scatter(IDgeno,Cm{IDgeno},50,[0.5 0.5 0.5],"filled")
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 3])
ylim([0 350])
%xticks([1:(length(mean_slope_across_cells)+1)])
xticks([1:2])
xticklabels(genotypes)
box off
ylabel('Cm (pF)','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
figure('Name','Rs', 'Units','centimeters', Position=[5 5 10 10])
for IDgeno=1:2
    mean_Rs(IDgeno,:)= mean(Rs{IDgeno},1)
    std_Rs(IDgeno,:)= std(Rs{IDgeno},0,1)
    sem_Rs(IDgeno,:)= std_Rs(IDgeno,:)/sqrt(size(Rs{IDgeno},1))
end
b=bar (mean_Rs)
for IDgeno=1:2
    b.FaceColor = 'flat';
    b.CData(IDgeno,:)=colours{IDgeno};
end 
hold on 
errorbar([1, 2],mean_Rs, ...
        [0 0],sem_Rs,".",Color=colours{size(mean_Rs,1)});
for IDgeno=1:2
    scatter(IDgeno,Rs{IDgeno},50,[0.5 0.5 0.5],"filled")
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 3])
ylim([0 20])
%xticks([1:(length(mean_slope_across_cells)+1)])
xticks([1:2])
xticklabels(genotypes)
box off
ylabel('Rs (M\Omega)','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')
figure('Name','Rin', 'Units','centimeters', Position=[5 5 10 10])
for IDgeno=1:2
    mean_Rin(IDgeno,:)= mean(Rin{IDgeno},1)
    std_Rin(IDgeno,:)= std(Rin{IDgeno},0,1)
    sem_Rin(IDgeno,:)= std_Rin(IDgeno,:)/sqrt(size(Rin{IDgeno},1))
end
b=bar (mean_Rin)
for IDgeno=1:2
    b.FaceColor = 'flat';
    b.CData(IDgeno,:)=colours{IDgeno};
end 
hold on 
errorbar([1, 2],mean_Rin, ...
        [0 0],sem_Rin,".",Color=colours{size(mean_Rin,1)});
for IDgeno=1:2
    scatter(IDgeno,Rin{IDgeno},50,[0.5 0.5 0.5],"filled")
end
%xlim([0 (length(mean_slope_across_cells)+1)])
xlim([0 3])
ylim([0 250])
%xticks([1:(length(mean_slope_across_cells)+1)])
xticks([1:2])
xticklabels(genotypes)
box off
ylabel('Rin (M\Omega)','FontSize',12,'FontName','Times')
set(gca, "TickDir","out")
set(gca, "FontSize",12)
set(gca, "FontName",'Times')