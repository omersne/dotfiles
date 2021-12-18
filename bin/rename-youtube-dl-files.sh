#!/bin/bash

##############################################################################
# rename-youtube-dl-files.sh
# ------------------------------------------
# Renames a media file downloaded with `youtube-dl' and associated files
# (info JSON, annotations, thumbnail image, subtitles).
#
# Usage:
#       rename-youtube-dl-files.sh <source filename> <destination filename>
#
#       The filenames should not include extensions. Example:
#       rename-youtube-dl-files.sh Rick_Astley_-_Never_Gonna_Give_You_Up_dQw4w9WgXcQ_D3141592653 some_misleading_video_name
#
# :authors: Omer Sne, @omersne, 0x65A9D22B299BA9B5
# :date: 2017-09-08
# :version: 0.0.3
##############################################################################

EXTENSIONS=( .info.json .annotations.xml .jpg _{thumb,small,medium,large,orig}.jpg .mp4 .mp3 .en.srt )
MV="mv"

endswith()
{
    [ "${1%*$2}" != "$1" ]
}

abort()
{
    echo "Exiting" >&2
    exit 1
}

usage()
{
    echo "Usage: $0 <source filename> <destination filename>" >&2
    echo "(the filenames should not include extensions)" >&2
}

# I'm too lazy to type 'DRY_RUN' sometimes.
if [ "$DRY_RUN" == 1 ] || [ "$DRY" == 1 ]; then
    MV="echo [dry run] $MV"
fi

SRC="$1"
DST="$2"

if [ -z "$SRC" ] || [ -z "$DST" ]; then
    usage
    abort
fi

for extension in "${EXTENSIONS[@]}"; do
    if [ ! -e "${SRC}$extension" ]; then
        continue
    fi
    $MV -- "${SRC}$extension" "${DST}$extension" || abort
done

exit 0
