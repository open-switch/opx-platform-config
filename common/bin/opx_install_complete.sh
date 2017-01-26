#!/bin/sh

cd /lib/systemd/system

mkdir old

mv *opx*.service old

cd /etc/systemd/system

cat <<END >opx.service
[Unit]
Description= Startup script for OPX

[Service]
ExecStart=/usr/bin/opx_start.sh
KillSignal=SIGKILL
SuccessExitStatus=SIGKILL

# Resource Limitations
LimitCORE=infinity

[Install]
WantedBy=multi-user.target

END

cd multi-user.target.wants

ln -s ../opx.service .
