#!/bin/bash
rm -f /tmp/disk_monitor_taskbar.tmp
do_readings() {
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
}
if [ -e "/dev/sdb" ]; then
    sdb="1";
fi
if [ -e "/dev/sdc" ]; then
    sdc="1";
fi
if [ "$1" == 'taskbar' ];then
    threshold_sda=1
    threshold_sdb=10
    threshold_sdc=10
    counter=0
    counter2=0
    while :; do
        DATA=()
        has_data=()
        do_readings
        counter=$((counter+1))
        if [[ $sda_read_final -ge $threshold_sda || $sda_write_final -ge $threshold_sda || -e /tmp/disk_monitor_taskbar.tmp && $(grep sda /tmp/disk_monitor_taskbar.tmp) ]]; then
            DATA+='| A | SSD\| R: <b>'$sda_read_final'MB/s</b> W: <b>'$sda_write_final'MB/s</b> | | |'
            has_data+=("sda")
        fi
        if [[ $sdb_read_final -ge $threshold_sdb || $sdb_write_final -ge $threshold_sdb || -e /tmp/disk_monitor_taskbar.tmp && $(grep sdb /tmp/disk_monitor_taskbar.tmp) ]]; then
            DATA+='| A | HDD\| R: <b>'$sdb_read_final'MB/s</b> W: <b>'$sdb_write_final'MB/s</b> | | |'
            has_data+=("sdb")
        fi
        if [[ $sdc_read_final -ge $threshold_sdc || $sdc_write_final -ge $threshold_sdc || -e /tmp/disk_monitor_taskbar.tmp && $(grep sdc /tmp/disk_monitor_taskbar.tmp) ]]; then
            DATA+='| A | sdc\| R: '$sdc_read_final'MB/s W: '$sdc_write_final'MB/s | | |'
            has_data+=("sdc")
        fi
        if [ ! "${has_data[*]}" ];then
            DATA='| A | | | |';
            counter2=$((counter2+1))
        else
            if [[ ! -e /tmp/disk_monitor_taskbar.tmp ]]; then
                printf "%s\n" "${has_data[@]}" > /tmp/disk_monitor_taskbar.tmp
            fi
        fi
        if [ $(($counter2+7)) == $counter ]; then
            rm -f /tmp/disk_monitor_taskbar.tmp
            counter=0
            counter2=0
        fi
        /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_951 org.kde.plasma.doityourselfbar.pass "${DATA[*]}"
        /bin/sleep 0.5
    done
else
    do_readings
    /bin/echo "SSD| R: "$sda_read_final"MB/s W: "$sda_write_final"MB/s";
    if [ "$sdb" ]; then
        /bin/echo "HDD| R: "$sdb_read_final"MB/s W: "$sdb_write_final"MB/s";
    fi
    if [ "$sdc" ]; then
        /bin/echo "sdc| R: "$sdc_read_final"MB/s W: "$sdc_write_final"MB/s";
    fi
    if [ "$1" != 'taskbar' ];then
        /bin/echo "CPU Temp: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")ºc";
    fi
fi


