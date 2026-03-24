#!/usr/bin/env bash

check_args() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: ./main.sh {1|2|3|4}"
        exit 1
    fi
}

validate_mode() {
    local mode="$1"

    [[ "$mode" =~ ^[1-4]$ ]] || {
        echo "Error: mode must be 1, 2, 3 or 4"
        exit 1
    }
}

check_logs_exist() {
    local base_dir
    base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    compgen -G "$base_dir/04/nginx_log_*.log" > /dev/null || {
        echo "Error: nginx logs not found in src/04"
        exit 1
    }
}