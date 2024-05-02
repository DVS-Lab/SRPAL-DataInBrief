###RF1-SRA
###shared reward, event related

from psychopy import visual, core, event, gui, data, sound, logging
import csv
import datetime
import random
import numpy
import os

#maindir = os.getcwd()


#parameters
useFullScreen = True
useDualScreen=2
DEBUG = False

frame_rate=1
instruct_dur=3
initial_fixation_dur = 4
#final_fixation_dur = 2
decision_dur=2.8
outcome_dur=0.6

responseKeys=('1','2','z')

#get subjID
subjDlg=gui.Dlg(title="Shared Reward Task")
subjDlg.addField('Enter Subject ID: ')
subjDlg.addField('Enter Friend Name: ') #1
subjDlg.addField('Enter Stranger Name: ')#NOTE: PARTNER IS THE CONFEDERATE/STRANGER #2
subjDlg.addField('Age:', choices=['18-39','40-64','65+'])
subjDlg.addField('Run:', choices=['1', '2'])
subjDlg.show()

if gui.OK:
    subj_id=subjDlg.data[0]
    friend_id=subjDlg.data[1]
    stranger_id=subjDlg.data[2]
    subj_age=subjDlg.data[3]
    run = subjDlg.data[4]

else:
    sys.exit()

run_data = {
    'Participant ID': subj_id,
    'Date': str(datetime.datetime.now()),
    'Description': 'RF1 - SharedReward Task'
    }

#window setup
win = visual.Window([800,600], monitor="testMonitor", units="deg", fullscr=useFullScreen, allowGUI=False, screen=useDualScreen)

#checkpoint
print("got to check 1")

#define stimulus
fixation = visual.TextStim(win, text="+", height=2)

#waiting for trigger
ready_screen = visual.TextStim(win, text="Please wait for the round to begin. \n\nRemember to keep your head still!", height=1.5)

#decision screen
nameStim = visual.TextStim(win=win,font='Arial',pos=(0, 5.5), height=1, color='white', colorSpace='rgb', opacity=1,depth=-1.0);
cardStim = visual.Rect(win=win, name='polygon', width=(7.0,7.0)[0], height=(9.0,9.0)[1], ori=0, pos=(0, 0),lineWidth=5, lineColor=[1,1,1], lineColorSpace='rgb',fillColor=[0,0,0], fillColorSpace='rgb',opacity=1, depth=0.0, interpolate=True)
question = visual.TextStim(win=win, name='text',text='?',font='Arial',pos=(0, 0), height=1, wrapWidth=None, ori=0, color='white', colorSpace='rgb', opacity=1,depth=-1.0);
#set scale for max image height (con't in for loop that sets path for var 'image')
scale = 6.65
pictureStim = visual.ImageStim(win, pos=(0,9.5))

#outcome screen
outcome_cardStim = visual.Rect(win=win, name='polygon', width=(7.0,7.0)[0], height=(9.0,9.0)[1], ori=0, pos=(0, 0),lineWidth=5, lineColor=[1,1,1], lineColorSpace='rgb',fillColor=[0,0,0], fillColorSpace='rgb',opacity=1, depth=0.0, interpolate=True)
outcome_text = visual.TextStim(win=win, name='text',text='',font='Arial',pos=(0, 0), height=2, wrapWidth=None, ori=0, color='white', colorSpace='rgb', opacity=1,depth=-1.0);
outcome_money = visual.TextStim(win=win, name='text',text='',font='Wingdings',pos=(0, 2.0), height=2, wrapWidth=None, ori=0, colorSpace='rgb', opacity=1,depth=-1.0);

#instructions
instruct_screen = visual.TextStim(win, text='Welcome to the Card Guessing Game!\n\nIn this game you will be guessing the numerical value of a card.\n\nPress the blue button (index finger) to guess lower than 5.\nPress the yellow button (middle finger) to guess higher than 5.\n\nIf you guess correctly, you gain $20.\n If you guess incorrectly, you will lose $10.\n\nRemember, you will be sharing half of the monetary outcome on each trial with the partner displayed at the top of the screen.', pos = (0,1), wrapWidth=20, height = 1.0)
#instruct_screen2 = visual.TextStim(win, text='Press Button 2 to send the amount on the lower left of the screen and press Button 3 to send the amount on the lower right of the screen.\n\n Remember, whatever you send means your partner receives 3 times that amount; your partner will be notified of your decision.\n\n If you sent money s/he will choose to share it back evenly with you or keep it all for him/herself.', pos = (0,1), wrapWidth=20, height = 1.2)

#Loading screen

#loading_screen = visual.TextStim(win, text='... Selecting past participant, please wait ...', pos = (0,1), wrapWidth=30, height = 1.0)

#exit
exit_screen = visual.TextStim(win, text='Thanks for playing! Please wait for instructions from the experimenter.', pos = (0,1), wrapWidth=20, height = 1.2)

