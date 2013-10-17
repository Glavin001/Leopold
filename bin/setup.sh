#!/bin/bash

# Setup speech recognition for the person.
# Do NOT run this script as root, because it can cause problems with files rights

command="apt-get install sox python-argparse wget espeak xautomation xvkbd -y"

if which "gksu"
then
    gksu -S "$command"
elif which "kdesudo"
then
    kdesudo "$command"
else
    eval "sudo $command"
fi

DIR="$(pwd)"

echo Assuming all files are in "'$DIR'"

touch Recognition/dictionary.c
cd Recognition
make
cd ..
rm Recognition/modes/main.dic
rm Recognition/bin/ -r
rm $HOME/.palaver.d/plugins.db
rm $HOME/.palaver.d/UserInfo
rm $HOME/.palaver.d/configs -r
mkdir $HOME/.palaver.d/
mkdir $HOME/.palaver.d/Plugins/
cp Recognition/config/defaultBin Recognition/bin -r
touch $HOME/.palaver.d/UserInfo
cp Recognition/config/BlankInfo $HOME/.palaver.d/UserInfo
touch Recognition/modes/main.dic
cp Recognition/config/defaultMain.dic Recognition/modes/main.dic
./installDefault
nohup Recognition/bin/goto 'http://palaver.bmandesigns.com/thanks' "nohup.out" &
echo "Done, you will have to setup the hotkey yourself."
