#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/validate.sh"
source "$LIB_DIR/parser.sh"

main() {
    check_args "$@"
    validate_mode "$1"
    check_logs_exist

    case "$1" in
        1) sort_by_status ;;
        2) unique_ips ;;
        3) error_requests ;;
        4) error_unique_ips ;;
    esac
}

main "$@"