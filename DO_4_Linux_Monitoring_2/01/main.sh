#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

source "$LIB_DIR/validate.sh"
source "$LIB_DIR/generator.sh"

main() {
    check_args "$@"
    validate_params "$1" "$2" "$3" "$4" "$5" "$6"

    generate "$1" "$2" "$3" "$4" "$5" "$6"
}

main "$@"