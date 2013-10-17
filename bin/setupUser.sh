#!/bin/bash

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
echo -n "Enter your language (en=English) [ENTER]: "
read lang

echo "Saving user."

cd "$(./getInstallDir.sh)"

cp recognition/config/BlankInfo "$USER_DIR/UserInfo"
cat > "$USER_DIR/UserInfo" << EOL
FIRST=${firstName}
LAST=${lastName}
EMAIL=${email}
LANGUAGE=${lang}
EOL

echo "Done."
echo