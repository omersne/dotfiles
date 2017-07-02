#!/bin/bash

# Requires `ffmpeg' for downloading 1080p YouTube videos.

ARCHIVE_FILE=".youtube-dl_archive"

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

valid_video_id_regex()
{
    echo "^[a-zA-Z0-9_-]\{11\}$"
}

ls_video_id()
{
    local video_id="$1"

    ls -a *"_${video_id}_U"*
}

ls_video_file()
{
    local video_id="$1"

    ls_video_id "$video_id" | ignore_non_video_files
}

ignore_partial_videos()
{
    grep -v "\.part$"
}

ignore_non_video_files()
{
    ignore_partial_videos | grep "\.\(webm\|mp4\)$"
}

ls_video_json()
{
    local video_id="$1"

    ls_video_id "$video_id" | grep "\.json$"
}

ls_original_video_json()
{
    local video_id="$1"

    ls_video_json "$video_id" | grep "\.info.json$"
}

video_json_exists()
{
    local video_id="$1"

    ls_video_json "$video_id" 2>/dev/null | grep -q "\.info\.json$" && \
            ls_video_json "$video_id" 2>/dev/null | grep -q "\.info\.min\.json$"
}

is_video_id()
{
    grep -q "$(valid_video_id_regex)" <<< "$1"
}

is_single_video()
{
    local url="$1"

    if (strstr "$url" "v=" && ! strstr "$url" "list=") || \
            strstr "$video" "youtu.be/" || strstr "$video" "/watch/" || \
            strstr "$video" "/embed/" || \
            is_video_id "$url"; then
        return 0
    fi

    return 1
}

get_video_id()
{
    local video="$1"

    if is_video_id "$video"; then
        :
    elif strstr "$video" "v="; then
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

    ls_video_file "$video_id" > /dev/null 2>&1 && video_json_exists "$video_id"
}

check_UNA()
{
    local video_id="$1"

    ls_video_file "$video_id" 2>/dev/null | \
            ignore_non_video_files | \
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

    if [ -f "$ARCHIVE_FILE" ]; then
        local archive_arg="--download-archive $ARCHIVE_FILE"
    else
        local archive_arg=""
    fi

    "$YOUTUBE_DL" --restrict-filename \
            -o '%(title)s_%(id)s_U%(upload_date)s.%(ext)s' \
            --format "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4" \
            --write-info-json \
            $archive_arg \
            "$url"
}

improve_video_json()
{
    # The default JSON file created by youtube-dl is compressed into one line.
    # For easier readability, I prefer to have it split into multiple lines with
    # indentation.
    local video_id="$1"

    local video_file="$(ls_original_video_json "$video_id")"
    local old_video_file="${video_file%.json}.min.json"
    mv "$video_file" "$old_video_file" || return 1

    #python -c "import json; f = open('$old_video_file', 'r'); j = json.load(f); f.close(); \
    #           f2 = open('$video_file', 'w'); json.dump(j, f2, indent=4, sort_keys=True); f2.close()"
    /usr/bin/env python <<EOF
import json
with open('$old_video_file', 'r') as f:
    j = json.load(f)
j["download_date"] = "$(date +"%Y-%m-%d %H-%M-%S")"
f2 = open('$video_file', 'w')
with open('$video_file', 'w') as f:
    json.dump(j, f, indent=4, sort_keys=True)
EOF
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
            ls_video_id "$video_id"
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
            # XXX: The 'UNA' problem can't be fixed by the script anymore, since
            # the script can only fix the filename and not the JSON file.
            echo "Failed to get the video's upload date (AKA, the UNA problem)." >&2
            ls_video_file "$video_id"
            return 1
        fi
        echo "Creating an improved JSON file"
        improve_video_json "$video_id"
        if [ $? -ne 0 ]; then
            echo "Failed to create an improved JSON file." >&2
            return 1
        fi
    fi

    return 0
}
main "$@"
