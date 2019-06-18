#!/bin/bash
# Copyright (c) 2015 Dell Inc.
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

. /etc/opx/opx-environment.sh

# Replace modules with custom versions
for mod in i2c-ismt igb
do
    /sbin/rmmod $mod
    /sbin/insmod /lib/modules/`uname -r`/updates/${mod}.ko
done    

# Check existence of I2C device
function i2c_chk {
    test -e /dev/i2c-$1
}

# Check existence of a range of I2C devices
function i2c_chk_range {
    local i
    i=$1
    while [[ $i -lt $2 ]]
    do
        i2c_chk $i
        if [[ $? -ne 0 ]]
        then
            false
            return
        fi
        i=$(($i + 1))
    done
    true
}

# Wait until a range of I2C devices exist
function i2c_wait_range {
    while true
    do
        i2c_chk_range $1 $2
        if [[ $? -eq 0 ]]
        then
            break
        fi
        sleep 0.5
    done
}

# Wait for i2c devices to appear
i2c_wait_range 0 2

#SMBus Controller 2.0 SPGT register to 0x00000005 to tune 80KHz frequency
/usr/bin/pcisysfs.py --set --val 0x00000005 --offset 0x300 --res "/sys/devices/pci0000:00/0000:00:13.0/resource0"
sleep 0.5

#register and initializes PCA954x mux
echo pca9548 0x73 >/sys/devices/pci0000:00/0000:00:13.0/i2c-?/new_device

# Wait for i2c devices to appear
i2c_wait_range 2 10

echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-8/new_device
echo pca9548 0x72 > /sys/bus/i2c/devices/i2c-8/new_device

# Wait for i2c devices to appear
i2c_wait_range 10 26

#Forcibly bring quad-port phy out of reset for 48-1G port functionality
/usr/bin/portiocfg.py --set --val 0x1f --offset 0x222

# Now create a file to hold the firmware versions.
FIRMWARE_VERSION_FILE=/var/log/firmware_versions
rm -rf ${FIRMWARE_VERSION_FILE}
# Get BIOS version
echo "BIOS: `dmidecode -s system-version `" > $FIRMWARE_VERSION_FILE
# Get MMC CPLD version
r=`/usr/bin/portiocfg.py --get --offset 0x100 | sed 's/reg value //'`
echo "MMC CPLD: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get SMC CPLD version
r=`/usr/bin/portiocfg.py --get --offset 0x200 | sed 's/reg value //'`
echo "SMC CPLD: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE

# Determine type of system start

rm -f /tmp/opx_start_*
r=`/usr/bin/portiocfg.py --get --offset 0x112 | sed 's/reg value //'`
case $r in
    11)
        # Power-on
        t=power
        ;;
    33)
        # Watchdog expired
        t=watchdog
        ;;
    44)
        # Cold reboot (NPU and other hardware reset)
        t=cold
        ;;
    55)
        # Warm reboot (NPU and other hardware not reset)
        t=warm
        ;;
    *)
        # Unknown reason
        t=unknown
        ;;
esac
touch /tmp/opx_start_$t
