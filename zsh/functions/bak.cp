# make backup file followed by last modified date
if [ $# -eq 0 ]; then
    echo "No file or directory is given" >&2; return 1
fi

if [ ${platform} = "OSX" ]; then
    # cp -r "$1" "$1".$(date -r $(stat -f '%m' "$1") "+%y%m%d%H%M").bak
    cp -r "$1" "$1".$(date "+%y%m%d%H%M").bak
elif [ ${platform} = "LINUX" ]; then
    # cp -r "$1" "$1".$(date -d @$(stat -c '%Y' "$1") "+%y%m%d%H%M").bak
    cp -r "$1" "$1".$(date "+%y%m%d%H%M").bak
else
    echo "${platform} is not supported" >&2
    return 1
fi
