#!/bin/bash

# Copyright (c) 2018 Dell Inc.
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
    count=0;

    while [ $count -lt 3 ]
    do
        # reset via CPLD
         /usr/bin/portiocfg.py --set --val 0xaa  --offset 0x113

        let "count = count + 1"
    done

    # If reset was successful, this line will not be reached.
    # Hence the fact we are here implies reset failed.
    echo "Platform_reset failed.  Some components might not have been reset" > /dev/console

}

function platform_poweroff {
    # reset via PS0_ON and PS1_ON registers of MASTER_CPLD
    # But then right now the CPLD seems to reset instead of power-down
    # TBD: Use ":" below to denote null function till actual functionality comes
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

