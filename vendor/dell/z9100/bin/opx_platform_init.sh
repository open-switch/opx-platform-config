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

# Set up I2C busses
echo pca9547 0x70 >/sys/devices/pci0000:00/0000:00:13.0/i2c-?/new_device
sleep 0.5
echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-4/new_device
echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-6/new_device
echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-7/new_device
echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-8/new_device
echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-9/new_device

#SMBus Controller 2.0 SPGT register to 0x00000005 to tune 80KHz frequency
/usr/bin/pcisysfs.py --set --val 0x00000005 --offset 0x300 --res "/sys/devices/pci0000:00/0000:00:13.0/resource0"
sleep 0.5

FIRMWARE_VERSION_FILE=/var/log/firmware_versions
rm -rf ${FIRMWARE_VERSION_FILE}
echo "BIOS: `dmidecode -s system-version `" > $FIRMWARE_VERSION_FILE
# Get SMF version
r=`/usr/bin/portiocfg.py --get --offset 0x200 | sed 's/reg value //'`
echo "SMF: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get CPLD1 version
r=`/usr/bin/portiocfg.py --get --offset 0x100 | sed 's/reg value //'`
echo "CPLD1: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get CPLD2 version
/usr/sbin/i2cset -y 14 0x3e 0 0
r=`/usr/sbin/i2cget -y 14 0x3e`
echo "CPLD2: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get CPLD3 version
/usr/sbin/i2cset -y 15 0x3e 0 0
r=`/usr/sbin/i2cget -y 15 0x3e`
echo "CPLD3: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get CPLD4 version
/usr/sbin/i2cset -y 16 0x3e 0 0
r=`/usr/sbin/i2cget -y 16 0x3e`
echo "CPLD4: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE

# Determine type of system start

rm -f /tmp/opx_start_*
r=`/usr/bin/portiocfg.py --get --offset 0x20a | sed 's/reg value //'`
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
