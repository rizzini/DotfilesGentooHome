#!/bin/bash
export LANG=C LC_ALL=C
readarray -t disk_list < <(lsblk -d | awk '/^sd/ {print $1}')
declare -A data1_read data1_write read write threshold show counter counter_no_data
for disk in "${disk_list[@]}"; do
    if [ "$disk" == "sdc" ]; then
        threshold[$disk]=2
    else
        threshold[$disk]=10
    fi
done
show_data_seconds=7
command='if [ "$(pgrep "systemmonitor")" ];then killall systemmonitor &> /dev/null;else /usr/bin/systemmonitor & disown $!;fi'
while :; do
    DATA=()
    has_data=()
    for disk in "${disk_list[@]}"; do
        counter[$disk]=$((counter[$disk]+1))
        data1_read[$disk]=$(/usr/bin/awk '/\<'"$disk"'\>/{print $6}' /proc/diskstats);
        data1_write[$disk]=$(/usr/bin/awk '/\<'"$disk"'\>/{print $10}' /proc/diskstats);
        /usr/bin/sleep 0.5 &&
        data2_read[$disk]=$(/usr/bin/awk '/\<'"$disk"'\>/{print $6}' /proc/diskstats);
        data2_write[$disk]=$(/usr/bin/awk '/\<'"$disk"'\>/{print $10}' /proc/diskstats);
        read[$disk]=$((data2_read[$disk] - data1_read[$disk]));
        write[$disk]=$((data2_write[$disk] - data1_write[$disk]));
        read[$disk]=$((${read[$disk]%%}/1024))
        write[$disk]=$((${write[$disk]%%}/1024))
        if [[ ${read[$disk]} -ge ${threshold[$disk]} || ${write[$disk]} -ge ${threshold[$disk]} || ${show[$disk]} -eq 1 ]]; then
            DATA+='| A | '${disk}'\| R: <b>'${read[$disk]}'MB/s</b> W: <b>'${write[$disk]}'MB/s</b> | | '$command' |'
            has_data+=("$disk")
        fi
    done
    if [ ! "$has_data" ];then
        DATA='| A | Sem atividade de disco | | '$command' |'
            counter_no_data_sda=$((counter_no_data_sda+1))
            counter_no_data_sdb=$((counter_no_data_sdb+1))
            counter_no_data_sdc=$((counter_no_data_sdc+1))
    else
        for disk in "${disk_list[@]}"; do
            if [[ "${has_data[*]}" == *"$disk"* ]]; then
                show[$disk]=1
            else
                counter_no_data[$disk]=$((counter_no_data[$disk]+1))
            fi
        done
    fi
    for disk in "${disk_list[@]}"; do
        if [ $((counter_no_data[$disk]+show_data_seconds)) == ${counter[$disk]} ]; then
            show[$disk]=0
            counter[$disk]=0
            counter_no_data[$disk]=0
        fi
    done
    if [ "$DATA" != "$DATA_last" ];then
        /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_951 org.kde.plasma.doityourselfbar.pass "${DATA[@]}"
        DATA_last="$DATA"
        /usr/bin/sleep 0.5
    else
        /usr/bin/sleep 2
    fi
done
