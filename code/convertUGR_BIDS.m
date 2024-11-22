% convert UGR raw behavioral to BIDS events

% set relative directories
filePath = matlab.desktop.editor.getActiveFilename;
[codedir,name,ext] = fileparts(filePath);
[basedir,~,~] = fileparts(codedir);
maindir = fullfile(basedir,'bids','sourcedata','Scan-Lets_Make_A_Deal');

% load subject list
subjects = load(fullfile(codedir,'sublist_all.txt'));

for s = 1:length(subjects)

    for r = 0:1

        % load raw data
        indata = fullfile(maindir,'logs',num2str(subjects(s)),sprintf('sub-%04d_task-ultimatum_run-%01d_raw.csv',subjects(s),r));
        T = readtable(indata);

        decision_onset = T.decision_onset;
        endowment_onset = T.endowment_onset;
        endowment_offset = T.endowment_offset;
        onset = T.cue_Onset;
        RT = T.rt;
        duration = T.trialDuration;
        Block = T.Block;
        Endowment = T.Endowment;
        response = T.resp; % is this accept/reject? accept == 1, reject == 2?
        L_Option = T.L_Option;
        R_Option = T.R_Option;
        offer = max([L_Option R_Option],[],2); % is this the offer amount?

        % create output file
        fname = sprintf('sub-%03d_task-ugr_run-%01d_events.tsv',subj,r+1); % making compatible with bids output
        output = fullfile(basedir,'bids',['sub-' num2str(subj)],'func');
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





            % missed trials, else real trials.
            % may want to adjust onset and remove cue/endowment (subtract 2 secs from onset)
            % increase duration (add 2 secs)?
            if response(t) == 999
                fprintf(fid,'%f\t%f\t%s\t%s\t%f\t%s\t%s\n',decision_onset(t),3.7669463,'missed_trial','n/a',Endowment(t),'n/a','n/a');
            else


            end

            trial_type = 'dec_nonsocial';


            if Block(t) == 2
                if response(t) == 1
                    if round(L_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- choice_mean, L_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_choice'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- nonsocial_mean, L_Option(t)/Endowment(t)- nonsocial_mean);
                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_choice'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- nonsocial_mean);
                    end
                end

                if response(t) == 2
                    if round(R_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- choice_mean, R_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_choice'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- nonsocial_mean, R_Option(t)/Endowment(t)- nonsocial_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_choice'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- nonsocial_mean);

                    end
                end
            end

            if Block(t) == 3

                if response(t) == 1
                    if round(L_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- choice_mean, L_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_choice'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_choice'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- social_mean);

                    end
                end

                if response(t) == 2
                    if round(R_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- choice_mean, R_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_choice'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_choice'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- choice_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_choice'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- social_mean);

                    end
                end
            end

            %% Add Accept/Reject regressors


            if Block(t) == 2
                if response(t) == 1
                    if round(L_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- accept_mean, L_Option(t)/Endowment(t)- accept_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_accept'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- accept_nonsocial_mean, L_Option(t)/Endowment(t)- accept_nonsocial_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- reject_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_reject'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- reject_nonsocial_mean);

                    end
                end

                if response(t) == 2
                    if round(R_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- accept_mean, R_Option(t)/Endowment(t)- accept_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_accept'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- accept_nonsocial_mean, R_Option(t)/Endowment(t)- accept_nonsocial_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- reject_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_non '_reject'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- reject_nonsocial_mean);

                    end
                end
            end

            if Block(t) == 3

                if response(t) == 1
                    if round(L_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- accept_mean, L_Option(t)/Endowment(t)- accept_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_accept'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- accept_social_mean, L_Option(t)/Endowment(t)- accept_social_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- reject_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_reject'], RT(t), Endowment(t),'n/a',0, 0, R_Option(t)/Endowment(t)- reject_social_mean);

                    end
                end

                if response(t) == 2
                    if round(R_Option(t)) > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- accept_mean, R_Option(t)/Endowment(t)- accept_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_accept'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- accept_social_mean, R_Option(t)/Endowment(t)- accept_social_mean);

                    else
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- reject_mean);
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type_both_soc '_reject'], RT(t), Endowment(t),'n/a',0, 0, L_Option(t)/Endowment(t)- reject_social_mean);

                    end
                end
            end


            %% Add high/low regressors


            if Block(t) == 2
                if response(t) == 1

                    if L_Option(t)/Endowment(t)- nonsocial_mean > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_high'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- nonsocial_mean, L_Option(t)/Endowment(t)- nonsocial_mean);
                    end
                    if L_Option(t)/Endowment(t)- nonsocial_mean < 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_low'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- nonsocial_mean, L_Option(t)/Endowment(t)- nonsocial_mean);
                    end

                end

                if response(t) == 2
                    if round(R_Option(t)) < 0
                        if R_Option(t)/Endowment(t)- nonsocial_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_high'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- nonsocial_mean, R_Option(t)/Endowment(t)- nonsocial_mean);
                        end
                        if R_Option(t)/Endowment(t)- nonsocial_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_low'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- nonsocial_mean, R_Option(t)/Endowment(t)- nonsocial_mean);
                        end
                    end
                end
            end

            if Block(t) == 3
                if response(t) == 1

                    if L_Option(t)/Endowment(t)- social_mean > 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_high'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);
                    end
                    if L_Option(t)/Endowment(t)- social_mean < 0
                        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_low'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);
                    end

                end

                if response(t) == 2
                    if round(R_Option(t)) < 0
                        if R_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_high'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);
                        end
                        if R_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_low'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);
                        end
                    end
                end
            end



            %% Add accept/reject for high/low

            if Block(t) == 2
                if response(t) == 1 % Left option chosen
                    if round(L_Option(t)) > 0 % And the choice has $$ (accept)
                        if L_Option(t)/Endowment(t)- nonsocial_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_high'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- accept_nonsocial_mean, L_Option(t)/Endowment(t)- accept_nonsocial_mean);
                        end
                        if L_Option(t)/Endowment(t)- nonsocial_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_low'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- accept_nonsocial_mean, L_Option(t)/Endowment(t)- accept_nonsocial_mean);
                        end
                    end
                end

                if response(t) == 1 % Left option chosen
                    if round(L_Option(t)) == 0 % And the choice is 0 (reject)
                        if L_Option(t)/Endowment(t)- nonsocial_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_high'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- reject_nonsocial_mean, L_Option(t)/Endowment(t)- reject_nonsocial_mean);
                        end
                        if L_Option(t)/Endowment(t)- nonsocial_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_low'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- reject_nonsocial_mean, L_Option(t)/Endowment(t)- reject_nonsocial_mean);
                        end
                    end
                end

                if response(t) == 2 % Right option chosen
                    if round(R_Option(t)) > 0 % And has $$$ (accept)
                        if R_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_high'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- accept_social_mean, R_Option(t)/Endowment(t)- accept_social_mean);
                        end
                        if R_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_low'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- accept_social_mean, R_Option(t)/Endowment(t)- accept_social_mean);
                        end
                    end
                end

                if response(t) == 2 % Right option chosen
                    if round(R_Option(t)) == 0 % And is 0 (reject)
                        if R_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_high'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- reject_social_mean, R_Option(t)/Endowment(t)- reject_social_mean);
                        end
                        if R_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_low'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- reject_social_mean, R_Option(t)/Endowment(t)- reject_social_mean);
                        end
                    end
                end
            end

            if Block(t) == 3

                if response(t) == 1 % Left option
                    if round(L_Option(t)) > 0 % And has $$$ (accept)
                        if L_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_high'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);
                        end
                        if L_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_low'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);
                        end

                    end
                end

                if response(t) == 1 % Left option

                    if round(L_Option(t)) == 0 % And is 0 (reject)
                        if L_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_high'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);
                        end
                        if L_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_low'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, L_Option(t)/Endowment(t)- social_mean);
                        end

                    end
                end

                if response(t) == 2 % Right option
                    if round(R_Option(t)) > 0 % Has $$$ (accept)
                        if R_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_high'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);
                        end
                        if R_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_accept_low'], RT(t), Endowment(t),'n/a',R_Option(t), R_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);
                        end
                    end
                end


                if response(t) == 2 % Right option
                    if round(R_Option(t)) == 0 % No $$$ (reject)
                        if R_Option(t)/Endowment(t)- social_mean > 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_high'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);
                        end
                        if R_Option(t)/Endowment(t)- social_mean < 0
                            fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%d\t%d\t%d\n',decision_onset(t),RT(t),[trial_type '_reject_low'], RT(t), Endowment(t),'n/a',L_Option(t), L_Option(t)/Endowment(t)- social_mean, R_Option(t)/Endowment(t)- social_mean);
                        end
                    end
                end
            end

        end
    end
end