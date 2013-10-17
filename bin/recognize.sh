#!/bin/bash

   # This program is free software: you can redistribute it and/or modify
   #  it under the terms of the GNU General Public License as published by
   #  the Free Software Foundation, either version 3 of the License, or
   #  (at your option) any later version.

   #  This program is distributed in the hope that it will be useful,
   #  but WITHOUT ANY WARRANTY; without even the implied warranty of
   #  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   #  GNU General Public License for more details.

   #  You should have received a copy of the GNU General Public License
   #  along with this program.  If not, see <http://www.gnu.org/licenses/>.
# TODO, make this use the mode, context and custom sed script

cd ${0%/*}
#USER_DIR=$HOME/.palaver.d
USER_DIR="$(./getUserDir.sh)"

# Go to the install directory (follow the symlink)
#cd "$(dirname $(./readlinkF $0))"
cd "$(./getInstallDir.sh $0)"

while read line           
do           
    export "$line"           
done < "$USER_DIR/UserInfo"

# Try to run a command in ./recognition/bin with useful errors.
function run_command() {
    while read line           
    do           
	export "$line"           
    done <"$USER_DIR/UserInfo"
    bin=$(./recognition/find_bin "${1%% *}" "${USER_DIR}/Plugins/" "./Plugins/")
    if [ ! -z "$bin" ]
    then
	eval "'$bin' ${1#* }"	
	if [ $? != 0 ];then
	    ./recognition/bin/result Error "There was an error while running:" \
		"$1" ""
	    exit 1
	fi
    else
	./recognition/bin/result Error "File not found :" \
	    "$1" ""
	exit 1
    fi
}

read mode < MODE.txt

speech="$1"

# Use sed scripts here.
if [ -z "$speech" ];then
    echo "Speech unable to be transcribed."
    ./recognition/bin/result "Speech unable to be transcribed"
    exit 1
fi

rm Microphone/result 2>/dev/null

echo "Before treatment : $speech" > last_speech.log

# Make a first transformation to the file depending on the mode
# The file must be at the root of the plugin directory with the name :
# <mode>.pre
# and if you want something specific for a language in addition :
# <mode>-<language>.pre (it is executed after <mode>.pre)

command="echo \"${speech}\""
while read -r line
do
    if [ -e "$line" ]
    then
	command="$command | $line"
    fi
done < <(echo "./Plugins/${mode}.pre
${USER_DIR}/Plugins/${mode}.pre
./Plugins/${mode}-${LANGUAGE}.pre
${USER_DIR}/${mode}-${LANGUAGE}.pre")

speech=$(eval $command) 
echo "After treatment : $speech" >> last_speech.log

# We search in .palader.d/personal.dic
if [ -e "$USER_DIR/personal.dic" ];then
    COMMAND=$(./recognition/dictionary "$speech"\
 "$USER_DIR/personal.dic")

    EXIT=$?
    if [ "$EXIT" == 0 ];then

	run_command "$COMMAND"

	exit 0
    fi
    if [ "$EXIT" != 2 ];then
	echo "There is an error in $USER_DIR/personal.dic"
    fi
fi
# We search in the .palader.d/Plugins directory
if [ -d "$USER_DIR/Plugins" ];then
    # With old versions, replace main with actions
    add=""
    if [ "$mode" == "main" ]
    then
	add="\n$(./recognition/find_dic actions "${USER_DIR}/Plugins" $LANGUAGE)"
    fi
    # We read dictionnaries :
    while read -r dictionary
    do
	if [ ! -z "$dictionary" ]
	then
	    COMMAND=$(./recognition/dictionary "$speech"\
 "$dictionary")
	    
	    EXIT=$?
	    if [ "$EXIT" == 0 ];then
		run_command "$COMMAND"
		exit 0
	    fi
	    if [ "$EXIT" != 2 ];then
		echo "There is an error in $dictionary"
	    fi
	fi
    done < <(echo -e "$(./recognition/find_dic $mode "${USER_DIR}/Plugins" $LANGUAGE)$add")
fi

# We search in the <installation>/Plugins directory
if [ -d "Plugins" ];then
    add=""
    if [ "$mode" == "main" ]
    then
	add="\n$(./recognition/find_dic actions Plugins $LANGUAGE)"
    fi
    while read -r dictionary
    do
	if [ ! -z "$dictionary" ]
	then
	    COMMAND=$(./recognition/dictionary "$speech"\
 "$dictionary")
	    
	    EXIT=$?
	    if [ "$EXIT" == 0 ];then
		run_command "$COMMAND"
		exit 0
	    fi
	    if [ "$EXIT" != 2 ];then
		echo "There is an error in $dictionary"
	    fi
	fi
    done < <(echo -e "$(./recognition/find_dic $mode Plugins $LANGUAGE)$add")
fi

if [ "$EXIT" == 2 ];then
    ./recognition/bin/result Error "'$speech'" "is not a recognized command" ""

else 
    echo "There is an error in ${dictionary}"
    ./recognition/bin/result Error "There was an error while reading $dictionary" \
	"$COMMAND" ""
fi
