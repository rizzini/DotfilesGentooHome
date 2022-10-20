#!/bin/bash

if [ -b "/dev/sdb" ]; then
    sdb="1";
fi
if [ -b "/dev/sdc" ]; then
    sdc="1";
fi
data1_read_sda2=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $6}');
data1_write_sda2=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $10}');
if [ "$sdb" ]; then
    data1_read_sdb=$(/bin/grep -w sdb /proc/diskstats | /usr/bin/awk '{print $6}');
    data1_write_sdb=$(/bin/grep -w sdb /proc/diskstats | /usr/bin/awk '{print $10}');
fi
if [ "$sdc" ]; then
    data1_read_sdc=$(/bin/grep -w sdc /proc/diskstats | /usr/bin/awk '{print $6}');
    data1_write_sdc=$(/bin/grep -w sdc /proc/diskstats | /usr/bin/awk '{print $10}');
fi
/usr/bin/sleep 0.5 &&
data2_read_sda2=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $6}');
data2_write_sda2=$(/bin/grep -w sda /proc/diskstats | /usr/bin/awk '{print $10}');
read_sda=$((data2_read_sda2 - data1_read_sda2));
write_sda=$((data2_write_sda2 - data1_write_sda2));
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
if [ $read_sda ]; then
    sda_read_final=$((${read_sda%%}/1024))
fi
if [ $write_sda ]; then
    sda_write_final=$((${write_sda%%}/1024))
fi
if [ $read_sdb ]; then
    sdb_read_final=$((${read_sdb%%}/1024))
fi
if [ $write_sdb ]; then
    sdb_write_final=$((${write_sdb%%}/1024))
fi
if [ $read_sdc ]; then
    sdc_read_final=$((${read_sdc%%}/1024))
fi
if [ $write_sdcc ]; then
    sdc_write_final=$((${write_sdc%%}/1024))
fi
if [[ "$1" == 'diskonly' ]];then
    if [[ $sda_read_final -ge 10 || $sda_write_final -ge 10 ]];then
        /usr/bin/printf "SSD|""R: $(/bin/echo "$sda_read_final MB/s") W: $(/bin/echo "$sda_write_final MB/s") ||\n";
    fi
    if [[ $sdb_read_final -ge 10 || $sdb_write_final -ge 10 ]];then
        /usr/bin/printf "HDD|""R: $(/bin/echo "$sdb_read_final MB/s") W: $(/bin/echo "$sdb_write_final MB/s") ||\n";
    fi
    if [[ $sdc_read_final -ge 10 || $sdc_write_final -ge 10  ]];then
        /usr/bin/printf "sdc|""R: $(/bin/echo "$sdc_read_final MB/s") W: $(/bin/echo "$sdc_write_final MB/s")";
    fi
    sleep 1
    exit
fi
if [ "$sdb" ]; then
    /usr/bin/printf "HDD|""R: $(/bin/echo "$sdb_read_final MB/s") W: $(/bin/echo "$sdb_write_final MB/s")\n";
fi
if [ "$sdc" ]; then
    /usr/bin/printf "sdc|""R: $(/bin/echo "$sdc_read_final MB/s") W: $(/bin/echo "$sdc_write_final MB/s")\n";
fi
if [ "$1" != 'diskonly' ];then
    /usr/bin/printf "CPU Temp: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
fi
