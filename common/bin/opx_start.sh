#!/bin/sh -x

. /etc/opx/opx-environment.sh

/usr/bin/opx_cps_service &
sleep 3

# cps-db
/usr/bin/python /usr/lib/opx/cps_db_stunnel_manager.py &
sleep 3

/usr/bin/opx_platform_init.sh

/usr/bin/opx_pas_service &
sleep 3

/usr/bin/bcm_mod_init.sh

/usr/bin/opx_nas_daemon &
sleep 3

/usr/bin/base_nas_front_panel_ports.sh &
sleep 3

/usr/bin/base_nas_create_interface.sh

/usr/bin/base_nas_fanout_init.sh && /usr/bin/network_restart.sh

/usr/bin/base_nas_phy_media_config.sh &
sleep 5

/usr/bin/base_nas_default_init.sh

/usr/bin/base_ip &
sleep 5

/usr/bin/base_qos_init.sh

/usr/bin/base_acl_copp_svc.sh &
sleep 5

/usr/bin/base-nas-shell.sh &
sleep 5

echo "OPX now up!"

while true; do
    sleep 1000
done
