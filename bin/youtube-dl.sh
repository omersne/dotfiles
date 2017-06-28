#!/bin/bash

help_info()
{
    echo "Usage: $0 <URL/video ID>"
}

strstr()
{
    [ "${1#*$2*}" == "$1" ] && return 1
    return 0
}

valid_iso_8601_date_regex()
{
    echo "20[0-2][0-9]-[01][0-9]-[0-3][0-9]"
}

valid_video_file_regex()
{
    local video_id="$1"

    echo "_${video_id}_U20[0-2][0-9][01][0-9][0-3][0-9]\."
}

ls_video_file()
{
    local video_id="$1"

    ls -lah *$(valid_video_file_regex "$video_id")*
}

is_single_video()
{
    local url="$1"

    if (strstr "$url" "v=" && ! strstr "$url" "list=") || \
            strstr "$video" "youtu.be/" || strstr "$video" "/watch/" || \
            strstr "$video" "/embed/"; then
        return 0
    fi

    return 1
}

get_video_id()
{
    local video="$1"

    if strstr "$video" "v="; then
        video="$(awk -F '=' '{print $NF}' <<< "$video")"
    elif strstr "$video" "youtu.be/" || strstr "$video" "/watch/" || \
            strstr "$video" "/embed/"; then
        video="$(awk -F '/' '{print $NF}' <<< "$video")"
    fi

    echo "$video"
}

ygrep()
{
    local video_id="$1"

    ls | grep -q "$(valid_video_file_regex "$video_id")" | grep -v "\.part$"
}

check_UNA()
{
    local video_id="$1"

    ls *$(valid_video_file_regex "$video_id")* 2>/dev/null | \
            grep -q "$(valid_video_file_regex "$video_id")"
}

fix_UNA()
{
    local video_id="$1"

    local una_file=*_${video_id}_UNA.*

    local upload_date="$(curl -s "https://www.youtube.com/watch?v=$video_id" | \
            grep 'itemprop="datePublished"' | \
            awk -F '"' '{print $(NF-1)}')"

    if ! grep -qx "$(valid_iso_8601_date_regex)" <<< "$upload_date"; then
        echo "Failed to get the video's upload date." >&2
        return 1
    fi

    upload_date="${upload_date//-/}"

    #mv "$una_file" "$(sed "s/_UNA\./_U${upload_date}\./" <<< "$una_file")"
    mv "$una_file" "${una_file/_UNA./_U$upload_date.}"
}

youtube_dl()
{
    local url="$1"

    "$YOUTUBE_DL" --restrict-filename \
            -o '%(title)s_%(id)s_U%(upload_date)s.%(ext)s' "$url"
}

main()
{
    if [ -n "$YOUTUBE_DL_DIR" ]; then
        YOUTUBE_DL=$YOUTUBE_DL_DIR/youtube_dl/__main__.py
    else
        if [ -x ~/git/youtube-dl/youtube_dl/__main__.py ]; then
            YOUTUBE_DL=~/git/youtube-dl/youtube_dl/__main__.py
        else
            echo "Error! \$YOUTUBE_DL_DIR is unset." >&2
            echo 2>&1
            echo "The repo can be cloned with this commamd:" 2>&1
            echo 2>&1
            echo "cd ~/git/ && git clone git@github.com:rg3/youtube-dl.git" 2>&1
            echo 2>&1
            echo "Then just add this to your bashrc:" 2>&1
            echo 2>&1
            echo "export YOUTUBE_DL_DIR=\$GIT_DIR/youtube-dl" 2>&1
            echo 2>&1
            echo "Exiting." >&2
            exit 99 # I've got 99 problems...
        fi
    fi

    local URL="$1"
    if [ -z "$URL" ]; then
        help_info
        exit 1
    fi

    if is_single_video "$URL"; then
        local video_id="$(get_video_id "$URL")"

        if ygrep "$video_id"; then
            echo "The video already exists: "
            ls -lah *_${video_id}_U2*
            echo "Skipping the download."
            return 0
        fi
    fi

    youtube_dl "$URL"

    if [ $? -ne 0 ]; then
        echo "An error was encountered, exiting." >&2
        return 1
    fi

    if is_single_video "$URL"; then
        if ! check_UNA "$video_id"; then
            echo "Failed to get the video's upload date (AKA, the UNA problem)." >&2
            fix_UNA "$video_id"
            local rc=$?
            if [ $rc -eq 0 ]; then
                echo "The upload date in the filename was fixed."
            else
                echo "Failed to fix the upload date in the filename." >&2
            fi
            ls -lah *_${video_id}_U*
            return $rc
        fi
    fi

    return 0
}
main "$@"
