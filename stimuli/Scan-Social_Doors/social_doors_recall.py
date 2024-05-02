#!/usr/bin/env python

# ============================
# ===== EXPERIMENT SETUP =====
# ============================

# ----- CALLING PACKAGES -----
from __future__ import absolute_import, division
from psychopy import prefs
from psychopy import sound, gui, visual, core, data, event, logging, clock, colors
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)
from psychopy.hardware import keyboard
import os
import numpy as np
import random
from pyglet.window import key
import datetime

# ---- CONVENIENTLY MODIFIABLE VARIABLES -----

continueValue = 'space'
respList = ['1', '2', '9', '0']
isiDur = 0.2
expName = 'Recall'
MonitorUsed = 1

# ------ SPECIFYING DIRECTORIES, HARDWARE READERS, and PREFERENCES -----

keyState=key.KeyStateHandler()
prefs.general['audioLib']=['pyo']
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# ----- CREATING a DATA DICTIONARY ----- 

psychopyVersion = '2021.2.3'
expInfo = {'Participant*': '', 'Age':['18-29','30-49','40-69','70-89+']}
dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
if dlg.OK == False:
    core.quit()

if expInfo['Age'] == '18-29':
    agerange = 1
elif expInfo['Age'] =='30-49':
    agerange = 2
elif expInfo['Age'] == '40-69':
    agerange = 3
else:
    agerange = 4

expInfo['date'] = data.getDateStr()
expInfo['expName'] = expName
expInfo['psychopyVersion'] = psychopyVersion

filename = _thisDir + os.sep + u'data/%s/%s_%s_%s_%s' % (expInfo['Participant*'], expName, expInfo['Participant*'], expInfo['date'], f'{agerange}')

thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath='C:\\' + expName + '\\Script.py',
    savePickle=True, saveWideText=True,
    dataFileName=filename)
    
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)

endExpNow = False

# =============================
# ===== GLOBAL COMPONENTS =====
# =============================

# Specifying Window & Screen Information -----
win = visual.Window(size=(1280, 800), 
                    fullscr=True, 
                    screen= MonitorUsed, 
                    winType='pyglet', 
                    allowGUI=True, 
                    allowStencil=False,
                    monitor='testMonitor', 
                    color=[0,0,0], 
                    colorSpace='rgb',
                    blendMode='avg', 
                    useFBO=True, 
                    units='height')

win.winHandle.push_handlers(keyState)
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0
frameTolerance = 0.001    

# Keyboard Components ----
defaultKeyboard = keyboard.Keyboard()
kb = keyboard.Keyboard()

# Time Components ----
routineTimer = core.CountdownTimer()

# Text Components ----
endText = visual.TextStim(win=win,text='Thank you for your participation in this part of the study!', pos=(0, 0), height=0.06, wrapWidth=1.6, color='white');

# ============================
# ===== CUSTOM FUNCTIONS =====
# ============================

