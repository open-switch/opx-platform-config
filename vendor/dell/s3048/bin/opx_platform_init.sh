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

echo pca9548 0x73 > /sys/bus/i2c/devices/i2c-0/new_device
echo pca9548 0x71 > /sys/bus/i2c/devices/i2c-8/new_device
echo pca9548 0x72 > /sys/bus/i2c/devices/i2c-8/new_device
#SMBus Controller 2.0 SPGT register to 0x00000005 to tune 80KHz frequency
/usr/bin/pcisysfs.py --set --val 0x00000005 --offset 0x300 --res "/sys/devices/pci0000:00/0000:00:13.0/resource0"

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
