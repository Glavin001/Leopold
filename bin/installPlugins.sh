#!/bin/bash

#IN='82a8-bd7d-986d-9dc9-41f5-fc02-2c20-3175-097a-c1eb'
# IN='|#|browser|#|DateDisplay|#|FileBrowser|#|GoogleMaps|#|InternetSearch|#|MediaControl|#|NoteToSelf|#|ScreenPlugin|#|SportsScores|#|UnityDash|#|UserInformation'
IN="$(curl "http://palaver.bmandesigns.com/functions.php?f=corePlugins" )"

OIFS=$IFS                   # store old IFS in buffer
IFS='|#|'                     # set IFS to '-'

for i in ${IN[@]}    # traverse through elements
do
  echo $i
  #arr[$j]=$i
done
IFS=$OIFS                   # reset IFS to default (whitespace)

exit

IN="$(curl "http://palaver.bmandesigns.com/functions.php?f=corePlugins" )"
echo $IN
IFS="|#|" && plugins=($*) 
echo "${plugins[@]}" 
echo "${plugins[0]}" 
echo "${plugins[1]}" 
