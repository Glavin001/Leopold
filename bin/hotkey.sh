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
   #  along with this 



# Go to the install directory (follow the symlink)
cd "$(dirname $(readlink -f $0))"

# To think of it, it should be the only places we call config too, if other
# scripts need those variables, they should be exported.
. CONFIG

if [ -z "$HOTKEY" ];then
    HOTKEY="switch"
fi

if [ "$HOTKEY" == "switch" ];then
    ./hotkey_switch
fi

# We would check for other possibilities below.
