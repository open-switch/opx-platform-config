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

echo pca9548 0x70 >/sys/devices/pci0000:00/0000:00:13.0/i2c-?/new_device

#SMBus Controller 2.0 SPGT register to 0x00000005 to tune 80KHz frequency
/usr/bin/pcisysfs.py --set --val 0x00000005 --offset 0x300 --res "/sys/devices/pci0000:00/0000:00:13.0/resource0"

# Now create a file to hold the firmware versions.
FIRMWARE_VERSION_FILE=/var/log/firmware_versions
rm -rf ${FIRMWARE_VERSION_FILE}
echo "BIOS: `dmidecode -s system-version `" > $FIRMWARE_VERSION_FILE
# Get System CPLD version
r=`i2cget -y 2 0x31 0`
echo "System CPLD: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get Master CPLD version
r=`i2cget -y 2 0x32 0`
echo "Master CPLD: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
# Get Slave CPLD version, if present
r=`i2cget -y 2 0x33 0`
if [ $? = 0 ]; then
    echo "Slave CPLD: $((r >> 4)).$((r & 0xf))" >> $FIRMWARE_VERSION_FILE
fi
