#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
from send_speech import Stt

def get_variable(variable_name, default=''):
    filePath = os.environ['HOME'] + '/.palaver.d/UserInfo'
    
    if os.path.isfile(filePath):
        content = open(filePath, 'r')
        
        for line in content:
            if variable_name in line:
                return str(line).partition('=')[2].strip()
            
    return str(default)

def transText(text):
	text = text.replace("\n",'')
	home = subprocess.Popen("echo $HOME", shell=True, stdout=subprocess.PIPE).communicate()[0].replace('\n','')
	with open(home+"/.palaver.d/UserInfo") as f:
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
		f1 = open("Microphone/Translations/"+language)
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
    if speak:
        os.system(currentDir + "/Plugins/Default/bin/say "+ language +" \""+ text + "\" &")
    
currentDir = os.path.dirname(os.path.realpath(__file__))

language = get_variable('LANGUAGE', 'en')
get_variable('BIDUIFDQ')

# You can now call the computer before running a command
listen = False
computer_hello = get_variable('COMPUTER_HELLO')
computer_goodbye = get_variable('COMPUTER_GOODBYE')

if get_variable('COMPUTER_CALL') != "true":
    computer_hello = ""
    computer_goodbye = ""
    

while True:
    if os.path.isfile(currentDir + '/Microphone/pycmd_nocmd'):
        # The -l option doesn't cut the sound
        # 0.1% is really to low, when I just touch the keyboard it
        # recognizes it as a sound.

        # FIXME : it would be nice if about 1 second would be kept before the text
        os.system("rec -r 16000 -b 16 speech.flac silence -l 1 0.1 8% 1 2.0 6%")
        with open('speech.flac', 'r') as audio_file:
            content = audio_file.read()
        audio_file.closed

        stt = Stt()
        text = stt.speech_to_text(content)
        if text:
            text = text.encode('utf-8').strip()
            if listen and text == computer_goodbye:
                print "I was proud to help you."
                listen = False
                tell(transText("I was proud to help you"))
            elif listen or computer_hello == "":
                tell(transText("I do it now"))
	        print 'Out:',text
	        os.system(currentDir + "/recognize \"" + text + "\"")
            elif text == computer_hello:
                print "Yes ? I'm listening to you."
                listen = True
                tell(transText("Yes I m listening to you"))
            else:
                print "Please, call me, I'm ",computer_hello," and you called ",text
                tell(transText("Please call me") + computer_hello)
        else:
            print 'No text was returned'
