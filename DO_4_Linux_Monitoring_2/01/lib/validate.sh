#!/usr/bin/env bash

check_args() {
    if [[ $# -ne 6 ]]; then
        echo "Usage: ./main.sh /absolute/path folder_count letters file_count name.ext sizekb"
        exit 1
    fi
}

validate_params() {
    local path="$1"
    local folder_count="$2"
    local folder_letters="$3"
    local file_count="$4"
    local file_pattern="$5"
    local size="$6"

    [[ "$path" =~ ^/ ]] || { echo "Error: path must be absolute"; exit 1; }
    [[ -d "$path" ]] || { echo "Error: directory does not exist"; exit 1; }

    [[ "$folder_count" =~ ^[1-9][0-9]*$ ]] || { echo "Error: folder_count must be positive"; exit 1; }
    [[ "$file_count" =~ ^[1-9][0-9]*$ ]] || { echo "Error: file_count must be positive"; exit 1; }

    [[ "$folder_letters" =~ ^[a-zA-Z]{1,7}$ ]] || { echo "Error: folder letters must be 1..7 English letters"; exit 1; }
    [[ "$file_pattern" =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]] || { echo "Error: file pattern must be name.ext"; exit 1; }

    [[ "$size" =~ ^([1-9][0-9]?|100)kb$ ]] || { echo "Error: size must be from 1kb to 100kb"; exit 1; }
}