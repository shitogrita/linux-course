#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/validate.sh"
source "$LIB_DIR/cleaner.sh"

main() {
    check_args "$@"
    validate_mode "$1"

    case "$1" in
        1) clean_by_log ;;
        2) clean_by_time ;;
        3) clean_by_mask ;;
    esac
}

main "$@"