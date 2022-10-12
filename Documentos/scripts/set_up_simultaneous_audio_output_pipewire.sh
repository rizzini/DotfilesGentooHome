#!/bin/bash
pulseeffects=0
if [ "$(/usr/bin/pgrep easyeffects)" ]; then
    pulseeffects=1
    /home/lucas/Documentos/scripts/easy.effects_in_background.sh
fi
if [ ! -h "/etc/wireplumber/main.lua.d/51-alsa-disable.lua" ];then
    get_current_volume="$(pactl get-sink-volume "$(pactl get-default-sink)" | /usr/bin/awk '{print $12}')";
    /usr/bin/sudo /bin/ln -sf /etc/wireplumber/main.lua.d/disable_minisystem/51-alsa-disable.lua /etc/wireplumber/main.lua.d/51-alsa-disable.lua;
    /bin/systemctl --user restart pipewire.service wireplumber.service;
    /usr/bin/sleep 1;
    /usr/bin/pactl set-sink-volume alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1 "$get_current_volume";
elif [ -h "/etc/wireplumber/main.lua.d/51-alsa-disable.lua" ]; then
    get_current_volume="$(pactl get-sink-volume 'alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1' | /usr/bin/awk '{print $12}')";
    /usr/bin/sudo /bin/rm -f /etc/wireplumber/main.lua.d/51-alsa-disable.lua;
    /bin/systemctl --user restart pipewire.service wireplumber.service;
    /usr/bin/sleep 1
    pactl load-module module-combine-sink sink_name=combination-sink sink_properties=slaves=alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1,alsa_output.pci-0000_00_1b.0.analog-stereo channels=2
    /usr/bin/sleep 1
    /usr/bin/pactl set-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo 100%;
    /usr/bin/pactl set-sink-volume alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1 100%;
    /usr/bin/pactl set-sink-volume "$(pactl get-default-sink)" "$get_current_volume";
    /usr/bin/pactl set-default-sink combination-sink;
fi
if [ $pulseeffects == 1 ];then
    /usr/bin/sleep 1
    /home/lucas/Documentos/scripts/easy.effects_in_background.sh &
fi
