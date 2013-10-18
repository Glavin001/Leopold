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

# TODO
# Look for CONFIG file to see if it has SOUND or VISUAL set
# And display accordingly

if [ -e "speech.pid" ];then
    read PID_OF_SPEECH < speech.pid
    sleep .1 # This is so the end of the speech doesn't get cut off.
    kill $PID_OF_SPEECH

    ./pycmd wait
    while kill -s 0 $PID_OF_SPEECH 2>/dev/null;do
    :
    done
    RESULT="$(./send_speech.py speech.flac)"
    echo "$RESULT" > last_command.log
    ./recognize "$RESULT"

    # Only takes effect if a script did not use pycmd result
    if [ ! -e "microphone/result" ];then
	./pycmd done
    fi

    rm speech.pid
else
    ./pycmd stop
    > speech.flac
    rec -r 16000 -q -b 16 speech.flac 2>/dev/null & 
    echo $! > "speech.pid"
    # Checks when recording starts
    while [ "$(stat -c%s speech.flac)" == "0" ];do
    	:
    done
    ./pycmd record
fi
