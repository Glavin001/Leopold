#!/bin/bash

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


echo "Setting up your user account."

USER_DIR="$(./getUserDir.sh)"

mkdir "$USER_DIR" > /dev/null 2>&1
touch "$USER_DIR/UserInfo"

echo "I will need your personal information to create your account."
echo -n "Enter your first name [ENTER]: "
read firstName
echo -n "Enter your last name [ENTER]: "
read lastName
echo -n "Enter your email [ENTER]: "
read email
echo -n "Enter your language (en=English,es,fr,pt) [ENTER]: "
read lang

echo "Saving user."

cd "$(./getInstallDir.sh)"

cp recognition/config/BlankInfo "$USER_DIR/UserInfo"
cat > "$USER_DIR/UserInfo" << EOL
FIRST=${firstName}
LAST=${lastName}
EMAIL=${email}
LANGUAGE=${lang}
COMPUTER_SPEAK=true
COMPUTER_CALL=true
COMPUTER_HELLO=hello computer
COMPUTER_GOODBYE=goodbye
EOL

echo "Done."
echo