% convert UGR raw behavioral to BIDS events

% set relative directories
filePath = matlab.desktop.editor.getActiveFilename;
[codedir,name,ext] = fileparts(filePath);
[basedir,~,~] = fileparts(codedir);
maindir = fullfile(basedir,'bids','sourcedata','Scan-Lets_Make_A_Deal');

% load subject list and loop through subs
subjects = load(fullfile(codedir,'sublist_all.txt'));
for s = 1:length(subjects)
    for r = 0:1

        % load raw data
        indata = fullfile(maindir,'logs',num2str(subjects(s)),sprintf('sub-%04d_task-ultimatum_run-%01d_raw.csv',subjects(s),r));
        if ~exist(indata,'file')
            disp(['missing: ' indata])
            continue
        end
        T = readtable(indata);
        decision_onset = T.decision_onset;
        endowment_onset = T.endowment_onset;
        endowment_offset = T.endowment_offset;
        onset = T.cue_Onset;
        RT = T.rt;
        duration = T.trialDuration;
        Block = T.Block;
        Endowment = T.Endowment;
        response = T.resp; % 1 == left, 2 == right
        L_Option = T.L_Option;
        R_Option = T.R_Option;
        offer = max([L_Option R_Option],[],2); % this is the offer amount
        if isa(decision_onset,'cell')
            disp(['cell array detected, incomplete data: ' indata])
            continue
        end

        % create output file
        fname = sprintf('sub-%03d_task-ugr_run-%01d_events.tsv',subjects(s),r+1); % making compatible with bids output
        output = fullfile(basedir,'bids',['sub-' num2str(subjects(s))],'func');
        if ~exist(output,'dir')
            mkdir(output)
        end
        myfile = fullfile(output,fname);
        fid = fopen(myfile,'w');
        fprintf(fid,'onset\tduration\ttrial_type\tresponse_time\tEndowment\tDecision\tOffer\n');

        for t = 1:length(Block)

            % cue and endowment phase
            if Block(t) == 3
                trial_type = 'cue_social';
                fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%s\t%s\n',onset(t),2,trial_type,'n/a',Endowment(t),'n/a','n/a');
                if Endowment(t) > 20
                    fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%s\t%s\n',onset(t),2,[trial_type '_high'],'n/a',Endowment(t),'n/a','n/a');
                else
                    fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%s\t%s\n',onset(t),2,[trial_type '_low'],'n/a',Endowment(t),'n/a','n/a');
                end
            elseif Block(t) == 2
                trial_type = 'cue_nonsocial';
                fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%s\t%s\n',onset(t),2,trial_type,'n/a',Endowment(t),'n/a','n/a');
                if Endowment(t) > 20
                    fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%s\t%s\n',onset(t),2,[trial_type '_high'],'n/a',Endowment(t),'n/a','n/a');
                else
                    fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%s\t%s\n',onset(t),2,[trial_type '_low'],'n/a',Endowment(t),'n/a','n/a');
                end
            end

            % decision phase: missed trials, else real trials.
            % may want to adjust onset and remove cue/endowment (subtract 2 secs from onset)
            % increase duration (add 2 secs)?
            if response(t) == 999
                fprintf(fid,'%f\t%f\t%s\t%s\t%f\t%s\t%s\n',decision_onset(t),3.7669463,'missed_trial','n/a',Endowment(t),'n/a','n/a');
            else
                % create trial_type variable
                if Block(t) == 3 && Endowment(t) > 20
                    trial_type = 'dec_social_high';
                elseif Block(t) == 3 && Endowment(t) < 20
                    trial_type = 'dec_social_low';
                elseif Block(t) == 2 && Endowment(t) > 20
                    trial_type = 'dec_nonsocial_high';
                elseif Block(t) == 2 && Endowment(t) < 20
                    trial_type = 'dec_nonsocial_low';
                end

                % ignore choice
                fprintf(fid,'%f\t%f\t%s\t%f\t%d\t%s\t%d\n',decision_onset(t),RT(t),trial_type,RT(t),Endowment(t),'n/a',offer(t));

                % split by choice
                if (response(t) == 1 && L_Option(t) > 0) || (response(t) == 2 && R_Option(t) > 0) % money on the left and chose left or money on the right and chose right
                    fprintf(fid,'%f\t%f\t%s\t%f\t%d\t%s\t%d\n',decision_onset(t),RT(t),[trial_type '_accept'],RT(t),Endowment(t),'accept',offer(t));
                else
                    fprintf(fid,'%f\t%f\t%s\t%f\t%d\t%s\t%d\n',decision_onset(t),RT(t),[trial_type '_reject'],RT(t),Endowment(t),'reject',offer(t));
                end
            end
        end
        fclose(fid);
    end
end