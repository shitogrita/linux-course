#!/usr/bin/env bash

LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../04" && pwd)"
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_FILE="$OUTPUT_DIR/report.html"

check_goaccess() {
    command -v goaccess >/dev/null 2>&1 || {
        echo "Error: goaccess is not installed"
        echo "Install it with: sudo apt install goaccess"
        exit 1
    }
}

check_logs() {
    compgen -G "$LOG_DIR/nginx_log_*.log" > /dev/null || {
        echo "Error: logs from Part 4 not found in src/04"
        exit 1
    }
}

run_goaccess_terminal() {
    goaccess "$LOG_DIR"/nginx_log_*.log \
        --log-format=COMBINED
}

run_goaccess_html() {
    goaccess "$LOG_DIR"/nginx_log_*.log \
        --log-format=COMBINED \
        -o "$REPORT_FILE"

    echo "HTML report created: $REPORT_FILE"
}

run_goaccess_web() {
    goaccess "$LOG_DIR"/nginx_log_*.log \
        --log-format=COMBINED \
        --real-time-html \
        --addr=0.0.0.0 \
        --port=7890 \
        -o "$REPORT_FILE"
}

main() {
    check_goaccess
    check_logs

    case "$1" in
        1) run_goaccess_terminal ;;
        2) run_goaccess_html ;;
        3) run_goaccess_web ;;
        *)
            echo "Usage: ./main.sh {1|2|3}"
            echo "1 - terminal interface"
            echo "2 - generate HTML report"
            echo "3 - real-time web interface"
            exit 1
            ;;
    esac
}

main "$@"