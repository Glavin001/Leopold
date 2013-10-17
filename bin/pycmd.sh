#!/bin/bash

# right now it uses moving of files, but we may want to communicate with the
# python script another way.

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
echo "$(dirname "$RESULT")"


function error() {
    echo "Accepted modes:"
    echo "wait"
    echo "done"
    echo "stop"
    echo "record"
    echo "result"
}

if [ -z "$1" ];then
    error
fi

if ps auxww |grep -v grep |grep osd_server > /dev/null 2>&1;then
    : # we are good, the server is there
else # otherwise start it
    ./Microphone/osd_server.py 2>/dev/null & 
	echo $! > "osd.pid"
fi  
if ps auxww |grep -v grep |grep indicator_server.py > /dev/null 2>&1;then
    : # we are good, the server is there
else # otherwise start it
    ./Microphone/indicator_server.py 2>/dev/null & 
    echo $! > "indicator.pid"
fi    
# This should be run from the base dir.
cd Microphone

case "$1" in
    wait)
	rm pycmd_*
	touch pycmd_wait
	;;
    done)
	rm pycmd_*
	touch pycmd_done
	;;
    stop)
	rm pycmd_*
	touch pycmd_stop
	;;
    record)
	rm pycmd_*
	touch pycmd_record
	;;
    result)
	rm pycmd_*
	touch pycmd_result
	;;
    *)
	error
	;;
esac

