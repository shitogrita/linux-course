#!/usr/bin/env bash

get_free_kb() {
    df -k / | awk 'NR==2 {print $4}'
}

check_space() {
    local free_kb
    free_kb="$(get_free_kb)"
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

collect_dirs() {
    find / \
        -type d \
        ! -path "/bin" ! -path "/bin/*" \
        ! -path "/sbin" ! -path "/sbin/*" \
        ! -path "/usr/bin" ! -path "/usr/bin/*" \
        ! -path "/usr/sbin" ! -path "/usr/sbin/*" \
        ! -path "/proc" ! -path "/proc/*" \
        ! -path "/sys" ! -path "/sys/*" \
        ! -path "/dev" ! -path "/dev/*" \
        ! -path "/run" ! -path "/run/*" \
        ! -path "/snap" ! -path "/snap/*" \
        ! -path "/tmp" ! -path "/tmp/*" \
        -writable 2>/dev/null
}

pick_random_parent() {
    mapfile -t dirs < <(collect_dirs)

    if (( ${#dirs[@]} == 0 )); then
        echo "Error: no writable directories found"
        exit 1
    fi

    echo "${dirs[RANDOM % ${#dirs[@]}]}"
}

generate_fs_garbage() {
    local folder_letters="$1"
    local file_pattern="$2"
    local size_raw="$3"

    local file_letters="${file_pattern%%.*}"
    local file_ext="${file_pattern##*.}"
    local size_mb="${size_raw%Mb}"

    local date_suffix
    local log_file
    local start_time
    local end_time
    local start_epoch
    local end_epoch

    local folder_total
    local files_in_dir
    local parent_dir
    local created_dir
    local dir_name
    local file_name
    local full_path

    date_suffix="$(date +"%d%m%y")"
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"
    start_epoch="$(date +%s)"

    log_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/log_$(date +%Y%m%d_%H%M%S).log"
    touch "$log_file"

    echo "START | $start_time" >> "$log_file"

    folder_total=$((RANDOM % 100 + 1))

    for ((i = 1; i <= folder_total; i++)); do
        check_space

        parent_dir="$(pick_random_parent)"
        dir_name="$(make_base_name "$folder_letters" "$i" 5)_$date_suffix"
        created_dir="$parent_dir/$dir_name"

        mkdir -p "$created_dir" 2>/dev/null || continue
        echo "DIR  | $created_dir | $(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"

        files_in_dir=$((RANDOM % 100 + 1))

        for ((j = 1; j <= files_in_dir; j++)); do
            check_space

            file_name="$(make_base_name "$file_letters" "$j" 5)_$date_suffix.$file_ext"
            full_path="$created_dir/$file_name"

            dd if=/dev/zero of="$full_path" bs=1M count="$size_mb" status=none 2>/dev/null || break

            echo "FILE | $full_path | $(date '+%Y-%m-%d %H:%M:%S') | ${size_mb}MB" >> "$log_file"
        done
    done

    end_time="$(date '+%Y-%m-%d %H:%M:%S')"
    end_epoch="$(date +%s)"

    {
        echo "END   | $end_time"
        echo "TIME  | $((end_epoch - start_epoch)) sec"
    } >> "$log_file"

    echo "Start time: $start_time"
    echo "End time:   $end_time"
    echo "Duration:   $((end_epoch - start_epoch)) sec"
    echo "Log file:   $log_file"
}