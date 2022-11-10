#!/bin/bash
url=$(/usr/bin/xclip -o -selection clipboard)
echo "$(tput setaf 82)URL: "$url"$(tput sgr0)"
regex='^https?://[^/]+'
if [[ $url =~ $regex ]];then
    if ! /usr/bin/yt-dlp "$url"; then
        if [[ "$url" == *"reddit.com/r/"* ]];then
            /usr/bin/xdg-open "https://redditsave.com/info?url=$url" &> /dev/null & disown
        fi
    else
        /usr/bin/xdg-open ~/ &> /dev/null & disown
    fi
else
    /bin/echo "$(tput setaf 197)URL inválido..$(tput sgr0)"
fi
