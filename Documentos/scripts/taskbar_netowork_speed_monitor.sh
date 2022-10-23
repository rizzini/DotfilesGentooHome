#!/bin/bash
size () {
    local -a units
    local -i scale
    if [[ "$1" == "-si" ]]
    then
        scale=1024
        units=(B KiB MiB GiB TiB EiB PiB YiB ZiB)
        shift
    else
        scale=1000
        units=(KB MB GB)
    fi
    local -i unit=0
    if [ -z "${units[0]}" ]
    then
        unit=1
    fi
    local -i whole=${1:-0}
    local -i remainder=0
    while (( whole >= $scale ))
    do
        remainder=$(( whole % scale ))
        whole=$((whole / scale))
        unit=$(( $unit + 1 ))
    done
    local decimal
    if [ $remainder -gt 0 ]
    then
        local -i fraction="$(( (remainder * 10 / scale)))"
        if [ "$fraction" -gt 0 ]
        then
            decimal=".$fraction"
        fi
    fi
    echo "${whole}${units[$unit]}"
}

while :;do
    dl=$(/usr/bin/awk '/\<enp2s0\>/{print $2}' /proc/net/dev)
    up=$(/usr/bin/awk '/\<enp2s0\>/{print $10}' /proc/net/dev)
    /usr/bin/sleep
    dl_=$(/usr/bin/awk '/\<enp2s0\>/{print $2}' /proc/net/dev)
    up_=$(/usr/bin/awk '/\<enp2s0\>/{print $10}' /proc/net/dev)
    dl_final=$(size $(( (dl_-dl) / 1024 )))
    up_final=$(size $(( (up_-up) / 1024 )))
    /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_952 org.kde.plasma.doityourselfbar.pass '| A | DL: '$dl_final'/s UP: '$up_final'/s | | |'


done
