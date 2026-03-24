#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/validate.sh"
source "$LIB_DIR/generator.sh"

main() {
    check_environment
    generate_logs
}

main "$@"