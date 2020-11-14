function bak
    if [ $platform = "OSX" ]
        mv "$argv[1]" "$argv[1]".$(date -r $(stat -f '%m' "$argv[1]") "+%y%m%d%H%M").bak
    else if [ $platform = "LINUX" ]
        mv "$argv[1]" "$argv[1]".$(date -d @$(stat -c '%Y' "$argv[1]") "+%y%m%d%H%M").bak
    else
        echo "$platform is not supported" >&2
        return 1
    end
end
