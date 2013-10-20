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

message="Options :
-i <name> : Install a plugin .sp
-r <name> : Remove the specified plugin
-p <name> : Install <name> from the repo
-d <name> : Display info on a plugin
-l        : List all plugins installed
-L        : List all plugins in repo
-f        : Force installation with no confirmation.
-a        : Install plugins in the palaver directory
"

current_dir=$(pwd)
# Plugin directory :
dir="$HOME/.leopold/Plugins/"

palaver_dir=$RESULT # "$(dirname $(readlink -f $0))"
install_name=""
remove_name=""
repo_name=""
info_name=""
list=false
list_repo=false
stop=true
while getopts ":i:r:p:d:lLfa" opts
do
    case $opts in
	i) install_name=$OPTARG; stop=false ;;
	r) remove_name=$OPTARG; stop=false ;;
	p) repo_name=$OPTARG; stop=false ;;
	d) info_name=$OPTARG; stop=false ;;
	l) list=true; stop=false ;;
	L) list_repo=true; stop=false ;;
	a) dir="${palaver_dir}/Plugins/" ;;
	\?) echo "$message"; exit 1 ;;
	:) echo "$message"; exit 1 ;;
    esac
done
if "$stop"
then
    echo "$message"
    exit 1
fi
remove_name=$(echo "$remove_name" | grep -e "^[a-zA-Z0-9_ ]\+$")
repo_name=$(echo "$repo_name" | grep -e "^[a-zA-Z0-9_ ]\+$")
info_name=$(echo "$info_name" | grep -e "^[a-zA-Z0-9_ ]\+$")

# Remove plugin
if [ ! -z "$remove_name" ]
then
    if [ -d "${dir}${remove_name}" ]
    then
	rm -r "${dir}${remove_name}"
	echo "The plugin $remove_name has been removed"
    else
	echo "The plugin $remove_name isn't installed"
    fi
fi

# Install from repo
if [ ! -z "$repo_name" ]
then
    echo -n "Récupération de ${repo_name}..."
    url="http://palaver.bmandesigns.com/functions.php?f=download&t=name&s=${repo_name}"
    install_name="/tmp/${repo_name}.sp"
    rm "$install_name" &> /dev/null
    wget -q -O "$install_name" "$url"
    echo "Done"    
fi

# Install file
if [ ! -z "$install_name" ]
then
    if [ -e "$install_name" ]
    then
	echo "Installing $install_name..."
	# Name of the plugin
	folder=$(tar -tvf "$install_name"  | grep -e "^d" | grep -o -e " [^/ ]*/$" | head -n 1 | sed 's/ *//g')
	add=""
	# If it is an old version plugin :
	if [ -z "$folder" ]
	then
	    name=$(echo "$install_name" | grep -o "[^/]*$")
	    add="${name%.*}/"
	fi
	# We remove the old plugin
	rm -r "${dir}${add}${folder}" &> /dev/null
	if [ ! -z "$add" ]
	then
	    mkdir "${dir}${add}"
	fi	    
	tar -C "${dir}${add}" -xvf "$install_name"
	echo "Plugin successfully installed in ${dir}${add}${folder}"
	echo "Plugin successfully installed in ${dir}${add}${folder}" > InstallResult
    else
	echo "Fichier $install_name not found"
	echo "Fichier $install_name not found" > InstallResult
    fi
fi  


# List installed
if "$list"
then
    echo "--- Plugins in ${palaver_dir}/Plugins/"
    ls -d ${palaver_dir}/Plugins/*/ -1 | grep -o -e "/[^/]*/$" | sed 's,/,,g'
    echo -e "\n--- Plugins in $dir"
    ls -d ${dir}*/ -1 | grep -o -e "/[^/]*/$" | sed 's,/,,g'
fi

# List repo
if "$list_repo"
then
    url="http://palaver.bmandesigns.com/plugins"
    echo -e "Plugins dans le repo $url :\n"
    wget -O - -q "$url" | grep "<h2>Plugins" | sed 's,</tr>,</tr>\n,g' | sed '/\/table/,$d' | sed '1,/<tr>/d' | sed 's/<[^>]*>/|/g' | sed 's/|\+/|/g' | awk -F "|" '{print $2,"(Version",$4")"}'
fi

# Display info
if [ ! -z "$info_name" ]
then
    if [ -e "${dir}/${info_name}/plugin.info" ]
    then
	cat "${dir}/${info_name}/plugin.info"
    elif [ -e "${palaver_dir}/Plugins/${info_name}/plugin.info" ]
    then
	cat "${palaver_dir}/Plugins/${info_name}/plugin.info"
    else
	echo "Plugin $info_name not found."
    fi
fi

cd "$current_dir"
