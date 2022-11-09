function bv
        set url (xclip -o)
        if not /usr/bin/yt-dlp $url;
            /usr/bin/xdg-open "https://redditsave.com/info?url=$url &> /dev/null & disown"
        end
end
