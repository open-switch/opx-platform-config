#!/bin/bash

# Copyright (c) 2018 Dell EMC.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT
# LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS
# FOR A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
#
# See the Apache Version 2.0 License for specific language governing
# permissions and limitations under the License.
#

# Platform specific script to trigger reset/shdutdown of all hw components
# in addition to the CPU.


function platform_reset {

    # reset the system
    /usr/bin/portiocfg.py --set --val 0xE --offset 0xCF9

    # If reset was successful, this line will not be reached.
    # Hence the fact we are here implies reset failed.
    echo "Platform_reset failed.  Some components might not have been reset" > /dev/console

}

function platform_poweroff {

    # poweroff the system
    :
}

case "$1" in
    "poweroff")
        platform_poweroff
        ;;
    "reboot")
        platform_reset
        ;;
esac