#logging
expdir = os.getcwd()
subjdir = '%s/logs/%s' % (expdir, subj_id)
if not os.path.exists(subjdir):
    os.makedirs(subjdir)
log_file = os.path.join(f'sub-{subj_id}_task-sharedreward_run-{run}_raw.csv')

globalClock = core.Clock()
logging.setDefaultClock(globalClock)

timer = core.Clock()

#trial handler
trial_data = [r for r in csv.DictReader(open('event-related/params/sub-' + subj_id + '/sub-'
   + subj_id + '_run-' + run + '_design.csv','rU'))]

trials_run = data.TrialHandler(trial_data[:], 1, method="sequential") #change to [] for full run

#trial_data_1 = [r for r in csv.DictReader(open('event-related/params/sub-' + subj_id + '/sub-'
#    + subj_id + '_run-1_design.csv','rU'))]
#trial_data_2  = [r for r in csv.DictReader(open('event-related/params/sub-' + subj_id + '/sub-'
#    + subj_id + '_run-2_design.csv','rU'))]

#trial_data = [r for r in csv.DictReader(open('SharedReward_design.csv','rU'))]
#trials = data.TrialHandler(trial_data[:], 1, method="sequential") #change to [] for full run

#trials_run1 = data.TrialHandler(trial_data_1[:], 1, method="sequential") #change to [] for full run
#trials_run2 = data.TrialHandler(trial_data_2[:], 1, method="sequential") #change to [] for full run

#set partner names
# 3 = friend, 2 = confederate, 1 = computer
# change names accordingly here

stim_map = {
  '3': friend_id,
  '2': stranger_id,
  '1': 'Computer',
  }

image_map = {
  '3': 'friend',
  '2': 'stranger',
  '1': 'computer',
}

outcome_map = {
  '3': 'reward',
  '2': 'neutral',
  '1': 'punish',
  }

if subj_age == '18-39':
        agerange = 1
elif subj_age =='40-64':
        agerange = 2
else:
        agerange = 3

#checkpoint
print("got to check 2")

'''
runs=[]
for run in range(1):
    run_data = []
    for t in range(8):
        sample = random.sample(range(len(trial_data)),1)[0]
        run_data.append(trial_data.pop(sample))
    runs.append(run_data)
'''

# Instructions
instruct_screen.draw()
win.flip()
event.waitKeys(keyList=('1'))

#loading_screen.draw()
win.flip()
core.wait(3)

#instruct_screen2.draw()
#win.flip()
#event.waitKeys(keyList=('space'))

