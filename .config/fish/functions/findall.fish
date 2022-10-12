function findall
    sudo find / -not \( -wholename "/mnt" -prune -o -wholename "/usr/share/locale" -prune -o -wholename "/home/lucas/.local/share/icons" -prune -o -wholename "/usr/share/man" -prune \)  -iname """*$argv[1]*""" 2> /dev/null
end










