#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, os, subprocess
from termcolor import colored, cprint
from PIL import Image


#
# Need to find path to spectrology
#


#Global Variables...
local_ip='10.0.0.1' #change this
pbx_ip='10.0.0.2' #change this
IMG=''
ext=''
strips = []
spectros = []
pcaps = []

# request image from user
def reqImage():
    global IMG
    img_path = raw_input(colored('Please input the path to your image: ', 'cyan', attrs=['bold']))
    iIMG = img_path
    os.system('cp %s . 2>/dev/null' % img_path )
    IMG = os.path.basename(img_path)
    print("We found it!")

# chop up image
def chopImage():
    im = Image.open(IMG)                 
    imgwidth, imgheight = im.size           #Get image sizes (from file?)
    height = 200                            #Height of our slices, 200-300px
    width = imgwidth
    print 'Image Height: %s' % imgheight
    j = 0                                      
    for i in range(0,imgheight,height):
        print "r:0 t: %d, l: %d, b:%d" % (i, width, height*(j+1))
        box = (0, i, width, height*(j+1))         
        tmp = im.crop(box)                  
        fname = 'images/' + IMG.replace('.bmp', '_%s.bmp' % j)
        tmp.save(fname) 
        strips.append(fname)
        j += 1

# send image to encoder
def encodeSpectro():
    for img in strips:
        fname = img.replace('.bmp','.wav').replace('images/', '')
        os.system('python spectrology/spectrology.py '+ img +' -b 20 -t 2000 -s 8000 -o spectros/' + fname) 
        spectros.append(fname)

def convertWAV2PCAP():
    for spec in spectros:
        fname = spec.replace('.wav','.pcap') #remove/replace file ending
        print spec
        os.system('/opt/wav2rtp/bin/wav2rtp -f '+ 'spectros/' + spec + ' -t pcaps/'+ fname + ' -c PCMU')
        pcaps.append(fname)

# Generate voip_1100.xml file
def genXML():
    os.system("./genXML.sh %s" % ext )

#deliver over SIPp
def shipIt():
    print "Ship it!!"
    os.system('MAX_CALLS=1')
    os.system('export PATH=$PATH:/usr/local/bin')
    os.system('ulimit -n 65536')
    #os.system('sipp ' + pbx_ip + ' -t t1 -i "' + local_ip + '" -sf "voip_1100.xml" -inf "voip_1100.csv" -mi "' + local_ip + '" -m "200000" -l "$MAX_CALLS" -r "1" -rp "3s" -d 50 -skip_rlimit -trace_err --watchdog_minor_threshold 10000 --watchdog_major_threshold 20000')
    os.system('sipp 10.0.0.1 -t t1 -i "10.0.0.2" -sf "voip_1100.xml" -inf "voip_1100.csv" -mi "10.0.0.2" -m "200000" -l "$MAX_CALLS" -r "1" -rp "3s" -d 50 -skip_rlimit -trace_err --watchdog_minor_threshold 10000 --watchdog_major_threshold 20000') #the 10.0.0.2 needs to be a variable that is your local ip


#Check for dependecies
def checkDepoz():
    try:
        osstdout = subprocess.check_call("./checkDepos.sh")
    except subprocess.CalledProcessError:
        print "\n\n****** EXITING PROGRAM DUE TO MISSING DEPENDENCIES ******\n\n"
        exit()

    return osstdout

#Generate dtmf tone for a number
def dtmf():
    global ext
    ext = raw_input(colored('\nPlease enter the extension to dial: ', 'cyan', attrs=['bold' ]))
    os.system('./makeDTMF.sh %s' % ext)
    
def cleanUp():
    os.system('rm -rf pcaps/ 2>/dev/null')
    os.system('rm -rf images/ 2>/dev/null')
    os.system('rm -rf spectros/ 2>/dev/null')
    os.system('rm -rf %s 2>/dev/null' % IMG )
    
def main():
    
    #Catch that ugly ctrl-c error and exit gracefully
    try:
        print colored('\nWelcome to the VoIP Stego extravaganza!\n', 'blue', attrs=['bold', 'underline'])

        #Check if all dependencies are there
        checkDepoz()

        #Ask if user wants to make a DTMF pcap
        dtmf()

        #Make subfolders
        if not os.path.exists('images'):
            os.makedirs('images')
        if not os.path.exists('spectros'): 
            os.makedirs('spectros')
        if not os.path.exists('pcaps'):
            os.makedirs('pcaps')

        print "\n"

        #Get image
        reqImage()

        #Chop image into subfolder
        chopImage()

        #Make image .wavs into subfolder
        encodeSpectro()

        #FOR TESTING
        #Convert wavs to pcaps into subfolder
        convertWAV2PCAP()

        genXML()

        shipIt()
        
        cleanUp()

        exit()

    except KeyboardInterrupt:
        print colored("\n\nOk, I'll take the hint... " + u'◕︵◕ \n', 'red', attrs=['bold'])
        exit()

if __name__ == '__main__':
    main()
