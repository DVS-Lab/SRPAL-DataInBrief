function genSharedRewardDesign(s)

% so clunky: set up relative paths to ensure this works on any computer.
% warning: all paths are references based on the location of this file. if
% you move the file, you break the paths.

for ii = 1:length(s)
    sub = s(ii);
    
    scriptname = pwd
    disp(scriptname)
    [scriptdir,~,~] = fileparts(scriptname);
    
    disp(scriptdir)
    outfiles = fullfile(scriptdir,'event-related','params');
    mkdir(outfiles);
    
    subout = fullfile(outfiles,sprintf('sub-%04d',sub));
    mkdir(subout);
    
    %{

trials per run: 54
length of a trial: 5.1

trial sequence              seconds
decision phase with face	2.8	max (remaining goes into ISI)
ISI                         1.7	mean
outcome                     0.6
total                       5.1


evt1	computer_loss       8
evt2	computer_neutral	2
evt3	computer_win        8
evt4	stranger_loss       8
evt5	stranger_neutral	5
evt6	stranger_win        8
evt7	friend_loss         8
evt8	friend_neutral      2
evt9	friend_win          8


    %}
    
    
    runs = 2;
    ntrials = 54;
    TR=1.615;
    
    trial_types = [repmat([1 3 4 6 7 9],1,8) repmat([2 5 8],1,2)];
    ISI_distribution = repmat([TR/2 TR TR*1.5],1,18);
    ISI_distribution = ISI_distribution(randperm(length(ISI_distribution)));
    ITI_distribution = [repmat(TR,1,27) repmat(TR*2,1,13) repmat(TR*3,1,7) repmat(TR*4,1,4) repmat(TR*5,1,2) TR*6];
    ITI_distribution = ITI_distribution(randperm(length(ITI_distribution))) - TR/2; %reduce time
    
    % % timing information for testing
    % decision_phase = 2.8; % doesn't match current code as of 12/17/2022 (decision_dur=2.5)
    % outcome = 0.6; % doesn't match current code as of 12/17/2022 (outcome_dur=1)
    % initial_fixation_dur = 4;
    % final_fixation_dur = 8; % not currently defined in code
    % totalseconds = (decision_phase*ntrials + outcome*ntrials + sum(ITI_distribution) + sum(ISI_distribution) + initial_fixation_dur + final_fixation_dur)
    % minutes = totalseconds / 60
    % measurements = totalseconds/TR
    
    for r = 1:runs
        
        rand_trials = randperm(ntrials);
        fname = fullfile(subout,sprintf('sub-%04d_run-%d_design.csv',sub,r));
        fid = fopen(fname,'w');
        fprintf(fid,'Trialn,TrialType,Partner,Feedback,ITI,ISI\n');
        for t = 1:ntrials
            tt = rand_trials(t);
            switch trial_types(tt)
                case 1 %Computer Punishment
                    partner = 1;
                    feedback_mat = 1;
                case 2 %Computer neutral
                    partner = 1;
                    feedback_mat = 2;
                case 3 %Computer Reward
                    partner = 1;
                    feedback_mat = 3;
                case 4 %Stranger Punishment
                    partner = 2;
                    feedback_mat = 1;
                case 5 %Stranger Neutral
                    partner = 2;
                    feedback_mat = 2;
                case 6 %Stranger Reward
                    partner = 2;
                    feedback_mat = 3;
                case 7 %Friend Punishment
                    partner = 3;
                    feedback_mat = 1;
                case 8 %Friend Neutral
                    partner = 3;
                    feedback_mat = 2;
                case 9 %Friend Reward
                    partner = 3;
                    feedback_mat = 3;
            end
            fprintf(fid,'%d,%d,%d,%d,%d,%d\n',t,trial_types(tt),partner,feedback_mat,ITI_distribution(tt),ISI_distribution(tt));
        end
        fclose(fid);
    end
end
