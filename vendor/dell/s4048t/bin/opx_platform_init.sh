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
echo pca9548 0x70 >/sys/devices/pci0000:00/0000:00:13.0/i2c-?/new_device

# Wait for i2c devices to appear
i2c_wait_range 2 10

# Now create a file to hold the firmware versions.
FIRMWARE_VERSION_FILE=/var/log/firmware_versions
rm -rf ${FIRMWARE_VERSION_FILE}
echo "BIOS: `dmidecode -s system-version `" > $FIRMWARE_VERSION_FILE
# Get System CPLD version
echo "System CPLD: $((`i2cget -y 2 0x31 8` & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get Master CPLD version
echo "Master CPLD: $((`i2cget -y 2 0x32 0x12` & 0xf))" >> $FIRMWARE_VERSION_FILE

# Determine type of system start

rm -f /tmp/opx_start_*
r=$((`i2cget -y 2 0x31 0xb` & 0xff))
case $r in
    127)
        # Cold reboot (NPU and other hardware reset 0x7f, bit 7 triggered)
        t=cold
        ;;
    191)
        # Warm reboot (NPU and other hardware not reset 0xbf, bit 6 triggered)
        t=warm
        ;;
    223)
        # Thermal shutdown (0xdf, bit 5 triggered)
        t=thermal
        ;;
    239)
        # Watchdog expired (WDI triggered 0xef, bit 4 triggered)
        t=watchdog
        ;;
    247)
        # Warm BIOS switch over (0xf7, bit 3 triggered)
        t=bios
        ;;
    251)
        # Boot Failure ( System boot failed 0xfb, bit 2 triggered)
        t=boot
        ;;
    *)
        # Unknown reason (Including Power Cycle, any reason not supported by HW)
        t=unknown
        ;;
esac

if [[ "$t" != "unknown" ]]
then
    touch /tmp/opx_start_$t
fi
