clear all
close all
clc

%% 


[pathstr,name,ext] = fileparts(pwd);
usedir = pathstr;
codedir = pwd;
maindir = fullfile(usedir,'bids','sourcedata','Scan-Lets_Make_A_Deal')

sublist = fullfile(codedir,'sublist_test.txt');

subjects = table2array(readtable(sublist));

for ii = 1:length(subjects)

    try

        subj = subjects(ii)

        for r = 0:1


            % sub-101_task-ultimatum_run-0_raw.csv sub-102_task-ultimatum_run-1_raw.csv
            fname = fullfile(maindir,'logs',num2str(subj),sprintf('sub-%04d_task-ultimatum_run-%01d_raw.csv',subj,r)); % Psychopy taken out from Logs to make work for now.
            if exist(fname,'file')
                fid = fopen(fname,'r');
            else
                fprintf('sub-%d -- Let''s Make a Deal Game, Run %d: No data found.\n', subj, r+1)
                continue;
            end
            C = textscan(fid,repmat('%f',1,23),'Delimiter',',','HeaderLines',1,'EmptyValue', NaN);
            fclose(fid);


            % "Feedback" is the offer value

            decision_onset = C{16};
            endowment_onset = C{12};
            endowment_offset = C{13};
            onset = C{11};
            RT = C{18};
            duration = C{21};
            % test
            Block = C{3};
            Block = round(Block);
            Endowment = C{4};
            response = C{17};
            response = round(response);
            L_Option = C{7};
            R_Option = C{8};
            L_Option = round(L_Option);
            R_Option = round(R_Option);

            fname = sprintf('sub-%03d_task-ugr_run-%01d_events.tsv',subj,r+1); % making compatible with bids output
            output = fullfile(usedir,'bids',['sub-' num2str(subj)],'func');
            if ~exist(output,'dir')
                mkdir(output)
            end
            myfile = fullfile(output,fname);
            fid = fopen(myfile,'w');
            fprintf(fid,'onset\tduration\ttrial_type\tresponse_time\tEndowment\tEndowment_pmod\tDecision\tDecision_pmod\tOffer_pmod\n');


            % We need to split up the endowments per the blocks. Then take the
            % mean of those blocks. We do this to generate the parametric
            % regressors, which require the demeaned endowment.

            Block2Mean = [];
            Block3Mean = [];

            for ii = 1:length(Block)

                if (Block(ii) == 2)
                    Block2Mean = [Block2Mean;Endowment(ii)];

                elseif (Block(ii) == 3)
                    Block3Mean = [Block3Mean;Endowment(ii)];

                end

            end

            Block2Mean = mean(Block2Mean);
            Block3Mean = mean(Block3Mean);

            % %% Find the means of decision per conditions.
            %
            % % Make a table that has all the offers split per condition.
            %
            % social=[];
            % nonsocial=[];
            %
            %  for t = 1:length(Block)
            %
            %         % 2 is reject
            %         % 3 is accept
            %         % 999 is miss
            %
            %         % L_option
            %         % R_Option
            %
            %         if Block(t) == 3
            %             save = [];
            %             if response(t) == 1
            %                 if round(L_Option(t)) > 0
            %                     save = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
            %                 else
            %                     save = [0, L_Option(t)/Endowment(t)];
            %                 end
            %
            %                 social= [social; save];
            %             end
            %
            %             if response(t) == 2
            %                 if round(R_Option(t)) > 0
            %                     save = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
            %                 else
            %                     save = [0, R_Option(t)/Endowment(t)];
            %                 end
            %                 social = [social; save];
            %             end
            %         end
            %
            %         if Block(t) == 2
            %             save = [];
            %             if response(t) == 1
            %                 if round(L_Option(t)) > 0
            %                     save = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
            %                 else
            %                     save = [0, L_Option(t)/Endowment(t)];
            %                 end
            %
            %                 nonsocial= [nonsocial; save];
            %             end
            %
            %             if response(t) == 2
            %                 if round(R_Option(t)) > 0
            %                     save = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
            %                 else
            %                     save = [0, R_Option(t)/Endowment(t)];
            %                 end
            %                 nonsocial = [nonsocial; save];
            %             end
            %         end
            %  end
            %
            % % Find the means
            %
            % social_mean = mean(social(:,2)); % mean proportion accepted
            % nonsocial_mean = mean(nonsocial(:,2));


            %% Find the mean of offers per conditions.

            % Make a table that has all the offers split per condition.

            social=[];
            nonsocial=[];
            social_accept=[];
            social_reject=[];
            nonsocial_accept=[];
            nonsocial_reject=[];

            for t = 1:length(Block)

                % 2 is reject
                % 3 is accept
                % 999 is miss

                % L_option
                % R_Option

                save_reject = [];
                save_accept = [];

                if Block(t) == 3
                    save = [];
                    if response(t) == 1 % If left
                        if round(L_Option(t)) > 0 % If left option has $$$ (accept)
                            save = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                            save_accept = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                        else
                            save = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)]; 
                        end

                        social= [social; save];
                        social_accept = [social_accept; save_accept];
                        
                    end

                    if response(t) == 1 % If left
                        if round(L_Option(t)) == 0 % If left option has $$$ (accept)
                            save_reject = [Endowment(t) - L_Option(t), R_Option(t)/Endowment(t)];
                        end

                        social_reject = [social_reject; save_reject];
                    end

                    if response(t) == 2
                        if round(R_Option(t)) > 0
                            save = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                            save_accept = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                        else
                            save = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                        end
                        social = [social; save];
                        social_accept = [social_accept; save_accept];

                        if round(R_Option(t)) == 0
                            save_reject = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                        end
                        social_reject = [social_reject; save_reject];

                    end
                end

                if Block(t) == 2
                    save = [];
                    if response(t) == 1
                        if round(L_Option(t)) > 0
                            save = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                            save_accept = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                        else
                            save = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                            save_reject = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                        end

                        nonsocial= [nonsocial; save];
                        nonsocial_accept = [nonsocial_accept; save_accept];

                        if round(L_Option(t)) == 0
                            save_reject = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                        end

                        nonsocial_reject = [nonsocial_reject; save_reject];
                    end

                    if response(t) == 2
                        if round(R_Option(t)) > 0
                            save = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                            save_accept = [Endowment(t) - R_Option(t), R_Option(t)/Endowment(t)];
                        else
                            save = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                        end
                        nonsocial = [nonsocial; save];
                        nonsocial_accept = [nonsocial_accept; save_accept];

                        if round(R_Option(t)) == 0
                            save_reject = [Endowment(t) - L_Option(t), L_Option(t)/Endowment(t)];
                        end
                        nonsocial_reject = [nonsocial_reject; save_reject];
                    end
                end
            end

            % Find the means

            if size(nonsocial_reject) == 0
                nonsocial_reject = [0,0]
            end

            if size(social_reject) == 0
                social_reject = [0,0]
            end

            social_mean = mean(social(:,2)); % mean proportion accepted
            nonsocial_mean = mean(nonsocial(:,2));
            accept_nonsocial_mean = mean(nonsocial_accept(:,2));
            reject_nonsocial_mean = mean(nonsocial_reject(:,2));
            accept_social_mean = mean(social_accept(:,2));
            reject_social_mean = mean(social_reject(:,2));

            choice = [social(:,2);nonsocial(:,2)]; % concatenate decisions
            choice_mean = mean(choice);

            reject = [social_reject(:,2); nonsocial_reject(:,2)];
            reject_mean = mean(reject);

            accept = [social_accept(:,2); nonsocial_accept(:,2)];
            accept_mean = mean(accept);



            %% Adding in the cue onsets for parametric model

            for t = 1:length(Block)
                if (Block(t) == 3)
                    trial_type = 'cue_social';
                    fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%s\n',onset(t),2,[trial_type],'n/a',Endowment(t),round(Endowment(t)-Block3Mean),'n/a','n/a','n/a');
                elseif (Block(t) == 2)
                    trial_type = 'cue_nonsocial';
                    fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%s\n',onset(t),2,[trial_type],'n/a',Endowment(t),round(Endowment(t)-Block2Mean),'n/a','n/a','n/a');


                else
                    keyboard
                end


                if (Block(t) == 2)
                    if Endowment(t) > 20
                        trial_type = 'cue_nonsocial_high';
                        fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%s\n',onset(t),2,[trial_type],'n/a',Endowment(t),round(Endowment(t)-Block3Mean),'n/a','n/a','n/a');
                    end
                end


                if (Block(t) == 3)
                    if Endowment(t) > 20
                        trial_type = 'cue_social_high';
                        fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%s\n',onset(t),2,[trial_type],'n/a',Endowment(t),round(Endowment(t)-Block2Mean),'n/a','n/a','n/a');
                    end
                end



                if (Block(t) == 2)
                    if Endowment(t) < 20
                        trial_type = 'cue_nonsocial_low';
                        fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%s\n',onset(t),2,[trial_type],'n/a',Endowment(t),round(Endowment(t)-Block3Mean),'n/a','n/a','n/a');
                    end
                end


                if (Block(t) == 3)
                    if Endowment(t) < 20
                        trial_type = 'cue_social_low';
                        fprintf(fid,'%f\t%d\t%s\t%s\t%d\t%d\t%s\t%s\t%s\n',onset(t),2,[trial_type],'n/a',Endowment(t),round(Endowment(t)-Block2Mean),'n/a','n/a','n/a');
                    end
                end

            end





            %% Populate the parametric regressors.

            % Block 2 = non social
            % Block 3 = social

            for t = 1:length(onset)


                if (Block(t) == 2)
                    trial_type = 'dec_nonsocial';
                    trial_type_both_non = 'dec';

                elseif (Block(t) == 3)
                    trial_type = 'dec_social';
                    trial_type_both_soc = 'dec';
                else
                    keyboard
                end

                % 1 is reject
                %2 is accept
                % 999 is miss

                % L_option
                % R_Option

                if response(t) == 999
                    fprintf(fid,'%f\t%f\t%s\t%f\t%f\t%s\t%s\t%s\t%s\n',decision_onset(t),3.7669463,'missed_trial',3.7669463, Endowment(t),'n/a','n/a','n/a','n/a');
                end



                %% Add choice only regessors


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




        fopen(fid); % Changed from fclose

    catch
        ('Debug')
    end


end



