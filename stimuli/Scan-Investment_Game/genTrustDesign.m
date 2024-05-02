function genTrustDesign(s)

% so clunky: set up relative paths to ensure this works on any computer.
% warning: all paths are references based on the location of this file. if
% you move the file, you break the paths.

for ii = 1:length(s)
    sub = s(ii);
    
    scriptname = pwd
    [scriptdir,~,~] = fileparts(scriptname);
    
    outfiles = fullfile(scriptdir,'Scan-Investment_Game','params');
    mkdir(outfiles);
    
    subout = fullfile(outfiles,sprintf('sub-%03d',sub));
    mkdir(subout);
    for r = 1:2
        
        TR=1.615;
        ntrials = 42;
        choice_dur = 3.0;
        outcome = 0.8;
        ISI_list = [repmat(2,1,23) repmat(3.5,1,15) repmat(5,1,4)];
        ISI_list = ISI_list(randperm(length(ISI_list)));
        ISI_list = ISI_list - 1.5; %shaving 1.5 seconds to account for "WAITING" screen
        %ITI_list = [repmat(1.5,1,25) repmat(3,1,10) repmat(4.5,1,5) repmat(7,1,2)];
        ITI_list = [repmat(TR,1,21) repmat(TR*2,1,11) repmat(TR*3,1,5) repmat(TR*4,1,2) repmat(TR*5,1,2) TR*6];
        ITI_list = ITI_list(randperm(length(ITI_list))) - TR/2; %reduce time;
        
        
        % initial_fixation_dur = 4;
        % final_fixation_dur = 8; % not currently defined in code
        % totalseconds = (choice_dur*ntrials + outcome*ntrials + sum(ITI_list) + sum(ISI_list) + initial_fixation_dur + final_fixation_dur)
        % minutes = totalseconds / 60
        % measurements = totalseconds/TR
        
        
        
        choice_pairs = combnk([0 2 4 8],2);
        choice_pairs = [choice_pairs; 2 8];
        trial_mat = [choice_pairs ones(7,1)*3 ones(7,1);
            choice_pairs ones(7,1)*3 zeros(7,1);
            choice_pairs ones(7,1)*2 ones(7,1);
            choice_pairs ones(7,1)*2 zeros(7,1);
            choice_pairs ones(7,1)*1 ones(7,1);
            choice_pairs ones(7,1)*1 zeros(7,1)];
        
        fname = fullfile(subout,sprintf('sub-%03d_run-%02d_design.csv',sub,r));
        
        fid = fopen(fname,'w');
        fprintf(fid,'Trial,cLeft,cRight,Partner,Reciprocate,ISI,ITI\n');
        % Partner is Friend=3, Stranger=2, Computer=1
        % Reciprocate is Yes=1, No=0
        % cLeft is the left option
        % cRight is the right option
        % high/low value option will randomly flip between left/right
        
        rand_trials = randperm(ntrials);
        for i = 1:ntrials
            if rand < .5
                fprintf(fid,'%d,%d,%d,%d,%d,%d,%d\n',i,trial_mat(rand_trials(i),1),trial_mat(rand_trials(i),2),trial_mat(rand_trials(i),3:4),ISI_list(rand_trials(i)),ITI_list(rand_trials(i)));
            else
                fprintf(fid,'%d,%d,%d,%d,%d,%d,%d\n',i,trial_mat(rand_trials(i),2),trial_mat(rand_trials(i),1),trial_mat(rand_trials(i),3:4),ISI_list(rand_trials(i)),ITI_list(rand_trials(i)));
            end
        end
        fclose(fid);
    end
end
