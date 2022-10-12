#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    /usr/bin/echo "Root needed";
    exit
fi
export LANG=C LC_ALL=C;
/sbin/fdisk -l | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/fdisk -l'
/usr/bin/glxinfo -B | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/glxinfo -B'
/usr/bin/hwinfo | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/hwinfo'
/usr/bin/inxi -F | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/inxi -F'
/usr/bin/lsblk | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/lsblk'
/usr/bin/lscpu | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/lscpu'
/usr/bin/lshw | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/lshw'
/usr/bin/lspci -v | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/lspci -v'
/usr/bin/lsusb -v | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/lsusb -v'
/usr/bin/vainfo | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/vainfo'
/usr/bin/vulkaninfo | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/vulkaninfo'
/sbin/btrfs device usage / | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/btrfs device usage'
/sbin/btrfs filesystem df / | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/btrfs filesystem df'
/sbin/btrfs filesystem show | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/btrfs filesystem show'
/sbin/btrfs filesystem usage / | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/btrfs filesystem usage'
/usr/bin/sudo -u lucas /usr/bin/yay -Q | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/installed_package_list'
/bin/mount | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/mount'
/usr/bin/eix-installed-after -dve0 | /usr/bin/tee '/home/lucas/Documentos/hardware_specs/installed_package_list_by_date'
