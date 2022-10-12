#!/bin/bash
export LANG=C LC_ALL=C;
if [ "$1" == 'click' ]; then
    if /usr/bin/pgrep easyeffects; then
        /usr/bin/easyeffects;
    else
        alacritty -o window.dimensions.lines=13 window.dimensions.columns=55 -e /usr/bin/sudo /usr/bin/intel_gpu_top
    fi
fi
if /bin/grep -q 'ENABLED=no' /etc/ufw/ufw.conf; then
    /bin/echo 'Firewall desativado';
elif [ "$(pgrep easyeffects)" ]; then
    /bin/echo 'EasyEffects ligado'
else
    if [[ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" -ge 65 || "$1" == 'taskbar' ]]; then
        /usr/bin/printf "CPU: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
    elif [ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" == '00' ]; then
        /usr/bin/printf "CPU: ""$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)""ºc";
    fi
fi
