#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    /bin/echo "No root, no deal..";
    exit 1;
fi
varrun="/run/meu_android"
BRIDGE="android_bridge0"
IPV4_ADDR="192.0.0.1"
IPV4_NETMASK="255.255.255.252"
IPV4_NETWORK="192.0.0.1/30"
IPV4_BROADCAST="0.0.0.0"
IPV4_NAT="true"
use_iptables_lock="-w"
iptables -w -L -n > /dev/null 2>&1 || use_iptables_lock=""
_netmask2cidr () {
    local x=${1##*255.}
    set -- "0^^^128^192^224^240^248^252^254^" "$(( (${#1} - ${#x})*2 ))" "${x%%.*}"
    x=${1%%${3}*}
    echo $(( ${2} + (${#x}/4) ))
}
ifdown() {
    ip addr flush dev "${1}"
    ip link set dev "${1}" down
}
ifup() {
    [ "${HAS_IPV6}" = "true" ] && [ "${IPV6_PROXY}" = "true" ] && ip addr add fe80::1/64 dev "${1}"
    if [ -n "${IPV4_NETMASK}" ] && [ -n "${IPV4_ADDR}" ]; then
        MASK=$(_netmask2cidr ${IPV4_NETMASK})
        CIDR_ADDR="${IPV4_ADDR}/${MASK}"
	ip addr add "${CIDR_ADDR}" broadcast "${IPV4_BROADCAST}" dev "${1}"
    fi
    ip link set dev "${1}" up
}
start() {
    if [ -d /sys/class/net/${BRIDGE} ]; then
        stop 2>/dev/null || true
    fi
    FAILED=1
    cleanup() {
        set +e
        if [ "${FAILED}" = "1" ]; then
            echo "Failed to setup android_bridge0." >&2
            stop
        fi
    }
    set -e
    [ ! -d "/sys/class/net/${BRIDGE}" ] && ip link add dev "${BRIDGE}" type bridge
    if [ ! -d "${varrun}" ]; then
        mkdir -p "${varrun}"
        if which restorecon >/dev/null 2>&1; then
            restorecon "${varrun}"
        fi
    fi
    ifup "${BRIDGE}" "${IPV4_ADDR}" "${IPV4_NETMASK}"
    IPV4_ARG=""
    if [ -n "${IPV4_ADDR}" ] && [ -n "${IPV4_NETMASK}" ] && [ -n "${IPV4_NETWORK}" ]; then
        echo 1 > /proc/sys/net/ipv4/ip_forward
        if [ "${IPV4_NAT}" = "true" ]; then
            iptables "${use_iptables_lock}" -t nat -A POSTROUTING -s "${IPV4_NETWORK}" ! -d "${IPV4_NETWORK}" -j MASQUERADE
        fi
    fi
    iptables "${use_iptables_lock}" -I INPUT -i "${BRIDGE}" -p udp --dport 67 -j ACCEPT
    iptables "${use_iptables_lock}" -I INPUT -i "${BRIDGE}" -p tcp --dport 67 -j ACCEPT
    iptables "${use_iptables_lock}" -I INPUT -i "${BRIDGE}" -p udp --dport 53 -j ACCEPT
    iptables "${use_iptables_lock}" -I INPUT -i "${BRIDGE}" -p tcp --dport 53 -j ACCEPT
    iptables "${use_iptables_lock}" -I FORWARD -i "${BRIDGE}" -j ACCEPT
    iptables "${use_iptables_lock}" -I FORWARD -o "${BRIDGE}" -j ACCEPT
    iptables "${use_iptables_lock}" -t mangle -A POSTROUTING -o "${BRIDGE}" -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
    touch "${varrun}/network_up"
    FAILED=0
}
stop() {
    if [ -d /sys/class/net/${BRIDGE} ]; then
        ifdown ${BRIDGE}
        iptables ${use_iptables_lock} -D INPUT -i ${BRIDGE} -p udp --dport 67 -j ACCEPT
        iptables ${use_iptables_lock} -D INPUT -i ${BRIDGE} -p tcp --dport 67 -j ACCEPT
        iptables ${use_iptables_lock} -D INPUT -i ${BRIDGE} -p udp --dport 53 -j ACCEPT
        iptables ${use_iptables_lock} -D INPUT -i ${BRIDGE} -p tcp --dport 53 -j ACCEPT
        iptables ${use_iptables_lock} -D FORWARD -i ${BRIDGE} -j ACCEPT
        iptables ${use_iptables_lock} -D FORWARD -o ${BRIDGE} -j ACCEPT
        iptables ${use_iptables_lock} -t mangle -D POSTROUTING -o ${BRIDGE} -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
        if [ -n "${IPV4_NETWORK}" ] && [ "${IPV4_NAT}" = "true" ]; then
            iptables ${use_iptables_lock} -t nat -D POSTROUTING -s ${IPV4_NETWORK} ! -d ${IPV4_NETWORK} -j MASQUERADE
        fi
        ls /sys/class/net/${BRIDGE}/brif/* > /dev/null 2>&1 || ip link delete "${BRIDGE}"
    fi
    rm -f "${varrun}/network_up"
}
if ! pgrep -f 'qemu-system-x86_64 -name Android'; then
    start
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
    su - lucas -c 'XDG_RUNTIME_DIR=/run/user/1000 DISPLAY=:0 qemu-system-x86_64 \
                        -name Android \
                        -enable-kvm \
                        -m 2048 \
                        -smp 4 \
                        -cpu host \
                        -nodefaults \
                        -audiodev pa,id=pa -audio pa,model=es1370 \
                        -usbdevice tablet \
                        -netdev bridge,id=hn0,br=android_bridge0 -device e1000,netdev=hn0,id=nic1 \
                        -device qemu-xhci,id=xhci -device usb-host,hostdevice=/dev/bus/usb/'"${webcam[0]}"'/'"${webcam[1]}"' \
                        -device virtio-vga-gl \
                        -display gtk,gl=on \
                        -hda /home/lucas/.android/androidx86_hda.img' &> /dev/null & disown $!
    sleep 10;
    while ! ping 192.0.0.2 -w 1 -c 1; do
        echo 'Aguardando VM..';
        sleep 2;
    done
    adb connect 192.0.0.2:5555 &
    sleep 3
    while [ "$(adb shell dumpsys battery | awk '/\<'"level"'\>/{print $2}')" == "0" ]; do
        adb shell dumpsys battery set level 80;
        sleep 5;
    done
    while pgrep -f 'qemu-system-x86_64 -name Android'; do
        sleep 3;
    done
    stop
else
    pkill -f 'qemu-system-x86_64 -name Android'
    stop
fi
