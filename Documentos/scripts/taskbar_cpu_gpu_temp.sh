#!/bin/bash
argument='always_show'
while :;do
    if /bin/grep -q 'ENABLED=no' /etc/ufw/ufw.conf; then
        DATA='Firewall desativado';
    elif [ "$(pgrep easyeffects)" ]; then
        DATA='EasyEffects ligado'
        if [[ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" -ge 65 || "$argument" == 'always_show' ]]; then
           DATA='| A | CPU <b>'$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)'ºc</b> | | |'
        fi
    else
        if [[ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" -ge 65 || "$argument" == 'always_show' ]]; then
            DATA='| A | CPU <b>'$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)'ºc</b> | | |'
        elif [ "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)" == '00' ]; then
            DATA='| A | CPU <b>'$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)'ºc</b> | | |'
        fi
    fi
    echo $DATA
    if [ "$DATA" != "$DATA_last" ];then
        /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_953 org.kde.plasma.doityourselfbar.pass "$DATA"
        DATA_last="$DATA"
    fi
    sleep 1
done




# alacritty -o window.dimensions.lines=13 window.dimensions.columns=55 -e /usr/bin/sudo /usr/bin/intel_gpu_top