# ----- INTERSTIMULUS INTERVALS -----
def isiPresent(duration):
    # FUNCTION SETUP ----
    # Creating a text component for the fixation cross
    stim = visual.TextStim(win=win, text='+',pos=(0, 0), height=0.10, color='white');

    # Noting which components we'll be using 
    isiComponents = [stim]
    for thisComponent in isiComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED

    # Timing Variables
    ts_start = datetime.datetime.now()
    isiClock = core.Clock()
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    isiClock.reset(-_timeToFirstFrame)

    # FUNCTION START ----
    # Creating an "On Switch", As long as continueRoutine equals true, this function will continue running
    continueRoutine = True
    # Setting a time limit equal to duration for how long this function can run
    routineTimer.add(duration)
    # While continueRoutine is true and the time hasn't run out
    while continueRoutine and routineTimer.getTime() > 0:
        tThisFlip = win.getFutureFlipTime(clock=isiClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)

        if stim.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            stim.tStart = isiClock.getTime()
            stim.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(stim, 'tStartRefresh')
            stim.setAutoDraw(True)
        if stim.status == STARTED:
            if tThisFlipGlobal > stim.tStartRefresh + duration-frameTolerance:
                stim.tStop = isiClock.getTime()
                win.timeOnFlip(stim, 'tStopRefresh')
                stim.setAutoDraw(False)
        isiOffset = stim.tStartRefresh + isiClock.getTime()

        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()

        if not continueRoutine:
            break
        continueRoutine = False
        for thisComponent in isiComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break

        if continueRoutine:
            win.flip()

     # end isi
    for thisComponent in isiComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    ts_end = datetime.datetime.now()
    thisExp.addData("Func", "isiFunc") 
    thisExp.addData('Keys','NA') 
    thisExp.addData('Text', '+')
    thisExp.addData('RespTime','NA')
    thisExp.addData('Onset', stim.tStartRefresh)
    thisExp.addData('Offset', isiOffset)
    thisExp.addData('SystemTime_Start', ts_start)
    thisExp.addData('SystemTime_Stop', ts_end)
    routineTimer.reset()
    thisExp.nextEntry()

