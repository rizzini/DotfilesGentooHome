#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    /bin/echo "Please run as root";
    exit;
fi
if test -f "/tmp/check_btrfs_health.sh.tmp"; then
    exit;
fi
/usr/bin/touch "/tmp/check_btrfs_health.sh.tmp";
if ! /sbin/btrfs device stats -c /; then
    /sbin/btrfs device stats -c / | /usr/bin/tee -a /home/lucas/check_btrfs_health.sh.ssd.log;
    /bin/machinectl shell --uid=lucas .host /usr/bin/notify-send -u critical "Erro de E/S: SSD | Checar ~/check_btrfs_health.sh.ssd.log";
fi
if /bin/mount | /bin/grep -q '/mnt/dados'; then
    if [ ! "$(/sbin/btrfs device stats -c /mnt/dados)" ]; then
        /sbin/btrfs device stats -c /mnt/dados | /usr/bin/tee -a /home/lucas/check_btrfs_health.sh.mnt.dados.log;
        /bin/machinectl shell --uid=lucas .host /usr/bin/notify-send -u critical "Erro de E/S: /mnt/dados/ | Checar ~/check_btrfs_health.sh.mnt.dados.log";
    fi
fi
if /bin/mount | /bin/grep -q '/mnt/backup'; then
    if ! /sbin/btrfs device stats -c /mnt/backup; then
        /sbin/btrfs device stats -c /mnt/backup | /usr/bin/tee -a /home/lucas/check_btrfs_health.sh.mnt.backup.log;
        /bin/machinectl shell --uid=lucas .host /usr/bin/notify-send -u critical "Erro de E/S: /mnt/backup/ | Checar ~/check_btrfs_health.sh.mnt.backup.log";
    fi
fi
/bin/rm -f "/tmp/check_btrfs_health.sh.tmp";
