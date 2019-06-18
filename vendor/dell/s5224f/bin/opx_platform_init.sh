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
i2c_wait_range 600 607

echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-603/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-604/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-605/new_device
echo pca9548 0x74 > /sys/bus/i2c/devices/i2c-606/new_device

# Wait for i2c devices to appear
i2c_wait_range 2 34

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
#System reboot cause
REBOOT_CAUSE=0x18
r=`/usr/bin/pcisysfs.py --get --offset $REBOOT_CAUSE --res /sys/bus/pci/devices/0000\:04\:00.0/resource0 | sed 's/reg_val read://'`
reason=$((`printf "0x%s" $r`))

#
# Decipher individual bits -- The HW can set multiple bits,
# e.g. 0x610 means the HW goes thru watchdog, cold and warm reboots             

# Cold reboot (NPU and other hardware reset, bit 10)
# ...
# Watchdog expired (WDI triggered 0x10, bit 4) etc
# ...
# Power failure (or Power Cycle 0x1, bit 0, Including Power Cycle)
r_array=(power cpu psu thermal watchdog bmc hotswap shutdown button warm cold)

rm -f /tmp/opx_start_*

for i in `seq 0 10`;
do
    tmp=$(( 1 << $i ))
    tmp=$(( $reason & $tmp ))
    if [[ $tmp != 0 ]]
then
        touch /tmp/opx_start_${r_array[i]}
fi
done

# HW requires write clear
/usr/bin/pcisysfs.py --set --val 0x0 --offset $REBOOT_CAUSE --res /sys/bus/pci/devices/0000\:04\:00.0/resource0 
