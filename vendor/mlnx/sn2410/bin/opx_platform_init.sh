#!/bin/bash

# Copyright Mellanox Technologies, Ltd. 2001-2017.
# This software product is licensed under Apache version 2, as detailed in
# the LICENSE file.


# Initialization of the Mellanox SN2410 platform
init_sn2410()
{
    # Install SX kernel modules
    /etc/init.d/sxdkernel start
    dvs_start.sh

    modprobe i2c-dev

    # install all BSP kernel drivers, connect drivers to devices
    /etc/mlnx/msn2410 start
}

. /etc/opx/opx-environment.sh

init_sn2410
