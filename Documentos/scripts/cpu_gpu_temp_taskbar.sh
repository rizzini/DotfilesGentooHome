#!/bin/bash
export LANG=C LC_ALL=C;
if /bin/grep -q 'ENABLED=no' /etc/ufw/ufw.conf; then
    /bin/echo 'Firewall desativado';
elif [ "$(pgrep easyeffects)" ]; then
    /bin/echo 'EasyEffects ligado'
    if [[ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" -ge 65 || "$1" == 'always_show' ]]; then
        /bin/echo " | CPU: $(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)ºc";
    fi
else
    if [[ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" -ge 65 || "$1" == 'always_show' ]]; then
        /bin/echo "CPU: $(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)ºc";
    elif [ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" == '00' ]; then
        /bin/echo "CPU: $(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)ºc";
    fi
fi
