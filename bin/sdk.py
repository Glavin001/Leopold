#!/usr/bin/env python

import argparse, os, tarfile, subprocess, shlex
parser = argparse.ArgumentParser(description='Create and Package Plugins.\nCreated by Brett Mayson (BmanDesigns)')
parser.add_argument('-c', metavar='create', type=str,help='Create a plugin - Create a New Plugin',default="")
parser.add_argument('-p', metavar='package', type=str,help='Package a plugin - Create a .sp package of your plugin',default="")
args = parser.parse_args()

root = ''.join([e+'/' for e in os.path.realpath(__file__).split('/')[0:-1]])
home = subprocess.Popen("echo $HOME", shell=True, stdout=subprocess.PIPE).communicate()[0].replace('\n','')

# Create new Plugin
if args.c != '':
	print "Creating new plugin"
	pdir = home+"/.leopold/Plugins_SDK/"+args.c+"/"
	os.system("mkdir -p "+pdir+"bin/")
	os.system("mkdir -p "+pdir+"config/")
	os.system("mkdir -p "+pdir+"modes/")
	os.system("touch "+pdir+"modes/main.dic")
	os.system("touch "+pdir+"bin/"+args.c)
	os.system("chmod +x "+pdir+"bin/"+args.c)
	os.system("touch "+pdir+"config/settings.conf")
	#Create plugin.info
	with open(home+"/.leopold/UserInfo") as f:
		for l in f:
			if l.startswith("FIRST="):
				first = l.replace("FIRST=",'').replace("\n",'')
			if l.startswith("LAST="):
				last = l.replace("LAST=",'').replace("\n",'')
	with open(pdir+"plugin.info",'w') as f:
		n = "\n"
		f.write("#Plugin.info automatically generated"+n)
		f.write("name = "+args.c+n)
		f.write("version = 1.0"+n)
		f.write("file = "+args.c+n)
		f.write("configs = settings.conf"+n)
		f.write("author = "+first+" "+last+n)
		f.write("description = "+n)
		f.write("actions ="+n)
	print "Created plugin in "+pdir
	print "-----"
	# What next...
	message = """To configure your plugin edit the respective files:
	plugin.info 	= Info about your Plugin
	bin/"""+args.c+""" 	= This is the file that will be executed when your command is said.
	config/settings.config 	= This file is used to store any settings your plugin needs.
	modes = main.dic 	= This will store all the commands your program needs.
	"""
	print message
	print "To create a portable plugin package run:"
	print "./sdk.py -p "+args.c+""
	print
	print "For more inforation see https://github.com/Glavin001/Leopold/wiki/Creating-A-Plugin"
	print

# Package Plugin
if args.p != '':
	print "Packaging existing plugin."
	print "Edit plugin.info file."
	import tarfile
	pdir = home+"/.leopold/Plugins_SDK/"+args.p+"/"
	os.system("$EDITOR "+pdir+"plugin.info")
	sp = tarfile.open(pdir+args.p+".sp","w:gz")
	sp.add(pdir+"plugin.info","plugin.info")
	for f in os.listdir(pdir+"modes"):
		if f.endswith("~") == False:
			if f == "main.dic":
				sp.add(pdir+"modes/"+f,"actions.dic")
			else:
				sp.add(pdir+"modes/"+f,f)
	for f in os.listdir(pdir+"bin"):
		if f.endswith("~") == False:
			sp.add(pdir+"bin/"+f,f)
	for f in os.listdir(pdir+"config"):
		if f.endswith("~") == False:
			sp.add(pdir+"config/"+f,f)
	sp.close()
	print "Packaged to ",pdir+args.p+".sp"
	print 
	print "To install this package run:"
	print "./plugins_manager.sh -i ",pdir+args.p+".sp"
	print


# Error: No command given.
if args.c == '' and args.p == '' :
	message = """Options :
	-c <name> : Create package name
	-p <name> : Package name"""
	print message
