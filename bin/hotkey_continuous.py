#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
from send_speech import Stt

def get_variable(variable_name, default=''):
    filePath = os.environ['HOME'] + '/.leopold/UserInfo'
    if os.path.isfile(filePath):
        content = open(filePath, 'r')
        for line in content:
            if variable_name in line:
                #print "Found: ", variable_name
                #print str(line).partition('=')[2].strip()
                return str(line).partition('=')[2].strip()
    return str(default)

def transText(text):
	text = text.replace("\n",'')
	home = subprocess.Popen("echo $HOME", shell=True, stdout=subprocess.PIPE).communicate()[0].replace('\n','')
	with open(home+"/.leopold/UserInfo") as f:
		for each in f:
			line = each.replace('\n','')
			if line.startswith("LANGUAGE="):
				language = line.replace("LANGUAGE=","").replace(" ","")
	try:
		if language == "en":
			return text
	except:
		return text
	else:
		f1 = open("microphone/Translations/"+language)
		f = f1.read().decode("utf-8")
		f1.close()
		f=f.split("\n")
		for l in f:
			l = l.replace('\n','')
			if l != "":
				o,n = l.split("=")
				if o == text:
					return n
	return text

speak=False
if get_variable('COMPUTER_SPEAK') == "true":
    speak=True    

def tell(text):
    print "tell '"+text+"'"
    if speak:
        os.system("'" + currentDir + "/plugins/Default/bin/say' "+ language +" \""+ text + "\" ")

def recognize(text):
    print "recognize '"+text+"'"
    os.system("'" + currentDir + "/bin/recognize.sh' \""+ text + "\" &")

    
binDir = os.path.dirname(os.path.realpath(__file__))
currentDir = os.path.abspath(os.path.join(os.path.dirname( __file__ ), '..', ''))

language = get_variable('LANGUAGE', 'en')
#get_variable('BIDUIFDQ')

# You can now call the computer before running a command
listen = False
computer_hello = get_variable('COMPUTER_HELLO')
computer_goodbye = get_variable('COMPUTER_GOODBYE')

if get_variable('COMPUTER_CALL') != "true":
    print "Computer Call is false"
    computer_hello = ""
    computer_goodbye = ""

# Source: http://stackoverflow.com/a/35857/2578205
def shellquote(s):
    return "'" + s.replace("'", "'\\''") + "'"

print computer_hello
print computer_goodbye

print currentDir

while True:
    if os.path.isfile(currentDir + '/microphone/pycmd_nocmd'):
        # The -l option doesn't cut the sound
        # 0.1% is really to low, when I just touch the keyboard it
        # recognizes it as a sound.

        # FIXME : it would be nice if about 1 second would be kept before the text
        # os.system("rec -r 16000 -b 16 speech.flac silence -l 1 0.1 8% 1 2.0 6%")
        #os.system("rec -r 16000 -b 16 temp/rec.mp3 silence -l 1 0.1 8% 1 2.0 6%")
        os.system("rec temp/rec.mp3 rate 16k silence -l 1 0.1 1% 1 2.0 1%")
        os.system("ffmpeg -i temp/rec.mp3 -ar 16000 -c:a flac temp/rec.flac > /dev/null 2>&1")
                
        with open('temp/rec.flac', 'r') as audio_file:
            content = audio_file.read()
        audio_file.closed

        os.system("rm temp/rec.mp3 > /dev/null 2>&1") # Remove old file
        os.system("rm temp/rec.flac > /dev/null 2>&1") # Remove old file

        stt = Stt()
        text = stt.speech_to_text(content)
        if text:
            text = text.encode('utf-8').strip()

            recognize(text)

            '''
            if listen and text == computer_goodbye:
                print "I was proud to help you."
                listen = False
                tell(transText("I was proud to help you"))
            elif listen or computer_hello == "":
                tell(transText("I do it now"))
	        print 'Out:',text
	        os.system("'"+currentDir + "/recognize' \"" + text + "\"")
            elif text == computer_hello:
                print "Yes ? I'm listening to you."
                listen = True
                tell(transText("Yes I m listening to you"))
            else:
                print "Please, call me, I'm ",computer_hello," and you called ",text
                tell(transText("Please call me") + computer_hello)
            '''

        else:
            print 'No text was returned'