# ----- INITIAL INSTRUCTIONS -----
def textPresent(continueKey, text):
    
    # FUNCTION SETUP ----
    # Telling Python which components we'll be using within this function
    instr = visual.TextStim(win=win,
                            text='', 
                            pos=[0,0], 
                            height=0.05, 
                            wrapWidth=1.45,
                            color='white');
    
    instrComponents = [instr, kb]
    for thisComponent in instrComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED

    # Create an empty array to capture key press information
    # This information comes as a vector, so we'll need to split it
    _kb_allKeys = []
    # Create an empty array to capture only what keys people press
    kb.keys = []
    # Create an empty array to capture only response times with which the keys were pressed
    kb.rt = []

    # Timing Variables
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    instrClock = core.Clock()
    instrClock.reset(-_timeToFirstFrame)
    ts_start = datetime.datetime.now()

    # FUNCTION START ----
    # Creating an "On Switch", As long as continueRoutine equals true, this function will continue running
    continueRoutine = True
    
    # As long as continueRoutine = True, do the following:
    while continueRoutine:
        # Set t to however long the task has been running thus far
        tThisFlip = win.getFutureFlipTime(clock=instrClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        # If the instr text component has been initialized, do the following 
        if instr.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # Set the text to whatever we specified in the function
            instr.setText(text)
            # Set the time that the instruction was presented to whatever t is equivalent to
            instr.tStart = instrClock.getTime()
            instr.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(instr, 'tStartRefresh')
            # Present the text
            instr.setAutoDraw(True)

        waitOnFlip = False

        # If the kb keyboard has not been initialized, do the following
        if kb.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            kb.tStart = instrClock.getTime()
            kb.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(kb, 'tStartRefresh')
            kb.status = STARTED
            waitOnFlip = True
            win.callOnFlip(kb.clock.reset)
            win.callOnFlip(kb.clearEvents, eventType='keyboard')

        # If the kb keyboard has been initialized, do the following
        if kb.status == STARTED and not waitOnFlip:
            # Collect any responses that match the continueKey as soon as they are pressed
            theseKeys = kb.getKeys(keyList=[continueKey], waitRelease=False)
            # Add information about the pressing to the end of the array _kb_allkeys
            _kb_allKeys.extend(theseKeys)
            # If _kb_allkeys is no longer empty:
            if len(_kb_allKeys):
                # Record what key was pressed in kb.keys
                kb.keys = _kb_allKeys[-1].name
                # Record the response time of the pressing in kb.rt
                kb.rt = _kb_allKeys[-1].rt
                # Move on to the next routine
                continueRoutine = False

        # If escape is pressed, end the program
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()

        # If continueRoutine is False
        if not continueRoutine:
            break
        continueRoutine = False
        for thisComponent in instrComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break
        if continueRoutine:
            win.flip()
    
    # Record what time the instructions ended by adding the current time to the time the instuctions first appeared        
    instrOffset = instr.tStartRefresh + instrClock.getTime()        

    # end inst routine
    for thisComponent in instrComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    if kb.keys in ['', [], None]:
        kb.keys = None
    ts_end = datetime.datetime.now()        
    thisExp.addData("Func", "instrFunc")     
    thisExp.addData('Keys',kb.keys) 
    thisExp.addData('Text', instr.text)
    thisExp.addData('RespTime',kb.rt)
    thisExp.addData('Onset', instr.tStartRefresh)
    thisExp.addData('Offset', instrOffset)
    thisExp.addData('SystemTime_Start', ts_start)
    thisExp.addData('SystemTime_Stop', ts_end)   
    routineTimer.reset()
    thisExp.nextEntry()

# ----- IMAGE INSTRUCTIONS -----
def imgtextPresent(continueKey, img, text):
    
    # FUNCTION SETUP ----
    # Telling Python which components we'll be using within this function
    instr = visual.TextStim(win=win,
                            text='', 
                            pos=[0,0], 
                            height=0.05, 
                            wrapWidth=1.45,
                            color='white');
    
    # Creating a component for stimulus
    imgInstrRow = -0.05
    imgInstrSize = 0.6

    imgInstr = visual.ImageStim(win=win, image='sin', mask=None, ori=0.0, pos=(0.00, imgInstrRow), size=(imgInstrSize, imgInstrSize/1.6),
                               color=[1,1,1], colorSpace='rgb', texRes=128.0, interpolate=True, depth=-4.0)
    
    instrComponents = [instr, kb, imgInstr]
    for thisComponent in instrComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED

    # Create an empty array to capture key press information
    # This information comes as a vector, so we'll need to split it
    _kb_allKeys = []
    # Create an empty array to capture only what keys people press
    kb.keys = []
    # Create an empty array to capture only response times with which the keys were pressed
    kb.rt = []

    # Timing Variables
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    instrClock = core.Clock()
    instrClock.reset(-_timeToFirstFrame)
    ts_start = datetime.datetime.now()

    # FUNCTION START ----
    # Specifying the stimulus image
    imgInstr.setImage(img)
    # Creating an "On Switch", As long as continueRoutine equals true, this function will continue running
    continueRoutine = True
    # As long as continueRoutine = True, do the following:
    while continueRoutine:
        # Set t to however long the task has been running thus far
        tThisFlip = win.getFutureFlipTime(clock=instrClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        # If the instr text component has been initialized, do the following 
        if instr.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # Set the text to whatever we specified in the function
            instr.setText(text)
            # Set the time that the instruction was presented to whatever t is equivalent to
            instr.tStart = instrClock.getTime()
            instr.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(instr, 'tStartRefresh')
            # Present the text
            instr.setAutoDraw(True)
        if imgInstr.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            imgInstr.tStart = instrClock.getTime()
            imgInstr.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(imgInstr, 'tStartRefresh')
            imgInstr.setAutoDraw(True) 

        waitOnFlip = False

        # If the kb keyboard has not been initialized, do the following
        if kb.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            kb.tStart = instrClock.getTime()
            kb.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(kb, 'tStartRefresh')
            kb.status = STARTED
            waitOnFlip = True
            win.callOnFlip(kb.clock.reset)
            win.callOnFlip(kb.clearEvents, eventType='keyboard')

        # If the kb keyboard has been initialized, do the following
        if kb.status == STARTED and not waitOnFlip:
            # Collect any responses that match the continueKey as soon as they are pressed
            theseKeys = kb.getKeys(keyList=[continueKey], waitRelease=False)
            # Add information about the pressing to the end of the array _kb_allkeys
            _kb_allKeys.extend(theseKeys)
            # If _kb_allkeys is no longer empty:
            if len(_kb_allKeys):
                # Record what key was pressed in kb.keys
                kb.keys = _kb_allKeys[-1].name
                # Record the response time of the pressing in kb.rt
                kb.rt = _kb_allKeys[-1].rt
                # Move on to the next routine
                continueRoutine = False

        # If escape is pressed, end the program
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()

        # If continueRoutine is False
        if not continueRoutine:
            break
        continueRoutine = False
        for thisComponent in instrComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break
        if continueRoutine:
            win.flip()
    
    # Record what time the instructions ended by adding the current time to the time the instuctions first appeared        
    instrOffset = instr.tStartRefresh + instrClock.getTime()        

    # end inst routine
    for thisComponent in instrComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    if kb.keys in ['', [], None]:
        kb.keys = None
    ts_end = datetime.datetime.now()        
    thisExp.addData("Func", "imgtextFunc")     
    thisExp.addData('Keys',kb.keys) 
    thisExp.addData('Text', instr.text)
    thisExp.addData('RespTime',kb.rt)
    thisExp.addData('Onset', instr.tStartRefresh)
    thisExp.addData('Offset', instrOffset)
    thisExp.addData('SystemTime_Start', ts_start)
    thisExp.addData('SystemTime_Stop', ts_end)   
    routineTimer.reset()
    thisExp.nextEntry()


# ----- IMAGE PRESENTATION -----
def imgPresent(respKeys, Stim, Name, Lure, Left, Right):

    # FUNCTION SETUP ----
    # Creating a component for stimulus
    imgStimRow = 0.15
    imgStimSize = 0.7

    imgStim = visual.ImageStim(win=win, image='sin', mask=None, ori=0.0, pos=(0.00, imgStimRow), size=(imgStimSize/1.53, imgStimSize),
                               color=[1,1,1], colorSpace='rgb', texRes=128.0, interpolate=True, depth=-4.0)

    # Creating a component for the direction images
    imgDirRow = -.30
    imgDirCol = 0.50
    imgDirSize = 0.25
    imgDirLeft = visual.ImageStim(win=win,image='sin', mask=None, ori=0.0, pos=(-imgDirCol, imgDirRow), size=(imgDirSize, imgDirSize/1.25),
        color=[1,1,1], colorSpace='rgb', texRes=128.0, interpolate=True, depth=-4.0)
    imgDirRight = visual.ImageStim(win=win,image='sin', mask=None, ori=0.0, pos=(imgDirCol, imgDirRow), size=(imgDirSize, imgDirSize/1.25),
        color=[1,1,1], colorSpace='rgb', texRes=128.0, interpolate=True, depth=-4.0)
    
    # Telling Python which components we'll need here    
    imgComponents = [imgStim, imgDirLeft, imgDirRight, kb]
    for thisComponent in imgComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED    

    # Create an empty array to capture key press information
    # This information comes as a vector, so we'll need to split it
    _kb_allKeys = []
    # Create an empty array to capture only what keys people press
    kb.keys = []
    # Create an empty array to capture only response times with which the keys were pressed
    kb.rt = []

    # Timing Variables
    imgClock = core.Clock()
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    imgClock.reset(-_timeToFirstFrame)
    ts_start = datetime.datetime.now()
    
    # FUNCTION START ----
    # Specifying the stimulus image
    imgStim.setImage(Stim)
    # Specifying the left direction image
    imgDirLeft.setImage(Left)
    # Specifying the right direction image
    imgDirRight.setImage(Right)    
    continueRoutine = True
    while continueRoutine:
        tThisFlip = win.getFutureFlipTime(clock=imgClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        if imgStim.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            imgStim.tStart = imgClock.getTime()
            imgStim.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(imgStim, 'tStartRefresh')
            imgStim.setAutoDraw(True)      
        waitOnFlip = False
        if imgDirLeft.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            imgDirLeft.tStart = imgClock.getTime()
            imgDirLeft.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(imgDirLeft, 'tStartRefresh')
            imgDirLeft.setAutoDraw(True) 
        if imgDirRight.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            imgDirRight.tStart = imgClock.getTime()
            imgDirRight.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(imgDirRight, 'tStartRefresh')
            imgDirRight.setAutoDraw(True)                
        if kb.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            kb.tStart = imgClock.getTime()
            kb.tStartRefresh = tThisFlipGlobal
            win.timeOnFlip(kb, 'tStartRefresh')
            kb.status = STARTED
            waitOnFlip = True
            win.callOnFlip(kb.clock.reset)
            win.callOnFlip(kb.clearEvents, eventType='keyboard')
        if kb.status == STARTED and not waitOnFlip:
            theseKeys = kb.getKeys(keyList = respKeys, waitRelease = False)
            _kb_allKeys.extend(theseKeys)
            if len(_kb_allKeys):
                kb.keys = _kb_allKeys[-1].name
                kb.rt = _kb_allKeys[-1].rt
                continueRoutine = False
           
        imgOffset = imgStim.tStartRefresh + imgClock.getTime()            
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        if not continueRoutine:
            break
        continueRoutine = False
        for thisComponent in imgComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break
        if continueRoutine:
            win.flip()

    # end routine img
    for thisComponent in imgComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    ts_end = datetime.datetime.now()
    thisExp.addData("Func", "imgFunc")
    thisExp.addData("Stim", Name)
    thisExp.addData("Lure", Lure)
    thisExp.addData('Keys',kb.keys) 
    thisExp.addData('Text', 'NA')
    thisExp.addData('RespTime',kb.rt)
    thisExp.addData('Onset', imgStim.tStartRefresh)
    thisExp.addData('Offset', imgOffset)
    thisExp.addData('SystemTime_Start', ts_start)
    thisExp.addData('SystemTime_Stop', ts_end)    
    routineTimer.reset()
    thisExp.nextEntry()

## ===============================
## ===== EXPERIMENTAL DESIGN =====
## ===============================

# Instructions
Instructions = data.TrialHandler(nReps=1.0, method='sequential',
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('RecallInstructions.xlsx'),
    seed=None, name='Instructions')
thisExp.addLoop(Instructions)
thisInstruction = Instructions.trialList[0]
for thisInstruction in Instructions:
    if thisInstruction != None:
        for paramName in thisInstruction:
            exec('{} = thisInstruction[paramName]'.format(paramName))     
    textPresent(continueKey = continueValue,
                 text = instrText)

# Last instruction screen with example
imgtextPresent(continueKey = continueValue,
               img = os.path.join('pictureFolder','RecallExample.png'),
               text = "Here is what the screen will look like while you make your ratings.\nThe green circles remind you to press 1 or 9 for positive feedback.\nThe red circles remind you to press 2 or 0 for negative feedback.\n\n\n\n\n\n\n\n\n\nPlease let the experimenter know if you have any questions.\n\nWhenever you're ready, press the spacebar to start the task.")

# First Run
# Randomizing which run will occur first
FirstRun = random.choice(("Faces","Doors"))

#Randomizing the trials within the first run
Trials = data.TrialHandler(nReps=1.0, method='random',
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('RecallStimList.xlsx'),
    seed=None, name='Trials')
thisExp.addLoop(Trials)
thisTrial = Trials.trialList[0]
for thisTrial in Trials:
    if thisTrial != None:
        for paramName in thisTrial:
            exec('{} = thisTrial[paramName]'.format(paramName))
    # There's a two second ISI between presentations, which you can remove by just removing isiPresent
    ##isiPresent(isiDur)        
    # Here's the actual presentation of the stimulus
    if FirstRun == "Faces":
        imgPresent(respKeys = respList,
                   Stim = os.path.join('pictureFolder',f'facesLabelled{agerange}', f'{stimFace}'),
                   Name = stimFace,
                   Lure = stimFaceLure,
                   Left = os.path.join('pictureFolder','LeftPrompt.png'),
                   Right = os.path.join('pictureFolder','RightPrompt.png'))
    if FirstRun != "Faces":
        imgPresent(respKeys = respList,
                   Stim = os.path.join('pictureFolder', 'doorsLabelled', f'{stimDoor}'),
                   Name = stimDoor,
                   Lure = stimDoorLure,
                   Left = os.path.join('pictureFolder','LeftPrompt.png'),
                   Right = os.path.join('pictureFolder','RightPrompt.png'))                

# Room for some other instructions
textPresent(continueKey = continueValue,
            text = "Great work! \n\n Now you will switch to the other image type.\n\n Press the spacebar whenever you are ready to start.")

#Second Run
Trials = data.TrialHandler(nReps=1.0, method='random',
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('RecallStimList.xlsx'),
    seed=None, name='Trials')
thisExp.addLoop(Trials)
thisTrial = Trials.trialList[0]
for thisTrial in Trials:
    if thisTrial != None:
        for paramName in thisTrial:
            exec('{} = thisTrial[paramName]'.format(paramName))
    ##isiPresent(isiDur)
    if FirstRun == "Faces":        
        imgPresent(respKeys = respList,
                   Stim = os.path.join('pictureFolder', 'doorsLabelled', f'{stimDoor}'),
                   Name = stimDoor,
                   Lure = stimDoorLure,
                   Left = os.path.join('pictureFolder','LeftPrompt.png'),
                   Right = os.path.join('pictureFolder','RightPrompt.png'))
    if FirstRun != "Faces":        
        imgPresent(respKeys = respList,
                   Stim = os.path.join('pictureFolder', f'facesLabelled{agerange}', f'{stimFace}'),
                   Name = stimFace,
                   Lure = stimFaceLure,
                   Left = os.path.join('pictureFolder','LeftPrompt.png'),
                   Right = os.path.join('pictureFolder','RightPrompt.png'))                

## ===============================
## ====== EXPERIMENT ENDING ======
## =============================== 
continueRoutine = True
endEnter = keyboard.Keyboard()
endEnter.keys = []
endEnter.rt = []
_endEnter_allKeys = []
EndScreenComponents = [endText, endEnter]
for thisComponent in EndScreenComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
EndScreenClock = core.Clock()
EndScreenClock.reset(-_timeToFirstFrame)

# ----- END SCREEN ROUTINE ----- 
while continueRoutine:
    tThisFlip = win.getFutureFlipTime(clock=EndScreenClock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    if endText.status == NOT_STARTED:
        endText.tStart = EndScreenClock.getTime()
        endText.setAutoDraw(True)
        waitOnFlip = False
    if endEnter.status == NOT_STARTED:
        endEnter.tStart = EndScreenClock.getTime()
        endEnter.status = STARTED
        waitOnFlip = True
        win.callOnFlip(endEnter.clock.reset)
        win.callOnFlip(endEnter.clearEvents, eventType='keyboard')
    if endEnter.status == STARTED and not waitOnFlip:
        theseKeys = endEnter.getKeys(keyList=['enter'], waitRelease=False)
        _endEnter_allKeys.extend(theseKeys)
        if len(_endEnter_allKeys):
            endEnter.keys = _endEnter_allKeys[-1].name
            endEnter.rt = _endEnter_allKeys[-1].rt
            continueRoutine = False
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    if not continueRoutine:
        break
    continueRoutine = False
    for thisComponent in EndScreenComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break
    if continueRoutine:
        win.flip()

# ----- END SCREEN CLOSING ----- 
for thisComponent in EndScreenComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
if endEnter.keys != None:
    thisExp.addData('RespTime', endEnter.rt)
thisExp.nextEntry()
routineTimer.reset()
win.flip()
thisExp.saveAsWideText(filename+'.xlsx', delim='auto')
thisExp.saveAsPickle(filename)
logging.flush()
thisExp.abort()
win.close()
core.quit()