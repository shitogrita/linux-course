#!/usr/bin/env bash

check_args() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: ./main.sh {1|2|3}"
        exit 1
    fi
}

validate_mode() {
    local mode="$1"

    if [[ ! "$mode" =~ ^[123]$ ]]; then
        echo "Error: mode must be 1, 2 or 3"
        exit 1
    fi
}