clear; close all;
[pathstr,name,ext] = fileparts(pwd);
usedir = pathstr;
maindir = pwd;
input_file_path = fullfile(usedir,'bids','sourcedata','Scan-Social_Doors','data');
warning off all

subs = load('sublist_test.txt');

tasks = {'facesA1', 'facesA2','facesA3','facesA4',...
    'facesB1','facesB2','facesB3','facesB4',...
    'doorsA1','doorsA2','doorsA3','doorsA4',...
    'doorsB1','doorsB2','doorsB3','doorsB4'};
nums = {'1', '2', '3', '4'};

% loop through each sub
for s = 1:length(subs)
    disp(["Now converting",subs(s),"events to BIDS format"]);
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
            inputdir = sprintf('%s/%d', input_file_path, subs(s));
            inputname = sprintf('%s/sub-%d_ses-1_task-socialReward_%s_events.tsv', inputdir, subs(s), rawtask);
            sub_str=num2str(subs(s));
            bidsdir = fullfile('..', 'bids', ['sub-',sub_str], 'func');
            bidsname = sprintf('%s/sub-%d_task-%s_run-1_events.tsv', bidsdir, subs(s), bidstask);

            % confirm file exists & rename file
            if isfile(inputname)
            % 
            %     % replace NaN with proper BIDS naming
                  T = readtable(inputname,'FileType','delimitedtext');
            %     % nan_T = isnan(T);
            %     % T(nan_T) = {'n/a'};
            % 
                disp(["writing", bidsname]);
                writetable(T,bidsname,'FileType','text','Delimiter','\t')
             else
            end
        end
    end
end
