#!/bin/bash
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
#     sda_read_final=$((${read_sda%%}/1024))
    sda_read_final=100
    sda_write_final=$((${write_sda%%}/1024))
    if [ "$sdb" ]; then
        data2_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
        data2_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
        read_sdb=$((data2_read_sdb - data1_read_sdb));
        write_sdb=$((data2_write_sdb - data1_write_sdb));
        sdb_read_final=$((${read_sdb%%}/1024))
#         sdb_write_final=$((${write_sdb%%}/1024))
        sdb_write_final=100
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
ID='951'
if [ "$1" == 'taskbar' ];then
    threshold_sda=5
    threshold_sdb=10
    threshold_sdc=10
    counter=0
    while :; do
        DATA=()
        counter=$((counter+1))
        do_readings
        if [[ $sda_read_final -ge $threshold_sda || $sda_write_final -ge $threshold_sda ]]; then
            DATA+='| A | SSD\| R: <font color='#f44444'>'$sda_read_final'MB/s</font> W: <font color='#f44444'>'$sda_write_final'MB/s</font> | | |'
        fi
        if [[ $sdb_read_final -ge $threshold_sdb || $sdb_write_final -ge $threshold_sdb ]]; then
            DATA+='| A | HDD\| R: <font color='#f44444'>'$sdb_read_final'MB/s</font> W: <font color='#f44444'>'$sdb_write_final'MB/s</font> | | |'
        fi
        if [[ $sdc_read_final -ge $threshold_sdc || $sdc_write_final -ge $threshold_sdc ]]; then
            DATA+='| A | sdc\| R: <font color='#f44444'>'$sdc_read_final'MB/s</font> W: <font color='#f44444'>'$sdc_write_final'MB/s</font> | | |'
        fi

        if [ ! "${DATA[*]}" ];then
            DATA='| A | | | |';
        fi
        qdbus org.kde.plasma.doityourselfbar /id_$ID org.kde.plasma.doityourselfbar.pass "${DATA[*]}"
        sleep 0.5
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


