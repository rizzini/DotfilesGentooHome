#!/bin/bash
command='if [ "$(pgrep "systemmonitor")" ];then killall systemmonitor &> /dev/null;else /usr/bin/systemmonitor & disown $!;fi'
while :; do
    cpu_usage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1); }' <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat))
    cpu_usage=${cpu_usage%.*}
    DATA='| A | CPU: <b>'$cpu_usage'%</b> | | '$command' |'
    if [ "$DATA" != "$DATA_last" ];then
        /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_954 org.kde.plasma.doityourselfbar.pass "$DATA"
        DATA_last="$DATA"
    fi
    sleep 0.5
done







