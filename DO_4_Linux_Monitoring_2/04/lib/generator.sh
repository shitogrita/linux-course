#!/usr/bin/env bash

# HTTP response codes used in the generator:
# 200 - OK
# 201 - Created
# 400 - Bad Request
# 401 - Unauthorized
# 403 - Forbidden
# 404 - Not Found
# 500 - Internal Server Error
# 501 - Not Implemented
# 502 - Bad Gateway
# 503 - Service Unavailable

STATUS_CODES=(200 201 400 401 403 404 500 501 502 503)
METHODS=(GET POST PUT PATCH DELETE)
AGENTS=(
    "Mozilla/5.0"
    "Google Chrome"
    "Opera"
    "Safari"
    "Internet Explorer"
    "Microsoft Edge"
    "Crawler and bot"
    "Library and net tool"
)
URLS=(
    "/"
    "/index.html"
    "/api/v1/users"
    "/api/v1/orders"
    "/products"
    "/products/42"
    "/images/logo.png"
    "/login"
    "/logout"
    "/admin"
    "/downloads/archive.zip"
    "/docs/manual.pdf"
    "/search?q=linux"
    "/cart"
    "/checkout"
)

random_ip() {
    echo "$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 256))"
}

random_item() {
    local -n arr=$1
    echo "${arr[RANDOM % ${#arr[@]}]}"
}

random_bytes() {
    echo $((RANDOM % 50000 + 200))
}

random_referer() {
    local refs=(
        "-"
        "https://google.com/"
        "https://yandex.ru/"
        "https://github.com/"
        "https://example.com/"
    )
    echo "${refs[RANDOM % ${#refs[@]}]}"
}

month_ago_day() {
    local offset="$1"
    date -d "$offset day ago" +"%d/%b/%Y"
}

day_for_filename() {
    local offset="$1"
    date -d "$offset day ago" +"%Y-%m-%d"
}

generate_day_log() {
    local offset="$1"
    local outfile="$2"

    local day_text
    local entry_count
    local total_seconds
    local step
    local current_sec
    local remain
    local i

    day_text="$(month_ago_day "$offset")"
    entry_count="$(shuf -i 100-1000 -n 1)"

    total_seconds=86399
    current_sec=0

    : > "$outfile"

    for ((i = 1; i <= entry_count; i++)); do
        remain=$((entry_count - i + 1))

        if (( remain == 1 )); then
            current_sec=86399
        else
            step=$(( (total_seconds - current_sec) / remain ))
            (( step < 1 )) && step=1
            current_sec=$(( current_sec + RANDOM % step + 1 ))
            (( current_sec > 86399 )) && current_sec=86399
        fi

        local hh mm ss time_part
        hh=$(printf "%02d" $((current_sec / 3600)))
        mm=$(printf "%02d" $(((current_sec % 3600) / 60)))
        ss=$(printf "%02d" $((current_sec % 60)))
        time_part="${hh}:${mm}:${ss}"

        local ip code method url agent bytes referer
        ip="$(random_ip)"
        code="$(random_item STATUS_CODES)"
        method="$(random_item METHODS)"
        url="$(random_item URLS)"
        agent="$(random_item AGENTS)"
        bytes="$(random_bytes)"
        referer="$(random_referer)"

        printf '%s - - [%s:%s +0000] "%s %s HTTP/1.1" %s %s "%s" "%s"\n' \
            "$ip" "$day_text" "$time_part" "$method" "$url" "$code" "$bytes" "$referer" "$agent" \
            >> "$outfile"
    done
}

generate_logs() {
    local base_dir
    base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    for ((d = 4; d >= 0; d--)); do
        local filename
        filename="$base_dir/nginx_log_$(day_for_filename "$d").log"
        generate_day_log "$d" "$filename"
        echo "Created: $filename"
    done
}