#!/usr/bin/env bash

check_args() {
    if [[ $# -ne 3 ]]; then
        echo "Usage: ./main.sh folder_letters file_name.ext sizeMb"
        exit 1
    fi
}

validate_params() {
    local folder_letters="$1"
    local file_pattern="$2"
    local size="$3"

    [[ "$folder_letters" =~ ^[a-zA-Z]{1,7}$ ]] || {
        echo "Error: folder letters must be 1..7 English letters"
        exit 1
    }

    [[ "$file_pattern" =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]] || {
        echo "Error: file pattern must be in format name.ext"
        exit 1
    }

    [[ "$size" =~ ^([1-9][0-9]?|100)Mb$ ]] || {
        echo "Error: size must be from 1Mb to 100Mb"
        exit 1
    }
}