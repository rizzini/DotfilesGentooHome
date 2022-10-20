#!/bin/bash
if [ -b "/dev/sdb" ]; then
    sdb="1";
fi
if [ -b "/dev/sdc" ]; then
    sdc="1";
fi
do_readings() {
    data1_read_sda=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $6}');
    data1_write_sda=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $10}');
    if [ "$sdb" ]; then
        data1_read_sdb=$(/bin/grep -w sdb /proc/diskstats | /usr/bin/awk '{print $6}');
        data1_write_sdb=$(/bin/grep -w sdb /proc/diskstats | /usr/bin/awk '{print $10}');
    fi
    if [ "$sdc" ]; then
        data1_read_sdc=$(/bin/grep -w sdc /proc/diskstats | /usr/bin/awk '{print $6}');
        data1_write_sdc=$(/bin/grep -w sdc /proc/diskstats | /usr/bin/awk '{print $10}');
    fi
    /usr/bin/sleep 0.5;
    data2_read_sda=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $6}');
    data2_write_sda=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $10}');
    read_sda=$((data2_read_sda - data1_read_sda));
    write_sda=$((data2_write_sda - data1_write_sda));
    if [ "$sdb" ]; then
        data2_read_sdb=$(/bin/grep -w sdb /proc/diskstats | /usr/bin/awk '{print $6}');
        data2_write_sdb=$(/bin/grep -w sdb /proc/diskstats | /usr/bin/awk '{print $10}');
        read_sdb=$((data2_read_sdb - data1_read_sdb));
        write_sdb=$((data2_write_sdb - data1_write_sdb));
    fi
    if [ "$sdc" ]; then
        data2_read_sdc=$(/bin/grep -w sdc /proc/diskstats | /usr/bin/awk '{print $6}');
        data2_write_sdc=$(/bin/grep -w sdc /proc/diskstats | /usr/bin/awk '{print $10}');
        read_sdc=$((data2_read_sdc - data1_read_sdc));
        write_sdc=$((data2_write_sdc - data1_write_sdc));
    fi
    if [ "$read_sda" ]; then
        sda_read_final=$((${read_sda%%}/1024));
    fi
    if [ "$write_sda" ]; then
        sda_write_final=100
    fi
    if [ "$read_sdb" ]; then
        sdb_read_final=$((${read_sdb%%}/1024));
    fi
    if [ "$write_sdb" ]; then
        sdb_write_final=$((${write_sdb%%}/1024));
    fi
    if [ "$read_sdc" ]; then
        sdc_read_final=$((${read_sdc%%}/1024));
    fi
    if [ "$write_sdcc" ]; then
        sdc_write_final=$((${write_sdc%%}/1024));
    fi
}
threshold=1;
counter=0;
do_readings;
if [[ "$1" == 'taskbar' ]];then
    while [[ $sdb_read_final -ge $threshold || $sdb_write_final -ge $threshold || $sda_read_final -ge $threshold || $sda_write_final -ge $threshold ]]; do
    counter=$((counter + 1))
        /bin/echo -ne "SSD| R: $sda_read_final MB/s W: $sda_write_final MB/s <=> HDD| R: $sdb_read_final MB/s W: $sdb_write_final MB/s\r"; # it doesn't work with Argos or Kargos..
        if [ $counter -ge 12 ]; then
            break
        fi
        do_readings;
        /usr/bin/sleep 0.5;
    done
    exit
fi

/bin/echo "SSD| R: $sda_read_final MB/s W: $sda_write_final MB/s";
if [ "$sdb" ]; then
    /bin/echo "HDD| R: $sdb_read_final MB/s W: $sdb_write_final MB/s";
fi
if [ "$sdc" ]; then
    /bin/echo "sdc| R: $sdc_read_final MB/s W: $sdc_write_final MB/s";
fi
if [ "$1" != 'taskbar' ];then
    /bin/echo "CPU Temp: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
fi
