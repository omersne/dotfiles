#!/bin/bash

YOUTUBE_DL="${YOUTUBE_DL:-youtube-dl}"

YOUTUBE_DL_COMMON_OPTIONS=(
    --restrict-filename
    --no-mtime
)
YOUTUBE_DL_OPTIONS=(
    "${YOUTUBE_DL_COMMON_OPTIONS[@]}"
    --format="bestvideo[height=1080][ext=mp4]+bestaudio[ext=m4a]/mp4"
    --write-info-json
    --write-all-thumbnails
)
YOUTUBE_DL_MAX_RES_OPTIONS=(
    "${YOUTUBE_DL_COMMON_OPTIONS[@]}"
    --format="bestvideo[ext=mp4]+bestaudio[ext=m4a]"
    --write-info-json
    --write-all-thumbnails
)
YOUTUBE_DL_MP3_OPTIONS=(
    "${YOUTUBE_DL_COMMON_OPTIONS[@]}"
    --extract-audio
    --audio-format=mp3
)
YOUTUBE_DL_FILENAME_OPTIONS=(
    --output="%(title)s_%(id)s_D%(epoch)s.%(ext)s"
)
YOUTUBE_DL_SHORT_FILENAME_OPTIONS=(
    --output="%(title).50s_%(id)s_D%(epoch)s.%(ext)s"
)
YOUTUBE_DL_PROXY_OPTIONS=(
    --proxy="$YOUTUBE_DL_PROXY"
)

main()
{
    local -a options
    case "${0##*/}" in
        youtube-dl.sh) options=("${YOUTUBE_DL_OPTIONS[@]}");;
        youtube-dl-max-res.sh) options=("${YOUTUBE_DL_MAX_RES_OPTIONS[@]}");;
        youtube-dl-mp3.sh) options=("${YOUTUBE_DL_MP3_OPTIONS[@]}");;
        *)
            echo "Unrecognized script name: \`${0##*/}'." >&2
            exit 1;;
    esac

    local skip_rest=0 short_filename=0 use_proxy=0
    while [ $# -gt 0 ]; do
        if [ "$skip_rest" == 1 ]; then
            options=("${options[@]}" "$1")
        else
            case "$1" in
                --) skip_rest=1;;
                --short-filename|--short) short_filename=1;;
                --use-proxy) use_proxy=1;;
                *) options=("${options[@]}" "$1");;
            esac
        fi
        shift
    done

    if [ "$short_filename" == 1 ]; then
        options=("${YOUTUBE_DL_SHORT_FILENAME_OPTIONS[@]}" "${options[@]}")
    else
        options=("${YOUTUBE_DL_FILENAME_OPTIONS[@]}" "${options[@]}")
    fi

    if [ "$use_proxy" == 1 ]; then
        if [ -z "$YOUTUBE_DL_PROXY" ]; then
            echo "No proxy is defined." >&2
            exit 1
        fi
        options=("${options[@]}" "${YOUTUBE_DL_PROXY_OPTIONS[@]}")
    fi

    "$YOUTUBE_DL" "${options[@]}" "$@"
}
main "$@"
