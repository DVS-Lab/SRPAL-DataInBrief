    
clear; close all;
maindir = fileparts(convert("fullpath"));
warning off all

%subs = [10317, 10369, 10402, 10418, 10462, 10478, 10486, 10529, 10541, ... 
%    10572, 10581, 10584, 10585, 10589, 10590, 10596, 10603, 10606, 10608, 10617, ...
%    10636, 10638, 10640, 10641, 10642, 10644, 10647, 10649, 10652, 10656, 10657, ...
%    10663, 10668, 10673, 10674, 10677, 10685, 10690, 10691, 10700, 10701, 10713, ...
%    10716, 10718, 10720, 10723, 10741, 10748, 10767, 10770, 10777, 10781, 10783, ...
%    10785, 10794, 10800, 10801, 10802, 10803, 10804, 10806, 10807, 10809, 10812, ...
%    10817, 10827, 10834, 10836, 10838, 10843, 10850, 10854, 10857, 10858, 10860, ...
%    10862, 10863, 10866, 10875, 10881, 10887, 10896, 10898, 10908, 10918, 10924, ...
%    10926, 10928, 10930, 10938, 10940, 10952, 10958, 10977];

subs = load("sublist_all.txt");

tasks = {'facesA1', 'facesA2','facesA3','facesA4',...
    'facesB1','facesB2','facesB3','facesB4',...
    'doorsA1','doorsA2','doorsA3','doorsA4',...
    'doorsB1','doorsB2','doorsB3','doorsB4'};
nums = {'1', '2', '3', '4'};

% loop through each sub
for s = 1:length(subs)  
    for t = 1:length(tasks)
        for n = 1:length(nums)    
            rawtask = tasks{t};
    
            % rename task
            if strcmp(rawtask,'facesA1') || strcmp(rawtask,'facesA2') || strcmp(rawtask,'facesA3') || strcmp(rawtask,'facesA4') || strcmp(rawtask,'facesB1') || strcmp(rawtask,'facesB2') ||strcmp(rawtask,'facesB3') ||strcmp(rawtask,'facesB4')
                bidstask = 'socialdoors';
            elseif strcmp(rawtask,'doorsA1') || strcmp(rawtask,'doorsA2') || strcmp(rawtask,'doorsA3') || strcmp(rawtask,'doorsA4') || strcmp(rawtask,'doorsB1') || strcmp(rawtask,'doorsB2') || strcmp(rawtask,'doorsB3') || strcmp(rawtask,'doorsB4') 
              bidstask = 'doors';
            else
            end
    
            % set file names and load in source data
            inputdir = sprintf('%s/%d', pwd, subs(s));
            inputname = sprintf('%s/sub-%d_ses-1_task-socialReward_%s_events.tsv', inputdir, subs(s), rawtask);
            sub_str=num2str(subs(s));
            bidsdir = fullfile('/ZPOOL/data/projects/rf1-sra-data/bids', ['sub-',sub_str], 'func');
            bidsname = sprintf('%s/sub-%d_task-%s_run-1_part-mag_events.tsv', bidsdir, subs(s), bidstask);

            % confirm file exists & rename file
            if isfile(inputname)
                T = readtable(inputname,'FileType','delimitedtext');
    
                %replace NaN with proper BIDS naming
                %T.rt(isnan(T.rt)) = 'n/a'
    
                writetable(T,bidsname,'FileType','text','Delimiter','\t')
            else
            end
        end
    end
end
