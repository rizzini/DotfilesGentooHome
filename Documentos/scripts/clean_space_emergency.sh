#!/bin/bash
if [ "$EUID" -ne 0 ];then
    /usr/bin/echo "Please run as root";
    exit 1;
fi
if [ "$1" == 'force' ];then
    /bin/rm -f /tmp/clean_space_emergency.sh.lock;
    if [[ -n "$2" && "$2" != 'allhdd' && "$2" != 'allssd' ]];then
        echo 'O segundo argumento, se existir, deve ser "allssd" ou "allhdd"';
        exit 1;
    fi
elif [[ -n "$1" && "$1" != 'force' ]];then
    echo 'O primeiro argumento, se existir, deve ser "force"';
    exit 1;
fi
if test -e "/tmp/clean_space_emergency.sh.lock";then
    exit 1;
fi
/usr/bin/touch /tmp/clean_space_emergency.sh.lock;
{
if [[ "$(/bin/df -B MB  /dev/sda2 --output=avail | /usr/bin/tail -1 | /usr/bin/tr -d 'MB')" -le 700 || "$1" == 'force' && "$2" != 'allhdd' ]];then
    out_of_space=1;
    if [ "$2" == 'allssd' ];then
        /sbin/btrfs sub del /mnt/gentoo/btrbk_snapshots/HOME/*;
        /sbin/btrfs sub del /mnt/gentoo/btrbk_snapshots/ROOT/*;
        /sbin/btrfs sub del /mnt/gentoo/btrbk_snapshots/BOOT_ESP/*;
        /sbin/btrfs sub del /mnt/gentoo/refind_btrfs_rw_snapshots/*;
    else
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list / | /bin/grep HOME | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]];then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/gentoo/btrbk_snapshots/HOME/* -prune -type d)
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list / | /bin/grep ROOT | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]];then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/gentoo/btrbk_snapshots/ROOT/* -prune -type d)
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list / | /bin/grep BOOT_ESP | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]];then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/gentoo/btrbk_snapshots/BOOT_ESP/* -prune -type d)
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list / | /bin/grep refind_btrfs_rw_snapshots | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]]; then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/gentoo/refind_btrfs_rw_snapshots/* -prune -type d)
        if [ "$1" == 'force' ]; then
            if [ -z "$(/usr/bin/pgrep makepkg)" ]; then
                echo -e 'Pasta \033[1m/mnt/gentoo/temp_stuff\033[0m'
                ls -lah /mnt/gentoo/temp_stuff/
                echo -e '\033[1mRemover temp_stuff?\033[0m'
                read -r temp_stuff
                if [ "$temp_stuff" == 's' ];then
                    /bin/rm -rf /mnt/gentoo/temp_stuff/*;
                fi
            fi
        fi
        if [ -z "$(/usr/bin/pgrep winetricks)" ];then
            /bin/rm -rf /home/lucas/.cache/winetricks/*;
        fi
    fi
fi
if [[ "$(/bin/df -B MB  "$(/bin/mount | /bin/grep  '/mnt/backup' | /usr/bin/awk '{print $1}')" --output=avail | /usr/bin/tail -1 | /usr/bin/tr -d 'MB')" -le 700 || "$1" == 'force' && "$2" != 'allssd' ]];then
    out_of_space=1;
    /usr/bin/killall -9 btrbk_ btrbk;
    if [ "$2" == 'allhdd' ];then
        /sbin/btrfs sub del /mnt/backup/HOME/*;
        /sbin/btrfs sub del /mnt/backup/ROOT/*;
        /sbin/btrfs sub del /mnt/backup/BOOT_ESP/*;
    else
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list /mnt/backup/ROOT/ | /bin/grep ROOT | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]];then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/backup/ROOT/* -prune -type d)
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list /mnt/backup/HOME/ | /bin/grep HOME | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]];then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/backup/HOME/* -prune -type d)
        while IFS= read -r d;do
            if [[ -d "$d" && "$d" != *"$(/sbin/btrfs subvol list /mnt/backup/BOOT_ESP/ | /bin/grep BOOT_ESP | /usr/bin/awk '{print $9}' | /usr/bin/tail -1)"* ]];then
                /sbin/btrfs sub del "$d";
            fi
        done < <(/usr/bin/find /mnt/backup/BOOT_ESP/* -prune -type d)
    fi
fi
} | /usr/bin/tee /tmp/clean_space_emergency.sh.log
if [[ -n "$out_of_space" && "$1" != 'force' ]];then
    /bin/machinectl shell --uid=lucas .host /usr/bin/notify-send -u critical "Script clean_space_emergency.sh executado. Checar logs em /tmp/clean_space_emergency.sh.log."
    exit 0;
fi
