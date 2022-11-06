#!/bin/bash
export LANG=C LC_ALL=C
if [ -e "/dev/sdb" ]; then
    sdb="1";
fi
if [ -e "/dev/sdc" ]; then
    sdc="1";
fi
threshold_sda=10
threshold_sdb=10
threshold_sdc=2
show_data_seconds=7
counter_sda=0
counter_sdb=0
counter_sdc=0
counter_no_data_sda=0
counter_no_data_sdb=0
counter_no_data_sdc=0
show_sda=0
show_sdb=0
show_sdc=0
command='if [ "$(pgrep "systemmonitor")" ];then killall systemmonitor &> /dev/null;else /usr/bin/systemmonitor & disown $!;fi'
while :; do
    data1_read_sda=$(/usr/bin/awk '/\<sda\>/{print $6}' /proc/diskstats);
    data1_write_sda=$(/usr/bin/awk '/\<sda\>/{print $10}' /proc/diskstats);
    if [ "$sdb" ]; then
        data1_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
        data1_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
    fi
    if [ "$sdc" ]; then
        data1_read_sdc=$(/usr/bin/awk '/\<sdc\>/{print $6}' /proc/diskstats);
        data1_write_sdc=$(/usr/bin/awk '/\<sdc\>/{print $10}' /proc/diskstats);
    fi
    /usr/bin/sleep 0.5 &&
    data2_read_sda=$(/usr/bin/awk '/\<sda\>/{print $6}' /proc/diskstats);
    data2_write_sda=$(/usr/bin/awk '/\<sda\>/{print $10}' /proc/diskstats);
    read_sda=$((data2_read_sda - data1_read_sda));
    write_sda=$((data2_write_sda - data1_write_sda));
    sda_read_final=$((${read_sda%%}/1024))
    sda_write_final=$((${write_sda%%}/1024))
    if [ "$sdb" ]; then
        data2_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
        data2_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
        read_sdb=$((data2_read_sdb - data1_read_sdb));
        write_sdb=$((data2_write_sdb - data1_write_sdb));
        sdb_read_final=$((${read_sdb%%}/1024))
        sdb_write_final=$((${write_sdb%%}/1024))
    fi
    if [ "$sdc" ]; then
        data2_read_sdc=$(/usr/bin/awk '/\<sdc\>/{print $6}' /proc/diskstats);
        data2_write_sdc=$(/usr/bin/awk '/\<sdc\>/{print $10}' /proc/diskstats);
        read_sdc=$((data2_read_sdc - data1_read_sdc));
        write_sdc=$((data2_write_sdc - data1_write_sdc));
        sdc_read_final=$((${read_sdc%%}/1024))
        sdc_write_final=$((${write_sdc%%}/1024))
    fi
    DATA=()
    has_data=()
    counter_sda=$((counter_sda+1))
    counter_sdb=$((counter_sdb+1))
    counter_sdc=$((counter_sdc+1))
    if [[ $sda_read_final -ge $threshold_sda || $sda_write_final -ge $threshold_sda || $show_sda -eq 1 ]]; then
        DATA+='| A | SSD\| R: <b>'$sda_read_final'MB/s</b> W: <b>'$sda_write_final'MB/s</b> | | '$command' |'
        has_data+=("sda")
    fi
    if [[ $sdb_read_final -ge $threshold_sdb || $sdb_write_final -ge $threshold_sdb || $show_sdb -eq 1 ]]; then
        DATA+='| A | HDD\| R: <b>'$sdb_read_final'MB/s</b> W: <b>'$sdb_write_final'MB/s</b> | | '$command' |'
        has_data+=("sdb")
    fi
    if [[ $sdc_read_final -ge $threshold_sdc || $sdc_write_final -ge $threshold_sdc || $show_sdc -eq 1 ]]; then
        DATA+='| A | sdc\| R: '$sdc_read_final'MB/s W: '$sdc_write_final'MB/s | | '$command' |'
        has_data+=("sdc")
    fi
    if [ ! "$has_data" ];then
        DATA='| A | Sem atividade de disco | | '$command' |'
            counter_no_data_sda=$((counter_no_data_sda+1))
            counter_no_data_sdb=$((counter_no_data_sdb+1))
            counter_no_data_sdc=$((counter_no_data_sdc+1))
    else
        if [[ "${has_data[*]}" == *"sda"* ]]; then
            show_sda=1
        else
            counter_no_data_sda=$((counter_no_data_sda+1))
        fi
        if [[ "${has_data[*]}" == *"sdb"* ]]; then
            show_sdb=1
        else
            counter_no_data_sdb=$((counter_no_data_sdb+1))
        fi
        if [[ "${has_data[*]}" == *"sdc"* ]]; then
            show_sdc=1
        else
            counter_no_data_sdc=$((counter_no_data_sdc+1))
        fi
    fi
    if [ $((counter_no_data_sda+show_data_seconds)) == $counter_sda ]; then
        show_sda=0
        counter_sda=0
        counter_no_data_sda=0
    fi
    if [ $((counter_no_data_sdb+show_data_seconds)) == $counter_sdb ]; then
        show_sdb=0
        counter_sdb=0
        counter_no_data_sdb=0
    fi
    if [ $((counter_no_data_sdc+show_data_seconds)) == $counter_sdc ]; then
        show_sdc=0
        counter_sdc=0
        counter_no_data_sdc=0
    fi
    if [ "$DATA" != "$DATA_last" ];then
        /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_951 org.kde.plasma.doityourselfbar.pass "${DATA[@]}"
        DATA_last="$DATA"
        /usr/bin/sleep 0.5
    else
        /usr/bin/sleep 2
    fi
done

