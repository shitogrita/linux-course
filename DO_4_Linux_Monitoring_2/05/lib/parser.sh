#!/usr/bin/env bash

get_log_files() {
    local base_dir
    base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    echo "$base_dir"/04/nginx_log_*.log
}

sort_by_status() {
    awk '
    {
        code = $(NF-3)
        print code, $0
    }
    ' $(get_log_files) | sort -n -k1,1 | cut -d" " -f2-
}

unique_ips() {
    awk '
    !seen[$1]++ {
        print $1
    }
    ' $(get_log_files)
}

error_requests() {
    awk '
    {
        code = $(NF-3)
        if (code ~ /^(4|5)[0-9][0-9]$/) {
            print $0
        }
    }
    ' $(get_log_files)
}

error_unique_ips() {
    awk '
    {
        code = $(NF-3)
        if (code ~ /^(4|5)[0-9][0-9]$/ && !seen[$1]++) {
            print $1
        }
    }
    ' $(get_log_files)
}