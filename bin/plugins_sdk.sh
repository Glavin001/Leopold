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
cd ..

message="Options :
-c <name> : Create package name
-p <name> : Package name
-u <name> : Update the plugin.info file
-d        : If present, in current directory, if not in .leopold/Plugins
-n        : Non interactive mode (don't run editor with plugin.info)
-f        : Remove the package without asking if package already exists"

current_dir=$(pwd)
dir="$HOME/.leopold/Plugins/"
interactive=true
ask=true
while getopts ":dc:p:u:nf" opts
do
    case $opts in
	d) dir=$(pwd) ;;
	c) create_name=$OPTARG ;;
	p) package_name=$OPTARG ;;
	u) update_name=$OPTARG ;;
	n) interactive=false ;;
	f) ask=false ;;
	\?) echo "$message" exit 1 ;;
	:) echo "$message" exit 1 ;;
    esac
done


# This script create a plugin from this structure (The files .pre are
# put at the root of the file because it must be at the root of
# .leopold/Plugins/ ):

# Test
#  plugin.info
#  <modes>.pre
#  bin
#   links_to_existing_bins
#  config
#   links_to_existing_configs
#  modes
#   main.dic // empty except for comments on what to do maybe
#   main-en.dic

if [ -z "$create_name" ] && [ -z "$package_name" ] && [ -z "$update_name" ]
then
    echo "$message"
fi

create_name=$(echo "$create_name" | grep -e "^[a-zA-Z0-9_ ]\+$")
package_name=$(echo "$package_name" | grep -e "^[a-zA-Z0-9_ ]\+$")
update_name=$(echo "$update_name" | grep -e "^[a-zA-Z0-9_ ]\+$")
if [ -z "$create_name" ] && [ -z "$package_name" ] && [ -z "$update_name" ]
then
    echo "Please use only letters, numbers and underscores in your package name."
    exit 1
fi

cd "$dir"
# We create a plugin
if [ ! -z "$create_name" ]
then
    name="$create_name"
    
    USER_DIR=$HOME/.leopold
    while read line           
    do           
	export "$line"           
    done <$USER_DIR/UserInfo
    if [ -d "$name" ] && $ask
    then
	read -p "This Plugin already exists. Do you want to continue ? (y/n) " answer
	if [ "$answer" != "y" ] && [ "$answer" != "Y" ]
	then
	    echo "See you later "'!'
	    exit 1
	fi
    fi
    rm -r "$name" &>/dev/null
    mkdir "$name"
    cd "$name"
    echo "name = $name
authors = $FIRST $LAST
version = 1.0
languages =
configs = settings.conf
bin = 
depends =
provides =
description = The plugin $name
actions =
" > plugin.info
    mkdir bin
    mkdir config
    mkdir modes
    touch config/settings.conf
    touch modes/main.dic
    touch modes/main-en.dic
    echo "The plugin has been created in $(pwd)"
fi

# Package a plugin
if [ ! -z "$package_name" ]
then
    name="$package_name"
    if [ -d "$package_name" ]
    then
	if $interactive
	then
	    editor "${name}/plugin.info"
	fi
	tar -cf "${name}.sp" --transform "s|${name}/(.*)\.pre$|\1.pre|x" --transform "s|~$||" "${name}/"
	echo "This package has been successfully created in $(pwd)/${name}.sp"
    else
	echo "Error : The package $name doesn't exist in $(pwd).
If you want to run the script in the current directory please use the option -d"
	exit 1
    fi
fi

# Update a plugin
if [ ! -z "$update_name" ]
then
    name="$update_name"
    if [ ! -d "$name" ]
    then
	echo "Error : The package $name doesn't exist in $(pwd).
If you want to run the script in the current directory please use the option -d"
	exit 1
    else
	cd "$name"
	# Languages :
	echo -n "Language..."
	languages=$(find . -type f | grep -e "^.*-[A-Za-z]\+\.dic$" | sed 's/^.*-\([A-Za-z]\+\)\.dic$/\1/' | sort | uniq | tr '\n' ' ' | sed 's/ $//')
	sed -i -e "s|^languages.*$|languages = $languages|g" plugin.info
	echo "Done"
	
	# Config
	echo -n "Config..."
	config_files=$(find config/ -type f | grep -e "config/\(.*\.conf\)$" | sed 's|config/\(.*\.conf\)$|\1|' | sort | uniq | tr '\n' ' ' | sed 's/ $//')
	sed -i -e "s|^configs.*$|configs = ${config_files}|g" plugin.info
	echo "Done"
	
	# Bin (from any plugin)
	echo -n "Bin..."
	bin_files=""
	while read -r file
	do
	    bin=$(cat "$file" | grep -e "^ " | sed 's/^ *//g' | cut -d' ' -f1)
	    bin_files=$(echo -e "${bin}\n${bin_files}")
	done < <(find modes/ -type f)
	bin_files=$(echo "$bin_files" | sort | uniq | tr '\n' ' ' | sed 's/ $//')
	sed -i -e "s/^bin.*$/bin = ${bin_files}/g" plugin.info
	echo "Done"
	
	# depends (like espeak)
	echo -n "Depends..."
	depends_files=""
	while read -r file
	do
	    tmp=$(cat "$file" | grep -e "^#@depends:* " | sed 's/^#@depends:* *//g')
	    depends_files=$(echo -e "${tmp}\n${depends_files}")
	done < <(find bin/ -type f)
	depends_files=$(echo "$depends_files" | sort | uniq | tr '\n' ' ' | sed 's/ *$//')
	sed -i -e "s/^depends.*$/depends = $depends_files/g" plugin.info
	echo "Done"
	
	# provides
	echo -n "Provides..."
	provides_files=$(find bin/ -type f | grep -e "bin/.*$" | sed 's|bin/\(.*\)$|\1|' | tr '\n' ' ' | sed 's/ $//')
	sed -i -e "s/^provides.*$/provides = $provides_files/g" plugin.info
	echo "Done"
	
	# Actions
	echo -n "Actions..."
	action="action=
# For all languages :
"
	while read -r file
	do
	    tmp=$(cat "$file" | grep -e "#@:" | sed 's/^#@://')
	    action="$action
$tmp"
	done < <(find modes/ -type f | grep -e "^[^\-]*.dic$")

	while read -r lang
	do
	    action="$action
# Language : ${lang}"
	    while read -r file
	    do
		tmp=$(cat "$file" | grep -e "#@:" | sed 's/^#@://')
		action="$action
$tmp"
	    done < <(eval "find modes/*-${lang}.dic -type f")
    	done < <(echo "$languages" | tr ' ' '\n')
	action=$(echo "$action" | sed '/^$/d' | sed 's/^#/\n#/g')
	sed -i '/^action/,$d' plugin.info
	echo "$action" >> plugin.info
	echo -e "Done\n"
	echo "$interactive"
	if $interactive
	then
	    editor plugin.info
	fi
	echo "********* plugin.info *********"
	cat "plugin.info"
	echo -e "*******************************\n"
	echo "This package has been successfully updated in $(pwd)/${name} !
You can know package it with plugin_sdk -p ${name}"
    fi
fi


cd "$current_dir"

