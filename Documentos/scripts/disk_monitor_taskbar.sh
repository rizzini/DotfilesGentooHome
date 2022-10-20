#!/bin/bash
sleep=0
if [ -b "/dev/sdb" ]; then
    sdb="1";
fi
if [ -b "/dev/sdc" ]; then
    sdc="1";
fi
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
if [ $read_sda ]; then
    sda_read_final=$((${read_sda%%}/1024));
fi
if [ $write_sda ]; then
    sda_write_final=$((${write_sda%%}/1024));
fi
if [ $read_sdb ]; then
    sdb_read_final=$((${read_sdb%%}/1024));
fi
if [ $write_sdb ]; then
    sdb_write_final=$((${write_sdb%%}/1024));
fi
if [ $read_sdc ]; then
    sdc_read_final=$((${read_sdc%%}/1024));
fi
if [ $write_sdcc ]; then
    sdc_write_final=$((${write_sdc%%}/1024));
fi
threshold=10
if [[ "$1" == 'taskbar' ]];then
    if [[ $sdb_read_final -ge $threshold || $sdb_write_final -ge $threshold && $sda_read_final -ge $threshold || $sda_write_final -ge $threshold ]];then
        /bin/echo "SSD| R: "$sda_read_final" MB/s W: "$sda_write_final" MB/s <=> ";
        /bin/echo "HDD| R: "$sdb_read_final" MB/s W: "$sdb_write_final" MB/s";
        sleep=1
    fi
    if [[ $sdc_read_final -ge $threshold || $sdc_write_final -ge $threshold  ]];then
        /bin/echo "sdc|""R: $(/bin/echo "$sdc_read_final MB/s") W: $(/bin/echo "$sdc_write_final MB/s")";
        sleep=1;
    fi
    if [ "$sleep" == '1' ];then
        /usr/bin/sleep 1;
    fi
    exit
fi
/usr/bin/printf "SSD|""R: $(/bin/echo "$sda_read_final MB/s") W: $(/bin/echo "$sda_write_final MB/s")\n";
if [ "$sdb" ]; then
    /usr/bin/printf "HDD|""R: $(/bin/echo "$sdb_read_final MB/s") W: $(/bin/echo "$sdb_write_final MB/s")\n";
fi
if [ "$sdc" ]; then
    /usr/bin/printf "sdc|""R: $(/bin/echo "$sdc_read_final MB/s") W: $(/bin/echo "$sdc_write_final MB/s")\n";
fi
if [ "$1" != 'taskbar' ];then
    /usr/bin/printf "CPU Temp: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
fi
