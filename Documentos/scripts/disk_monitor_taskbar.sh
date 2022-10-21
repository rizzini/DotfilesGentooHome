#!/bin/bash

if [ -e "/dev/sdb" ]; then
    sdb="1";
fi
if [ -e "/dev/sdc" ]; then
    sdc="1";
fi
data1_read_sda2=$(/usr/bin/awk '/\<sda\>/{print $6}' /proc/diskstats);
data1_write_sda2=$(/usr/bin/awk '/\<sda\>/{print $10}' /proc/diskstats);
if [ "$sdb" ]; then
    data1_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
    data1_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
fi
if [ "$sdc" ]; then
    data1_read_sdc=$(/usr/bin/awk '/\<sdc\>/{print $6}' /proc/diskstats);
    data1_write_sdc=$(/usr/bin/awk '/\<sdc\>/{print $10}' /proc/diskstats);
fi
/usr/bin/sleep 0.5 &&
data2_read_sda2=$(/usr/bin/awk '/\<sda\>/{print $6}' /proc/diskstats);
data2_write_sda2=$(/usr/bin/awk '/\<sda\>/{print $10}' /proc/diskstats);
read_sda2=$((data2_read_sda2 - data1_read_sda2));
write_sda2=$((data2_write_sda2 - data1_write_sda2));
if [ "$sdb" ]; then
    data2_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
    data2_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
    read_sdb=$((data2_read_sdb - data1_read_sdb));
    write_sdb=$((data2_write_sdb - data1_write_sdb));
fi
if [ "$sdc" ]; then
    data2_read_sdc=$(/usr/bin/awk '/\<sdc\>/{print $6}' /proc/diskstats);
    data2_write_sdc=$(/usr/bin/awk '/\<sdc\>/{print $10}' /proc/diskstats);
    read_sdc=$((data2_read_sdc - data1_read_sdc));
    write_sdc=$((data2_write_sdc - data1_write_sdc));
fi
if [ "$1" == 'taskbar' ];then
    /bin/echo "SSD| R: $((${read_sda2%%}/1024))MB/s W: $((${write_sda2%%}/1024))MB/s <=> ";
    if [ "$sdb" ]; then
        /bin/echo "HDD| R: $((${read_sdb%%}/1024))MB/s W: $((${write_sdb%%}/1024))MB/s";
    fi
    if [ "$sdc" ]; then
        /bin/echo "sdc| R: $((${read_sdc%%}/1024))MB/s W: $((${write_sdc%%}/1024))MB/s";
    fi
else
    /bin/echo "SSD| R: $((${read_sda2%%}/1024))MB/s W: $((${write_sda2%%}/1024))MB/s";
    if [ "$sdb" ]; then
        /bin/echo "HDD| R: $((${read_sdb%%}/1024))MB/s W: $((${write_sdb%%}/1024))MB/s";
    fi
    if [ "$sdc" ]; then
        /bin/echo "sdc| R: $((${read_sdc%%}/1024))MB/s W: $((${write_sdc%%}/1024))MB/s";
    fi
    if [ "$1" != 'taskbar' ];then
        /bin/echo "CPU Temp: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")ºc";
    fi
fi