# main task loop
def do_run(run, trials):
    resp=[]
    fileName=log_file.format(subj_id,run)

    #wait for trigger
    ready_screen.draw()
    win.flip()
    event.waitKeys(keyList=('equal'))
    globalClock.reset()
    studyStart = globalClock.getTime()
    trials.addData('studyStart',studyStart)

    #Initial Fixation screen
    fixation.draw()
    win.flip()
    initial_fixation_Onset = globalClock.getTime()
    trials.addData('InitFixOnset',initial_fixation_Onset)
    core.wait(initial_fixation_dur)



    for trial in trials:
        condition_label = stim_map[trial['Partner']]
        image_label = image_map[trial['Partner']]
        imagepath = os.path.join(expdir,'../Images')
        if image_label == 'stranger':
            image = os.path.join(imagepath, 'SR_%s_%s.jpg') %(stranger_id,agerange)
        else:
            image = os.path.join(imagepath, '%s.png') % image_label
        nameStim.setText(condition_label)
        pictureStim.setImage(image)
        #retain image proportions while scaling them to within maximum height - Ori Z 7.20.22
        pictureStim.size *=scale / max(pictureStim.size)


        #decision phase
        timer.reset()
        event.clearEvents()

        resp=[]
        resp_val=None
        resp_onset=None

        decision_onset = globalClock.getTime()
        trials.addData('decision_onset',decision_onset)


        while timer.getTime() < decision_dur:
            cardStim.draw()
            question.draw()
            pictureStim.draw()
            nameStim.draw()
            win.flip()

            resp = event.getKeys(keyList = responseKeys)

            if len(resp)>0:
                if resp[0] == 'z':
                #trials.saveAsText(fileName=log_file.format(subj_id),delim=',',dataOut='all_raw')
                    os.chdir(subjdir)
                    trials.saveAsWideText(fileName)
                    os.chdir(expdir)
                    win.close()
                    core.quit()
                resp_val = int(resp[0])
                if resp_val==1:
                    #resp_onset = globalClock.getTime()
                    question.setColor('darkorange')
                    #rt = resp_onset - decision_onset
                    #core.wait(decision_dur - rt)
                if resp_val==2:
                    #resp_onset = globalClock.getTime()
                    question.setColor('darkorange')
                    #rt = resp_onset - decision_onset
                    #core.wait(decision_dur -rt)
                cardStim.draw()
                question.draw()
                #pictureStim.draw()
                #nameStim.draw()
                win.flip()
                resp_onset = globalClock.getTime()
                rt = resp_onset - decision_onset
                core.wait(0.1)
                break
            else:
                resp_val = 0
                #resp_onset = 999
                resp_onset = globalClock.getTime()
                #rt = 0
                rt = resp_onset - decision_onset
                core.wait(0.1)

        trials.addData('resp', int(resp_val))
        trials.addData('resp_onset', resp_onset)
        trials.addData('rt', rt)

        ###reset question mark color
        question.setColor('white')


        #ISI
        timer.reset()

        given_ISI = float(trial['ISI'])
        isi_for_trial = float(given_ISI+(2.8-(rt+0.1)))
        ISI_onset = globalClock.getTime()
        trials.addData('ISI_onset', ISI_onset)
        trials.addData('isi_for_trial', isi_for_trial)

        fixation.draw()
        win.flip()
        core.wait(isi_for_trial)

        ISI_offset = globalClock.getTime()
        trials.addData('ISI_offset', ISI_offset)



        #outcome phase
        timer.reset()
        #win.flip()
        outcome_onset = globalClock.getTime()

        while timer.getTime() < outcome_dur:
            outcome_cardStim.draw()
            #pictureStim.draw()
            #nameStim.draw()
            #win.flip()

            if trial['Feedback'] == '3' and resp_val == 1:
                outcome_txt = int(random.randint(1,4))
                outcome_moneyTxt= 'þ'
                outcome_color='lime'
                trials.addData('outcome_val', int(outcome_txt))
            elif trial['Feedback'] == '3' and resp_val == 2:
                outcome_txt = int(random.randint(6,9))
                outcome_moneyTxt= 'þ'
                outcome_color='lime'
                trials.addData('outcome_val', int(outcome_txt))
            elif trial['Feedback'] == '2' and resp_val == 1:
                outcome_txt = int(5)
                outcome_moneyTxt= 'ó'
                outcome_color='white'
                trials.addData('outcome_val', int(outcome_txt))
            elif trial['Feedback'] == '2' and resp_val == 2:
                outcome_txt = int(5)
                outcome_moneyTxt= 'ó'
                outcome_color='white'
                trials.addData('outcome_val', int(outcome_txt))
            elif trial['Feedback'] == '1' and resp_val == 1:
                outcome_txt = int(random.randint(6,9))
                outcome_moneyTxt= 'x'
                outcome_color='darkred'
                trials.addData('outcome_val', int(outcome_txt))
            elif trial['Feedback'] == '1' and resp_val == 2:
                outcome_txt = int (random.randint(1,4))
                outcome_moneyTxt= 'x'
                outcome_color='darkred'
                trials.addData('outcome_val', int(outcome_txt))
            elif resp_val == 0:
                outcome_txt='#'
                outcome_moneyTxt = ''
                outcome_color='white'
                outcome_value='999'
                trials.addData('outcome_val',int(outcome_value))


            outcome_text.setText(outcome_txt)
            outcome_money.setText(outcome_moneyTxt)
            outcome_money.setColor(outcome_color)
            outcome_text.draw()
            outcome_money.draw()
            win.flip()
            core.wait(outcome_dur)
            #trials.addData('outcome_val', outcome_txt)
            trials.addData('outcome_onset', outcome_onset)

            outcome_offset = globalClock.getTime()
            trials.addData('outcome_offset', outcome_offset)

            duration = outcome_offset - decision_onset
            trials.addData('trialDuration', duration)

            event.clearEvents()
        print("got to check 3")


        #ITI
        logging.log(level=logging.DATA, msg='ITI') #send fixation log event
        timer.reset()
        ITI_onset = globalClock.getTime()
        iti_for_trial = float(trial['ITI'])
        fixation.draw()
        win.flip()
        core.wait(iti_for_trial)
        ITI_offset = globalClock.getTime()
        trials.addData('ITIonset', ITI_onset)
        trials.addData('ITIoffset', ITI_offset)

    #Final Fixation screen after trials completed
    fixation.draw()
    win.flip()
    expected_dur = 404
    buffer_dur = 8
    total_dur = expected_dur + buffer_dur
    if globalClock.getTime() < total_dur:
        endTime = (total_dur - globalClock.getTime())
    else:
        endTime = buffer_dur
    core.wait(endTime)
    final_fixation_offset = globalClock.getTime()
    trials.addData('final_fix_offset', final_fixation_offset)

    os.chdir(subjdir)
    trials.saveAsWideText(fileName)
    os.chdir(expdir)

    #endTime = 0.01 # not sure if this will take a 0, so giving it 0.01 and making sure it is defined


for run, trials in enumerate([trials_run]):
    do_run(run, trials)

# Exit
exit_screen.draw()
win.flip()
event.waitKeys()
