#!/bin/bash

# Setup speech recognition for the person.
# Do NOT run this script as root, because it can cause problems with files rights

# Source: http://stackoverflow.com/a/1116890/2578205
TARGET_FILE=$0
cd `dirname $TARGET_FILE`
TARGET_FILE=`basename $TARGET_FILE`
# Iterate down a (possible) chain of symlinks
while [ -L "$TARGET_FILE" ]
do
    TARGET_FILE=`readlink $TARGET_FILE`
    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`
done
# Compute the canonicalized name by finding the physical path 
# for the directory we're in and appending the target file.
PHYS_DIR=`pwd -P`
RESULT=$PHYS_DIR/$TARGET_FILE
#echo $RESULT
# Move up on level to installDir from bin/
cd "$(dirname "$RESULT")" # installDir/bin/
RESULT=`pwd -P`
#echo "$(dirname "$RESULT")"

#cd "${0%/*}"

USER_DIR="$(./getUserDir.sh)"

# Check if running as Root
if [[ $EUID -ne 0 ]]; 
then
	# Not root
   	#echo "This script must be run as root" 
   	#exit 1
   	echo "Preparing to install."
else 
	# Is Root
	echo "Do NOT run this script as root, because it can cause problems with files rights"
	exit 1
fi

function setPackageManager() 
{
	if ! which "$1" > /dev/null; 
	then
	   	echo "Package Manager '$1' not found!"
	else 
		packageManager="$1"
		echo "Package Manager '$packageManager' found!"
	fi
}

# Check for package manager to install dependencies
packageManager=""
if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    echo "Detected Mac platform"
    setPackageManager "brew"      
	if [ "$packageManager" == "" ]; then 
		setPackageManager "port" 
	fi
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under Linux platform
    echo "Detected Linux platform"
    setPackageManager "apt-get"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
    echo "Detected Windows NT Platform"
fi
if [ "$packageManager" == "" ]; then 
	setPackageManager "apt-get" # Default is Ubuntu's apt-get
fi
if [ "$packageManager" == "" ]; then 
	echo "Enter your Operating System's Package Manager: "
	read
	setPackageManager "$REPLY"
fi
if [ "$packageManager" == "" ]; then 
	echo "No package manager."
	exit 1
fi
# Install
packages="sox wget qt" # dialog, pygtk, espeak, argparse, xautomation, xvkbd
command="$packageManager install $packages"
echo
echo "Installing dependencies..."
# Mac's Brew does not run as Root
if [ "$packageManager" == "brew" ]; then
	eval "$command"
elif which "gksu"
then
    gksu -S "$command"
elif which "kdesudo"
then
    kdesudo "$command"
else
    eval "sudo $command"
fi

# Install Python Arg-parse
<<'COMMENT'
pythonPackages="argparse watchdog" #pyinotify
echo
if ! which "pip" > /dev/null; 
then
   	echo "Python Package Manager *pip* not found!"
   	echo "See http://www.pip-installer.org/en/latest/installing.html for installation information."
   	exit 1
else
	echo "Installing Python packages." 
	command="pip install $pythonPackages"
	if which "gksu"
	then
	    gksu -S "$command"
	elif which "kdesudo"
	then
	    kdesudo "$command"
	else
	    eval "sudo $command"
	fi
fi
COMMENT

DIR="$(pwd)" # Save directory
cd "$(./getInstallDir.sh)"
echo
echo "Assuming all files are in '$DIR'"
mkdir temp > /dev/null 2>&1
echo "Compiling recognition query engine..."
cd recognition
touch src/dictionary.c
touch log.txt
make >> log.txt 2>&1
echo "Done"
echo
cd ..
echo "Compiling the On-Screen Display"
cd microphone
touch osd_server.cpp
touch log.txt
# qmake -project >> log.txt 2>&1 
qmake >> log.txt 2>&1
make >> log.txt 2>&1
echo "Done"
echo
cd ..

echo "Removing old dictionaries."
rm recognition/modes/main.dic  > /dev/null 2>&1
rm -r recognition/bin/  > /dev/null 2>&1
rm $USER_DIR/plugins.db  > /dev/null 2>&1
rm $USER_DIR/UserInfo  > /dev/null 2>&1
rm -r $USER_DIR/configs  > /dev/null 2>&1
echo "Configuring setup."
mkdir $USER_DIR/ > /dev/null 2>&1
cp -r recognition/config/defaultBin recognition/bin 
#touch $USER_DIR/UserInfo
#cp recognition/config/BlankInfo $USER_DIR/UserInfo
touch recognition/modes/main.dic
cp recognition/config/defaultMain.dic recognition/modes/main.dic

#cd "$DIR" # Restore directory
cd bin/

# ./installDefault # see issue #9
echo
read -p "Would you like to setup user account? [Y/n]: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# Yes, setup user
    ./setupUser.sh
fi

# nohup Recognition/bin/goto 'http://palaver.bmandesigns.com/thanks' "nohup.out" &
echo "Done, you will have to setup the hotkey yourself."

