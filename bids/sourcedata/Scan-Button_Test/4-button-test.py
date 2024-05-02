#Ori Zaff - 7/29/22

from psychopy import visual, core, event
win = visual.Window([800,600], monitor="testMonitor", units="deg")

button_box = visual.ImageStim(win, image = './buttons.jpg',size=(20), pos=[0,0])
index = visual.ImageStim(win, image = './index.jpg',size=(20), pos=[0,0])
middle = visual.ImageStim(win, image = './middle.jpg',size=(20), pos=[0,0])
ring = visual.ImageStim(win, image = './ring.jpg',size=(20),pos=[0,0])
pinky = visual.ImageStim(win, image = './pinky.jpg',size=(20), pos=[0,0])

responseKeys=('1','2','3','4','z')
resp = event.getKeys(keyList = responseKeys)


while core.Clock().getTime() < (60):
    button_box.draw()
    win.flip()
    resp = event.getKeys(keyList = responseKeys)
    if len(resp)>0:
        if resp[0] == 'z':
            win.close()
            core.quit()
        elif resp[0] == '1':
            index.draw()
            win.flip()
            core.wait(.5)
            button_box.draw()
            win.flip()
        elif resp[0] == '2':
            middle.draw()
            win.flip()
            core.wait(.5)
            button_box.draw()
            win.flip()
        elif resp[0] == '3':
            ring.draw()
            win.flip()
            core.wait(.5)
            button_box.draw()
            win.flip()
        elif resp[0] == '4':
            pinky.draw()
            win.flip()
            core.wait(.5)
            button_box.draw()
            win.flip()


