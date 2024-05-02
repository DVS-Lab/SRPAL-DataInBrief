% Designate Paths
[pathstr, ~, ~] = fileparts(pwd);
usedir = pathstr;
codedir = pwd;
rawdata = fullfile(usedir, 'bids', 'sourcedata', 'Scan-Investment_Game', 'logs');

sublist_file = fullfile(codedir, 'sublist_all.txt');
subjects = table2array(readtable(sublist_file));

for ii = 1:length(subjects)

    try

        subj = subjects(ii);

        for r = 0:1

            fname = fullfile(rawdata, num2str(subj), sprintf('sub-%03d_task-trust_run-%d_raw.csv', subj, r));
            if exist(fname, 'file')
                disp("First checkpoint");
                fid = fopen(fname, 'r');
            else
                fprintf('sub-%d -- Investment Game, Run %d: No data found.\n', subj, r+1);
                continue;
            end

            % Read the data using readtable
            T = readtable(fname, 'Delimiter', ',');
            fclose(fid);

            % Extract the columns you need using column names
            outcomeonset = T.outcome_onset;
            choiceonset = T.onset;
            RT = T.rt;
            Partner = T.Partner;
            reciprocate = T.Reciprocate;
            response = T.highlow;
            trust_val = T.resp;
            cLeft = T.cLeft;
            cRight = T.cRight;
            options = [cLeft, cRight];

            output = fullfile(usedir, 'bids', ['sub-' num2str(subj)], 'func');
            disp(output);
            if ~exist(output, 'dir')
                disp("Second checkpoint");
                mkdir(output)
            end
            fname = sprintf('sub-%03d_task-trust_run-%01d_events.tsv', subj, r+1);
            fid = fopen(fullfile(output, fname), 'w');
            fprintf(fid, 'onset\tduration\ttrial_type\tresponse_time\ttrust_value\tchoice\tcLow\tcHigh\n');

            for t = 1:length(choiceonset)

                % Output check
                if trust_val(t) == 999
                    if strcmp(response{t}, 'high') && (max(options(t, :)) ~= trust_val(t))
                        error('response output incorrectly recorded for trial %d', t)
                    end
                end

                if Partner(t) == 1
                    trial_type = 'computer';
                elseif Partner(t) == 2
                    trial_type = 'stranger';
                elseif Partner(t) == 3
                    trial_type = 'friend';
                end

                % Output format
                if trust_val(t) == 999
                    fprintf(fid, '%f\t%f\t%s\t%f\t%s\t%s\t%d\t%d\n', choiceonset(t), 3, 'missed_trial', 3, 'n/a', 'n/a', min(options(t, :)), max(options(t, :)));
                else
                    if trust_val(t) == 0
                        fprintf(fid, '%f\t%f\t%s\t%f\t%d\t%s\t%d\t%d\n', choiceonset(t), RT(t), ['choice_' trial_type], RT(t), 0, response{t}, min(options(t, :)), max(options(t, :))); %should always be 'low'
                    else
                        if reciprocate(t) == 1
                            fprintf(fid, '%f\t%f\t%s\t%f\t%d\t%s\t%d\t%d\n', choiceonset(t), RT(t), ['choice_' trial_type], RT(t), trust_val(t), response{t}, min(options(t, :)), max(options(t, :)));
                            fprintf(fid, '%f\t%f\t%s\t%f\t%d\t%s\t%d\t%d\n', outcomeonset(t), 1, ['outcome_' trial_type '_recip'], RT(t), trust_val(t), response{t}, min(options(t, :)), max(options(t, :)));
                        else
                            fprintf(fid, '%f\t%f\t%s\t%f\t%d\t%s\t%d\t%d\n', choiceonset(t), RT(t), ['choice_' trial_type], RT(t), trust_val(t), response{t}, min(options(t, :)), max(options(t, :)));
                            fprintf(fid, '%f\t%f\t%s\t%f\t%d\t%s\t%d\t%d\n', outcomeonset(t), 1, ['outcome_' trial_type '_defect'], RT(t), trust_val(t), response{t}, min(options(t, :)), max(options(t, :)));
                        end
                    end
                end
            end
            fclose(fid);
        end
    end
end
