#!/usr/bin/env bash

check_environment() {
    command -v date >/dev/null 2>&1 || {
        echo "Error: 'date' command not found"
        exit 1
    }

    command -v shuf >/dev/null 2>&1 || {
        echo "Error: 'shuf' command not found"
        exit 1
    }
}