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

echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-603/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-604/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-605/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-606/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-607/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-608/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-609/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-610/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-611/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-612/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-613/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-614/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-615/new_device

FIRMWARE_VERSION_FILE=/var/log/firmware_versions
rm -rf ${FIRMWARE_VERSION_FILE}
echo "BIOS: `dmidecode -s system-version `" > $FIRMWARE_VERSION_FILE
## Get FPGA version
r=`/usr/bin/pcisysfs.py  --get --offset 0x00 --res /sys/bus/pci/devices/0000\:04\:00.0/resource0 | sed  '1d; s/.*\(....\)$/\1/; s/\(..\{1\}\)/\1./'`
r_min=$(echo $r | sed 's/.*\(..\)$/0x\1/')
r_maj=$(echo $r | sed 's/^\(..\).*/0x\1/')
echo "FPGA: $((r_maj)).$((r_min))" >> $FIRMWARE_VERSION_FILE

## Get BMC Firmware Revision
r=`ipmitool mc info | awk '/Firmware Revision/ { print $NF }'`
echo "BMC: $r" >> $FIRMWARE_VERSION_FILE

#System CPLD 0x31 on i2c bus 601 ( physical FPGA I2C-2)
r_min=`/usr/sbin/i2cget -y 601 0x31 0x0 | sed ' s/.*\(0x..\)$/\1/'`
r_maj=`/usr/sbin/i2cget -y 601 0x31 0x1 | sed ' s/.*\(0x..\)$/\1/'`
echo "System CPLD: $((r_maj)).$((r_min))" >> $FIRMWARE_VERSION_FILE

#Slave CPLD 1 0x30 on i2c bus 600 ( physical FPGA I2C-1)
r_min=`/usr/sbin/i2cget -y 600 0x30 0x0 | sed ' s/.*\(0x..\)$/\1/'`
r_maj=`/usr/sbin/i2cget -y 600 0x30 0x1 | sed ' s/.*\(0x..\)$/\1/'`
echo "Slave CPLD 1: $((r_maj)).$((r_min))" >> $FIRMWARE_VERSION_FILE

#Slave CPLD 2 0x31 on i2c bus 600 ( physical FPGA I2C-1)
r_min=`/usr/sbin/i2cget -y 600 0x31 0x0 | sed ' s/.*\(0x..\)$/\1/'`
r_maj=`/usr/sbin/i2cget -y 600 0x31 0x1 | sed ' s/.*\(0x..\)$/\1/'`
echo "Slave CPLD 2: $((r_maj)).$((r_min))" >> $FIRMWARE_VERSION_FILE

#Slave CPLD 3 0x32 on i2c bus 600 ( physical FPGA I2C-1)
r_min=`/usr/sbin/i2cget -y 600 0x32 0x0 | sed ' s/.*\(0x..\)$/\1/'`
r_maj=`/usr/sbin/i2cget -y 600 0x32 0x1 | sed ' s/.*\(0x..\)$/\1/'`
echo "Slave CPLD 3: $((r_maj)).$((r_min))" >> $FIRMWARE_VERSION_FILE

#Slave CPLD 3 0x32 on i2c bus 600 ( physical FPGA I2C-1)
r_min=`/usr/sbin/i2cget -y 600 0x33 0x0 | sed ' s/.*\(0x..\)$/\1/'`
r_maj=`/usr/sbin/i2cget -y 600 0x33 0x1 | sed ' s/.*\(0x..\)$/\1/'`
echo "Slave CPLD 4: $((r_maj)).$((r_min))" >> $FIRMWARE_VERSION_FILE

#Determine type of system start
#System CPLD 0x31 on i2c bus 601 ( physical FPGA I2C-2), CPU reboot cause
REBOOT_CAUSE=0x9
r=$((`/usr/sbin/i2cget -y 601 0x31 $REBOOT_CAUSE` & 0xff))

rm -f /tmp/opx_start_*
case $r in
    128)
        # Cold reboot (NPU and other hardware reset 0x80, bit 7)
        t=cold
        ;;
    64)
        # Warm reboot (NPU and other hardware not reset 0x40, bit 6)
        t=warm
        ;;
    32)
        # Thermal shutdown (Thermal 0x20, bit 5)
        t=thermal
        ;;
    16)
        # Watchdog expired (WDI triggered 0x10, bit 4)
        t=watchdog
        ;;
    8)
        # BIOS switch over (0x8, bit 3)
        t=bios
        ;;
    4)
        # Boot Failure (System boot failed 0x4, bit 2)
        t=boot
        ;;
    2)
        # CPU Initiated Shutdown (0x2, bit 1)
        t=cpu
        ;;
    1)
        # Power failure (or Power Cycle 0x1, bit 0)
        t=power
        ;;
    *)
        # Unknown reason (Including Power Cycle)
        t=unknown
        ;;
esac

if [[ "$t" != "unknown" ]]
then
    touch /tmp/opx_start_$t
fi

# HW requires write clear
/usr/sbin/i2cset -y 601 0x31 $REBOOT_CAUSE 0
