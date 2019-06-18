#!/usr/bin/python
# Copyright (c) 2017 Dell Inc.
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

import sys
import os
import struct
import sched, time
import portiocfg
import cps
import cps_object

resource='/dev/port'
write_value = 0xAF;
z9100_cpld_scratch_reg = 0x102;
z9100_smf_scratch_reg  = 0x202;

# read api to read from LPC registers

def portio_reg_read(resource,offset):
    fd=os.open(resource, os.O_RDONLY)
    if(fd<0):
        print 'file open failed %s"%resource'
        return
    if(os.lseek(fd, offset, os.SEEK_SET) != offset):
        print 'lseek failed on %s'%resource
        return
    buf=os.read(fd,1)
    reg_val=ord(buf)
    os.close(fd)
    return reg_val

# Write api to write into LPC registers

def portio_reg_write(resource,offset,val):
    fd=os.open(resource,os.O_RDWR)
    if(fd<0):
        print 'file open failed %s"%resource'
        return
    if(os.lseek(fd, offset, os.SEEK_SET) != offset):
        print 'lseek failed on %s'%resource
        return
    ret=os.write(fd,struct.pack('B',val))
    if(ret != 1):
        print 'write failed %d'%ret
        return
    os.close(fd)


# Publish a CPS API event

def sytem_fault_notify():
    handle = cps.event_connect()
    pas_fault_obj = cps_object.CPSObject(module='base-pas/platform-fault',
            data={
                'fault-type': 8
                })
    cps.event_send(handle,pas_fault_obj.get())

# CPLD LPC bus test

def cpld_lpc_bus_test():
    portio_reg_write (resource,z9100_cpld_scratch_reg,write_value)
    read_value1 = portio_reg_read(resource,z9100_cpld_scratch_reg)
    if (read_value1 != write_value):
        sytem_fault_notify()

# SMF LPC bus test
def smf_lpc_bus_test():
    portio_reg_write (resource,z9100_smf_scratch_reg,write_value)
    read_value2 = portio_reg_read(resource,z9100_smf_scratch_reg)
    if (read_value2 != write_value):
        sytem_fault_notify()

def lpc_bus_check():
    cpld_lpc_bus_test()
    smf_lpc_bus_test()

def main():

    while True:
        lpc_bus_check()
        time.sleep(300)

if __name__ == '__main__':
    main()

