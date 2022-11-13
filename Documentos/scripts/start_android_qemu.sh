#!/bin/bash
set -x
if [ "$EUID" -ne 0 ]; then
    /bin/echo "No root, no deal..";
    exit 1;
fi
killall adb &> /dev/null
start_bridge() {
    if [ -d /sys/class/net/android_bridge0 ]; then
        stop_bridge 2>/dev/null || true
    fi
    [ ! -d "/sys/class/net/android_bridge0" ] && ip link add dev android_bridge0 type bridge
    if [ ! -d "/run/meu_android" ]; then
        mkdir -p "/run/meu_android"
    fi
	ip addr add "192.0.0.1/30" dev android_bridge0
    ip link set dev android_bridge0 up
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -w -t nat -A POSTROUTING -s "192.0.0.1/30" ! -d "192.0.0.1/30" -j MASQUERADE
    iptables -w -I FORWARD -i android_bridge0 -j ACCEPT
    iptables -w -I FORWARD -o android_bridge0 -j ACCEPT
    touch "/run/meu_android/network_up"
}
stop_bridge() {
    if [ -d /sys/class/net/android_bridge0 ]; then
        ip addr flush dev android_bridge0
        ip link set dev android_bridge0 down
        iptables -w -D FORWARD -i android_bridge0 -j ACCEPT
        iptables -w -D FORWARD -o android_bridge0 -j ACCEPT
        iptables -w -t nat -D POSTROUTING -s 192.0.0.1/30 ! -d 192.0.0.1/30 -j MASQUERADE
        ls /sys/class/net/android_bridge0/brif/* > /dev/null 2>&1 || ip link delete android_bridge0
    fi
    rm -f "/run/meu_android/network_up"
}
if ! pgrep -f 'qemu-system-i386 -name Android'; then
    start_bridge
    sleep 1
    for i in $(lsusb -d '1908:2310' | awk '{print $2}{print $4}' | tr -d ':'); do
        webcam+=("$i");
    done
    if [[ ${webcam[0]} && ${webcam[1]} ]]; then
        /bin/chgrp qemu /dev/bus/usb/"${webcam[0]}"/"${webcam[1]}";
    else
        echo "Webcam não detectada..";
        /bin/machinectl shell --uid=lucas .host /usr/bin/notify-send -u critical "QEMU: Webcam não detectada..";
        exit 1;
    fi
    su - lucas -s /bin/bash -c 'XDG_RUNTIME_DIR=/run/user/1000 DISPLAY=:0 qemu-system-i386 \
                        -name Android \
                        -enable-kvm \
                        -machine q35 \
                        -m 2048 \
                        -smp 4 \
                        -cpu host \
                        -nodefaults \
                        -machine vmport=off \
                        -audiodev pa,id=pa -audio pa,model=es1370 \
                        -usbdevice tablet -usbdevice keyboard \
                        -netdev bridge,id=hn0,br=android_bridge0 -device virtio-net-pci,netdev=hn0,id=nic1 \
                        -device qemu-xhci,id=xhci -device usb-host,hostdevice=/dev/bus/usb/'"${webcam[0]}"'/'"${webcam[1]}"' \
                        -device virtio-vga-gl \
                        -display gtk,gl=on,show-cursor=on,show-menubar=off,zoom-to-fit=off \
                        -drive file=/home/lucas/.android/androidx86_hda.img,if=virtio,cache=off' &
    sleep 13;
    ok=0
    while pgrep -f 'qemu-system-i386 -name Android'; do
        counter=$((counter+1))
        if [[ $((counter%2)) -eq 0 && "$ok" == '0' ]]; then
            if ping 192.0.0.2 -w 1 -c 1; then
                if timeout 5 adb connect 192.0.0.2:5555; then
                    ok=1
                fi
            fi
        fi
        if [ $counter -eq 10 ];then
            counter=0
        fi
        sleep 3;
    done
    stop_bridge
else
    pkill -f 'qemu-system-i386 -name Android'
fi
