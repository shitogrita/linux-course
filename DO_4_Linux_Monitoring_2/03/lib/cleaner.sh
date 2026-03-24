#!/usr/bin/env bash

remove_path() {
    local path="$1"

    [[ -e "$path" ]] || return 0

    rm -rf -- "$path" 2>/dev/null && echo "Removed: $path"
}

clean_by_log() {
    read -r -p "Enter full path to log file: " log_file

    if [[ ! -f "$log_file" ]]; then
        echo "Error: log file not found"
        exit 1
    fi

    awk -F'|' '/^(DIR|FILE)/ {
        gsub(/^[ \t]+|[ \t]+$/, "", $2)
        print $2
    }' "$log_file" | sort -r | while IFS= read -r path; do
        remove_path "$path"
    done
}

clean_by_time() {
    read -r -p "Enter start time (YYYY-MM-DD HH:MM): " start_time
    read -r -p "Enter end time   (YYYY-MM-DD HH:MM): " end_time

    if ! date -d "$start_time" >/dev/null 2>&1; then
        echo "Error: invalid start time"
        exit 1
    fi

    if ! date -d "$end_time" >/dev/null 2>&1; then
        echo "Error: invalid end time"
        exit 1
    fi

    local start_fmt end_fmt
    start_fmt="$(date -d "$start_time" '+%Y-%m-%d %H:%M:00')"
    end_fmt="$(date -d "$end_time" '+%Y-%m-%d %H:%M:59')"

    find / \
        \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune -o \
        -newermt "$start_fmt" ! -newermt "$end_fmt" \
        \( -type f -o -type d \) \
        2>/dev/null | sort -r | while IFS= read -r path; do
            remove_path "$path"
        done
}

clean_by_mask() {
    read -r -p "Enter name mask (example: azzzz_130326): " mask

    if [[ ! "$mask" =~ ^[a-zA-Z]+_[0-9]{6}$ ]]; then
        echo "Error: invalid mask format"
        exit 1
    fi

    find / \
        \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune -o \
        \( -type f -o -type d \) -name "${mask}*" \
        2>/dev/null | sort -r | while IFS= read -r path; do
            remove_path "$path"
        done
}