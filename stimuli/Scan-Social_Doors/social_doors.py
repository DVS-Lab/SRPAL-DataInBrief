###socialDoors - RF1 Aging - Ori Zaff 8/23/22
from psychopy import visual, core, event, gui, data
from psychopy.visual import ShapeStim
from instructions import *
import pandas as pd
import os
import datetime
import time


#gui set up for subject id and picture order
subjDlg = gui.Dlg(title="Picture Task")
subjDlg.addField('Enter Subject ID: ')
subjDlg.addField('Type:', choices=['faces', 
                                    'doors'])
subjDlg.addField('Version:', choices=['A', 'B'])
subjDlg.addField('Age:', choices=['18-29','30-49','50-69','70-89+'])
subjDlg.show()
if subjDlg.OK == False:
    core.quit()
#store gui variables
subj_id = subjDlg.data[0]
task_type = subjDlg.data[1]
version = subjDlg.data[2]
age = subjDlg.data[3]

#parameter file for Trial, ITI, win or lose, and image and face ordering, set window, response keys
reference = pd.read_csv(('reference.csv'), header = 0)
win = visual.Window([1000,750], monitor="testMonitor", units="deg", 
                    fullscr=True, allowGUI=False, screen=2)
responseKeys=('1','2','z')

#Setting image, face, fixation, and timing. Writing instructions
fixation = visual.TextStim(win, text="+", height=2)
box = [(-.2,-.2),(-.2,.2),(.2,.2), (.2,-.2)]
x_shape_1 = [(-.15,-.15), (.15, .15)]
x_shape_2 = [(-.15,.15), (.15, -.15)]
check_mark = [(-.15,0),(-.07,-.15),(.15, .15)]
miss_stim = [ShapeStim(win, vertices=x_shape_1, lineWidth = 10, size= 7, lineColor='darkred'), ShapeStim(win, vertices=x_shape_2, lineWidth = 10, size= 7, lineColor='darkred'), ShapeStim(win, vertices=box, lineWidth = 10, size= 7, lineColor='darkred')]
hit_stim = [ShapeStim(win, vertices=check_mark, lineWidth = 10, closeShape=False, size= 7, lineColor='lime'), ShapeStim(win, vertices=box, lineWidth = 10, size= 7, lineColor='lime')]
no_resp = visual.TextStim(win, text="Please respond faster", height=1.5, wrapWidth=30)

fixation_time = 0.54
decision_time = 3.0
fb_dur = 1.0

#instruction display settings, variables are from imported instructions file
instruct_screen_image = visual.TextStim(win, text=instruction_hello_door, pos = (.5,0), wrapWidth=45, height = 1.2)
instruct_screen_face = visual.TextStim(win, text=instruction_hello_face, pos = (.5,0), wrapWidth=45, height = 1.2)

instruct_screen1_image = visual.TextStim(win, text=instruction_overview_door, pos = (0,0), wrapWidth=30, height = 1.2)
instruct_screen1_face = visual.TextStim(win, text=instruction_overview_face, pos = (0,0), wrapWidth=30, height = 1.2)

ready_screen = visual.TextStim(win, text=ready_screen, height=1.5, wrapWidth=30)
ready_screen_practice = visual.TextStim(win, text=ready_screen_practice, height=1.5, wrapWidth=30)

