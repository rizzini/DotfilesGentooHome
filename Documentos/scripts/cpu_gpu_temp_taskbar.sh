#!/bin/bash
export LANG=C LC_ALL=C;
if /bin/grep -q 'ENABLED=no' /etc/ufw/ufw.conf; then
    /bin/echo 'Firewall desativado';
elif [ "$(pgrep easyeffects)" ]; then
#     /usr/bin/printf "EasyEffects ligado | CPU: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
    /usr/bin/printf "EasyEffects ligado";
else
    if [[ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" -ge 65 || "$1" == 'always_show' ]]; then
        /usr/bin/printf "CPU: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
    elif [ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" == '00' ]; then
        /usr/bin/printf "CPU: ""$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)""ºc";
    fi
fi
