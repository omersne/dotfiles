#!/bin/bash

# The filenames of shows downloaded with `youtube-dl' are in this format:
# <video title>_<video ID>_D<download date timestamp>.{mp4,jpg,info.json}
#
# Example:
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_1_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.mp4
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_1_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.jpg
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_1_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.info.json
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_2_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.mp4
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_2_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.jpg
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_2_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.info.json
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_3_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.mp4
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_3_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.jpg
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_3_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.info.json
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_4_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.mp4
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_4_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.jpg
# The_Daily_Show_with_Trevor_Noah_August_28_2017_22_22146_Extended_-_Neil_deGrasse_Tyson_Act_4_3dcd873d-5ebd-42fa-ab61-437b811f831a_D1503987510.info.json
#
# The act number needs to be taken from the video title of each file, so
# the new filenames won't be the same.

abort()
{
    echo "$@" >&2
    echo "Exiting" >&2
    exit 1
}

month_name_to_num()
{
    local month="$1"

    echo "January February March April May June July August September October November December" | awk '{
        MONTH="'"$month"'"
        for (i=1; i<13; i++)
            if ($i == MONTH || substr($i, 1, 3) == MONTH)
                printf("%02d", i)
    }'
}

get_date_from_filename()
{
    local filename="$1"

    local date_re="\(Jan\(uary\)\?\|Feb\(ruary\)\?\|Mar\(ch\)\?\|Apr\(il\)\?\|May\|Jun\(e\)\?\|Jul\(y\)\?\|Aug\(ust\)\?\|Sep\(tember\)\?\|Oct\(ober\)\?\|Nov\(ember\)\?\|Dec\(ember\)\?\)_[0-9]\{1,2\}_[0-9]\{4\}"
    # Some filenames contain the date more than once.
    local match="$(grep -o "$date_re" <<< "$filename" | head -1)"

    if [ -n "$match" ]; then
        local month="$(month_name_to_num "${match%%_*}")"
        local day="$(grep -o "_[0-9]\{1,2\}_" <<< "$match" | tr -d '_')"
        if [ "${#day}" -eq 1 ]; then
            day="0$day"
        fi
        local year="${match##*_}"
    fi

    echo "$year-$month-$day"
}

main()
{
    local dry_run=0 file_num=0 skip_opts=0 date_opt show
    local -a FILES
    while [ $# -gt 0 ]; do
        if [ "$skip_opts" == 1 ]; then
            FILES[file_num++]="$1"
        else
            case "$1" in
                --dry-run|-n) dry_run=1;;
                --show|-s)
                    show="$2"
                    shift;;
                --date|-d)
                    date_opt="$2"
                    shift;;
                --) skip_opts=1;;
                -*) abort "Invalid option: \`$1'";;
                *) FILES[file_num++]="$1";;
            esac
        fi
        shift
    done

    if [ -z "$show" ]; then
        abort "No show name was selected."
    fi

    # I'm too lazy to write the year and month.
    if [ "${#date_opt}" -eq 2 ]; then
        date_opt="$(date +"%Y-%m")-$date_opt"
    fi

    local MV="mv --"
    if [ "$dry_run" == 1 ]; then
        MV="echo [dry run] $MV"
    fi

    local act suffix date
    for file in "${FILES[@]}"; do
        cd $(dirname "$file") || abort "\`cd' failed."
        file="$(basename "$file")"

        if [ -n "$date_opt" ]; then
            date="$date_opt"
        else
            date="$(get_date_from_filename "$file")"
            if [ -z "$date" ]; then
                abort "$file: Failed to get the date from the filename."
            fi
        fi

        act="$(sed -ne "s/.*_[Aa]ct_\([0-9]\)_.*/\1/p" <<< "$file")"
        if [ -z "$act" ]; then
            abort "$file: Failed to get the act number from the filename."
        fi

        # The download date + extension
        suffix="${file##*_}"

        new_filename="${show}_${date}_act_${act}_${suffix}"
        if [ -e "$new_filename" ]; then
            abort "'$new_filename' Already exists."
        fi

        $MV "$file" "${show}_${date}_act_${act}_${suffix}" || abort "\`mv' failed."
    done

    exit 0
}
main "$@"