def do_run(stimset):
    #instructions
    if stimset == 'faces':
        instruct_screen_face.draw()
    else:
        instruct_screen_image.draw()
    win.flip()
    event.waitKeys(keyList=('space','1'))

    if stimset == 'faces':
        instruct_screen1_face.draw()
    else:
        instruct_screen1_image.draw()
    win.flip()
    event.waitKeys(keyList=('space','1'))
    
    #wait for scan trigger 
    if version == 'practice':
        ready_screen_practice.draw()
    else:
        ready_screen.draw()
    win.flip()
    event.waitKeys(keyList=('equal'))
    run_start = time.time()
    
    #set Version ITI, Image orders, feedback order
    if age == '18-29':
        agerange = 1
    elif age =='30-49':
        agerange = 2
    elif age == '50-69':
        agerange = 3
    else:
        agerange = 4
    
    if task_type == 'faces':
        pic_path = os.path.join(os.getcwd(), 'pictureFolder', f'{stimset}Labelled{agerange}',)
    else:
        pic_path = os.path.join(os.getcwd(), 'pictureFolder', f'{stimset}Labelled',)
    
    #lists to store logging
    clock = core.Clock()
    clock.reset()
    onset = []
    duration = []
    condition = []
    resp_val = []
    responsetime = []
    b_1 = []
    b_2 = []
    b_3 = []
    b_4 = []
    b_5 = []
    b_6 = []
    b_7 = []
    b_8 = []

    #hide mouse
    win.mouseVisible = False
    
    for trial in reference.iterrows():
        trial_start = clock.getTime()
        row_counter = trial[0]
        if version == 'practice' and row_counter == 3:
            print('Practice Complete')
            core.quit()
        
        pic_L_image_name = reference.loc[reference.index[row_counter], f'{version}_{stimset}_L']
        pic_R_image_name = reference.loc[reference.index[row_counter], f'{version}_{stimset}_R']
        pic_L = visual.ImageStim(win,os.path.join(pic_path, pic_L_image_name), pos =(-7,0),size=(11.2,17.14))
        pic_R = visual.ImageStim(win,os.path.join(pic_path, pic_R_image_name), pos =(7,0),size=(11.2,17.14))
        border = visual.ShapeStim(win, vertices=pic_L.verticesPix, units='pix', fillColor = 'grey', lineColor = 'grey')
        border2 = visual.ShapeStim(win, vertices=pic_R.verticesPix, units='pix', fillColor = 'grey', lineColor = 'grey')
        select_2 = visual.ShapeStim(win, vertices=pic_L.verticesPix, units='pix', lineWidth = 10, lineColor = 'white')
        select_3 = visual.ShapeStim(win, vertices=pic_R.verticesPix, units='pix', lineWidth = 10, lineColor = 'white')
        
        trial_timer = core.CountdownTimer(5.2)   
        while trial_timer.getTime() > 0:
            #1st fixation
            if stimset == 'image':
                timer = core.CountdownTimer(fixation_time + 0.034)
            else:
                timer = core.CountdownTimer(fixation_time)
            while timer.getTime() > 0:
                fixation.draw()
                win.flip()
            fixationPre_dur = clock.getTime() - trial_start
            
            #decision_phase
            timer = core.CountdownTimer(decision_time)
            resp = event.getKeys(keyList = responseKeys)
            decision_onset = clock.getTime()
            while timer.getTime() > 0:
                pic_L.draw()
                pic_R.draw()
                win.flip()
                resp = event.getKeys(keyList = responseKeys)
                if len(resp)>0:
                    if 'z' in resp:
                        log.to_csv(os.path.join("data",subj_id, f"sub-{subj_id}_{stimset}-{version}-{agerange}.tsv"), sep='\t', index = False)
                        bidsEvents.to_csv(os.path.join("data",subj_id, f"sub-{subj_id}_ses-1_task-socialReward_{stimset}{version}{agerange}_events.tsv"), sep='\t', index = False)
                        core.quit()
                    if selected == 1 or 2:
                        selected = int(resp[0])
                        if selected == 1:
                            pic_L.draw()
                            pic_R.draw()
                            l_r = 'left'
                            select_2.draw()
                            win.flip()
                            core.wait(.5)
                        elif selected == 2:
                            pic_R.draw()
                            pic_L.draw()
                            l_r = 'right'
                            select_3.draw()
                            win.flip()
                            core.wait(.5)
                        resp_onset = clock.getTime()
                        rt = resp_onset - decision_onset
                        border.autoDraw=True
                        border2.autoDraw=True
                        pic_L.draw()
                        pic_R.draw()
                        #win.flip()
                        core.wait(decision_time - rt)
                        break
                else:
                    resp = 999
                    selected = 'n/a'
                    rt = 'n/a'
                    l_r = 'n/a'
                    core.wait(.25)
            decision_dur = clock.getTime() - decision_onset 
            border.autoDraw=False
            border2.autoDraw=False
            
            #2nd fixation
            timer = core.CountdownTimer(fixation_time)
            fixationPost_onset = clock.getTime()
            while timer.getTime() > 0:
                fixation.draw()
                win.flip()
            fixationPost_dur = clock.getTime() - fixationPost_onset

            #feedback
            timer = core.CountdownTimer(fb_dur)
            feedback_onset = clock.getTime()
            fb_type = reference.loc[reference.index[row_counter], f'{version}_feedback']
            if resp == 999:
                while timer.getTime() > 0:
                    no_resp.draw()
                    win.flip()
            elif resp == 1 or 2:
                if fb_type == 'loss':
                    while timer.getTime() > 0:
                        for stim in miss_stim:
                            stim.draw()
                        win.flip()
                elif fb_type == 'win':
                    while timer.getTime() > 0:
                        for stim in hit_stim:
                            stim.draw()
                        win.flip() 
                else:
                    print('Feedback Error')
            else:
                print('Feedback Error')
            feedback_dur = clock.getTime() - feedback_onset
            
            #ITI
            ITI_onset = clock.getTime()
            ITI = reference.loc[reference.index[row_counter], f'{version}_ITI']
            timer = core.CountdownTimer(ITI)
            while timer.getTime() > 0:
                fixation.draw()
                win.flip()
                core.wait(ITI)
            ITI_dur = clock.getTime() - ITI_onset
            
            gender = (pic_path, reference.loc[reference.index[row_counter], f'{version}_{stimset}_L'])
            
            #logging
            condition.append('fixation_1')
            onset.append(trial_start)
            duration.append(fixationPre_dur)
            resp_val.append('999')
            responsetime.append('999')

            condition.append('face')
            onset.append(decision_onset)
            duration.append(decision_dur)
            resp_val.append(selected)
            responsetime.append(rt)
            
            condition.append('fixation_2')
            onset.append(fixationPost_onset)
            duration.append(fixationPre_dur)
            resp_val.append('999')
            responsetime.append('999')
            
            condition.append('feedback ' + fb_type)
            onset.append(feedback_onset)
            duration.append(feedback_dur)
            resp_val.append('999')
            responsetime.append('999')
           
            condition.append('ITI')
            onset.append(ITI_onset)
            duration.append(ITI_dur)
            resp_val.append('999')
            responsetime.append('999')
            
            #BIDS Log
            
            #image or face being presented 
            b_1.append(decision_onset)
            b_2.append(decision_dur)
            if rt == 'n/a':
                b_3.append('decision-missed')
            else:
                b_3.append('decision')
            b_4.append(rt)
            b_5.append(l_r)
            b_6.append(gender[1][0:1])
            b_7.append(pic_L_image_name)
            b_8.append(pic_R_image_name)
            
            #feedback
            b_1.append(feedback_onset)
            b_2.append(feedback_dur)
            b_3.append(fb_type)
            b_4.append('n/a')
            b_5.append('n/a')
            b_6.append('n/a')
            b_7.append(pic_L_image_name)
            b_8.append(pic_R_image_name)

        #data to frame 
        log = pd.DataFrame(
                {'onset':onset, 
                'duration':duration,
                'trial_type':condition,
                'rt':responsetime,
                'resp':resp_val})

        bidsEvents = pd.DataFrame(
                {'onset':b_1, 
                'duration':b_2,
                'trial_type':b_3,
                'rt':b_4,
                'resp':b_5,
                'gender':b_6,
                'image_left':b_7,
                'image_right':b_8})
        
        log.to_csv(os.path.join("data",subj_id, f"sub-{subj_id}_{stimset}-{version}-{agerange}.tsv"), sep='\t', index = False)
        bidsEvents.to_csv(os.path.join("data",subj_id, f"sub-{subj_id}_ses-1_task-socialReward_{stimset}{version}{agerange}_events.tsv"), sep='\t', index = False)
    run_end = time.time()
    run_length = run_end -run_start
    print(run_length)
    event.clearEvents()
    return;

def all_run():
    print(subj_id)
    try:
        os.mkdir(f'data/{subj_id}')
    except:
        print("Subject File Exists, Overwrite Warning")
    if task_type == 'doors' or 'faces':
        do_run(task_type)
    else:
        print('Could not find task order')
        core.quit()
    return;

all_run()
print('Task Completed')
fixation.draw()
core.wait(10.0)
win.flip()
core.quit()

###beta###
#check all ordering
#overwrite protect
#brainstorm other features?

#exit
#exit_screen = visual.TextStim(win, text='Thanks for playing! Please wait for instructions from the experimenter.', pos = (0,1), wrapWidth=20, height = 1.2)
#exit_screen.draw()
event.waitKeys()