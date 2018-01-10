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

# This files creates a separate network name space 'vportnetns' for simulated front panel ports.
# It renames standard network interfaces to 'vnic<N>', and sets the default state to 'down'
# This script is invoked for each interface - from the udev rules.

IFNAME="$1"

if [ -z "${IFNAME}" ]; then
   exit 1
fi


# Virtual front panel ports namespace
SIMNS="vportnetns"
if [ ! -e /var/run/netns/${SIMNS} ]; then
  /sbin/ip netns add ${SIMNS}
  /sbin/ip netns exec ${SIMNS} /sbin/ip link set dev lo up
fi


# Rename eth<N> interface to vport<N>
VNIC="${IFNAME/eth/vport}"

/sbin/ip link set dev ${IFNAME} down
/sbin/ip link set dev ${IFNAME} name ${VNIC}
if [ $? -ne 0 ]; then
   exit 2
fi

/sbin/ip link set dev ${VNIC} promisc on
/sbin/ip link set dev ${VNIC} netns ${SIMNS}
