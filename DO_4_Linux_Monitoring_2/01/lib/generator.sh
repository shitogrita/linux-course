#!/usr/bin/env bash

get_free_kb() {
    df / --output=avail | tail -n 1 | tr -d ' '
}

check_space() {
    local free_kb
    free_kb=$(get_free_kb)
    (( free_kb > 1048576 )) || {
        echo "Stopped: less than 1 GB free space left on /"
        exit 0
    }
}

make_base_name() {
    local letters="$1"
    local idx="$2"
    local min_len="$3"

    local name="$letters"
    local last="${letters: -1}"

    while (( ${#name} < min_len )); do
        name+="$last"
    done

    for ((i = 1; i < idx; i++)); do
        name+="$last"
    done

    echo "$name"
}

generate() {
    local base_path="$1"
    local folder_count="$2"
    local folder_letters="$3"
    local file_count="$4"
    local file_pattern="$5"
    local size_raw="$6"

    local file_letters="${file_pattern%%.*}"
    local file_ext="${file_pattern##*.}"
    local size_kb="${size_raw%kb}"
    local date_suffix
    local log_file
    local current_path="$base_path"

    date_suffix=$(date +"%d%m%y")
    log_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/log_$(date +%Y%m%d_%H%M%S).log"
    touch "$log_file"

    for ((i = 1; i <= folder_count; i++)); do
        check_space

        dir_name="$(make_base_name "$folder_letters" "$i" 4)_$date_suffix"
        current_path="$current_path/$dir_name"
        mkdir -p "$current_path"
        echo "DIR  | $current_path | $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"

        for ((j = 1; j <= file_count; j++)); do
            check_space

            file_name="$(make_base_name "$file_letters" "$j" 4)_$date_suffix.$file_ext"
            full_path="$current_path/$file_name"

            dd if=/dev/zero of="$full_path" bs=1K count="$size_kb" status=none

            echo "FILE | $full_path | $(date '+%Y-%m-%d %H:%M:%S') | ${size_kb}KB" >> "$log_file"
        done
    done

    echo "Done. Log: $log_file"
}