#!/bin/bash
# Copyright (c) 2018 Dell Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT
# LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS
# FOR A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
#
# See the Apache Version 2.0 License for specific language governing
# permissions and limitations under the License.

# This files creates a separate network name space for simulated front panel ports.
# It renames standard network interfaces to 'vport<N>', and sets the default state to 'down'

IFNAME="$1"

MGMTIF="eth0"
IFPREFIX="eth"
VNICPREFIX="vport"


# Virtual front panel ports namespace
SIMNS="vportnetns"
echo "Creating namespace ${SIMNS}"
  /sbin/ip netns add ${SIMNS}
  /sbin/ip netns exec ${SIMNS} /sbin/ip link set dev lo up

IFLIST=`find /sys/class/net/ -name "eth*" -printf " %f"`

for IFNAME in ${IFLIST/$MGMTIF/}; do

   VNIC="${IFNAME/$IFPREFIX/$VNICPREFIX}"
   echo "Move $IFNAME to ${SIMNS}::$VNIC"

/sbin/ip link set dev ${IFNAME} down
/sbin/ip link set dev ${IFNAME} name ${VNIC}
   /sbin/ip link set dev ${VNIC} promisc on
   /sbin/ip link set dev ${VNIC} netns ${SIMNS}
if [ $? -ne 0 ]; then
	echo "Cannot move $IFNAME to ${SIMNS}::$VNIC"
fi
done

