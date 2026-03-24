#!/bin/bash

start_time=$(date +%s.%N)

if [[ $# -ne 1 ]]; then
    echo "Error: script must be run with exactly one parameter."
    exit 1
fi

dir_path="$1"

if [[ "${dir_path: -1}" != "/" ]]; then
    echo "Error: parameter must end with '/'."
    exit 1
fi

if [[ ! -d "$dir_path" ]]; then
    echo "Error: directory does not exist."
    exit 1
fi

to_human_size() {
    local path="$1"
    du -h "$path" 2>/dev/null | awk 'NR==1 {print $1}'
}

get_file_type() {
    local file_path="$1"
    local file_info

    case "$file_path" in
        *.conf) echo "conf"; return ;;
        *.log) echo "log"; return ;;
    esac

    if [[ -x "$file_path" ]]; then
        echo "executable"
        return
    fi

    file_info=$(file -b "$file_path" 2>/dev/null)

    if [[ "$file_info" == *text* ]]; then
        echo "text"
    elif [[ "$file_info" == *archive* ]]; then
        echo "archive"
    else
        echo "unknown"
    fi
}

total_folders=$(find "$dir_path" -type d 2>/dev/null | wc -l)
total_files=$(find "$dir_path" -type f 2>/dev/null | wc -l)

conf_files=$(find "$dir_path" -type f -name "*.conf" 2>/dev/null | wc -l)
text_files=$(find "$dir_path" -type f -exec file {} + 2>/dev/null | grep -c 'text')
exec_files=$(find "$dir_path" -type f -executable 2>/dev/null | wc -l)
log_files=$(find "$dir_path" -type f -name "*.log" 2>/dev/null | wc -l)
archive_files=$(find "$dir_path" -type f \
    \( -name "*.tar" -o -name "*.gz" -o -name "*.zip" -o -name "*.rar" -o -name "*.7z" -o -name "*.bz2" \) \
    2>/dev/null | wc -l)
symlinks=$(find "$dir_path" -type l 2>/dev/null | wc -l)

echo "Total number of folders (including all nested ones) = $total_folders"

echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
folder_top=$(du -h "$dir_path" 2>/dev/null | sort -hr | head -n 5)
i=1
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    size=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | cut -f2-)
    echo "$i - $path, $size"
    ((i++))
done <<< "$folder_top"

echo "Total number of files = $total_files"

echo "Number of:"
echo "Configuration files (with the .conf extension) = $conf_files"
echo "Text files = $text_files"
echo "Executable files = $exec_files"
echo "Log files (with the extension .log) = $log_files"
echo "Archive files = $archive_files"
echo "Symbolic links = $symlinks"

echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
file_top=$(find "$dir_path" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 10)
i=1
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    size=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | cut -f2-)
    type=$(get_file_type "$path")
    echo "$i - $path, $size, $type"
    ((i++))
done <<< "$file_top"

echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
exec_top=$(find "$dir_path" -type f -executable -exec du -h {} + 2>/dev/null | sort -hr | head -n 10)
i=1
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    size=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | cut -f2-)
    md5=$(md5sum "$path" 2>/dev/null | awk '{print $1}')
    echo "$i - $path, $size, $md5"
    ((i++))
done <<< "$exec_top"

end_time=$(date +%s.%N)
execution_time=$(awk "BEGIN {printf \"%.1f\", $end_time - $start_time}")

echo "Script execution time (in seconds) = $execution_time"