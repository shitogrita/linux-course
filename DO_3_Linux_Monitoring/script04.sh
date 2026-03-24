#!/bin/bash

default_bg1=6
default_font1=1
default_bg2=2
default_font2=4

source config.conf 2>/dev/null

bg1=${column1_background:-$default_bg1}
font1=${column1_font_color:-$default_font1}
bg2=${column2_background:-$default_bg2}
font2=${column2_font_color:-$default_font2}

if [[ "$bg1" -eq "$font1" || "$bg2" -eq "$font2" ]]; then
    echo "Ошибка: цвет фона и шрифта одного столбца совпадают."
    echo "Исправьте config.conf и повторно вызовите скрипт."
    exit 1
fi

get_bg() {
    case $1 in
        1) echo 47 ;;
        2) echo 41 ;;
        3) echo 42 ;;
        4) echo 44 ;;
        5) echo 45 ;;
        6) echo 40 ;;
    esac
}

get_font() {
    case $1 in
        1) echo 37 ;;
        2) echo 31 ;;
        3) echo 32 ;;
        4) echo 34 ;;
        5) echo 35 ;;
        6) echo 30 ;;
    esac
}

get_name() {
    case $1 in
        1) echo "white" ;;
        2) echo "red" ;;
        3) echo "green" ;;
        4) echo "blue" ;;
        5) echo "purple" ;;
        6) echo "black" ;;
    esac
}

code_bg1=$(get_bg "$bg1")
code_font1=$(get_font "$font1")
code_bg2=$(get_bg "$bg2")
code_font2=$(get_font "$font2")

HOSTNAME=$(hostname)

TIMEZONE_NAME=$(timedatectl show --property=Timezone --value 2>/dev/null)
if [[ -z "$TIMEZONE_NAME" ]]; then
    TIMEZONE_NAME=$(cat /etc/timezone 2>/dev/null)
fi
UTC_OFFSET=$(date +%z | sed 's/\(..\)$/ \1/' | awk '{print $1}')
TIMEZONE="$TIMEZONE_NAME UTC $UTC_OFFSET"

USER_NAME=$USER
OS="$(uname -s) $(uname -r)"
DATE_NOW=$(date +"%d %b %Y %H:%M:%S")
UPTIME=$(uptime -p | sed 's/up //')
UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)

IP_INFO=$(ip -o -4 addr show | awk '!/127.0.0.1/ {print $4; exit}')
IP=$(echo "$IP_INFO" | cut -d/ -f1)
PREFIX=$(echo "$IP_INFO" | cut -d/ -f2)

prefix_to_mask() {
    local p=$1
    local mask=""
    local full=$((p / 8))
    local rem=$((p % 8))

    for i in 0 1 2 3; do
        if (( i < full )); then
            octet=255
        elif (( i == full && rem != 0 )); then
            octet=$((256 - 2 ** (8 - rem)))
        else
            octet=0
        fi

        if [[ $i -eq 0 ]]; then
            mask=$octet
        else
            mask="$mask.$octet"
        fi
    done

    echo "$mask"
}

MASK=$(prefix_to_mask "$PREFIX")
GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

RAM_TOTAL=$(free -b | awk '/Mem:/ {printf "%.3f GB", $2/1024/1024/1024}')
RAM_USED=$(free -b | awk '/Mem:/ {printf "%.3f GB", $3/1024/1024/1024}')
RAM_FREE=$(free -b | awk '/Mem:/ {printf "%.3f GB", $4/1024/1024/1024}')

SPACE_ROOT=$(df / --block-size=1M | awk 'NR==2 {printf "%.2f MB", $2}')
SPACE_ROOT_USED=$(df / --block-size=1M | awk 'NR==2 {printf "%.2f MB", $3}')
SPACE_ROOT_FREE=$(df / --block-size=1M | awk 'NR==2 {printf "%.2f MB", $4}')

print_line() {
    echo -e "\e[${code_bg1};${code_font1}m$1\e[0m = \e[${code_bg2};${code_font2}m$2\e[0m"
}

print_line "HOSTNAME" "$HOSTNAME"
print_line "TIMEZONE" "$TIMEZONE"
print_line "USER" "$USER_NAME"
print_line "OS" "$OS"
print_line "DATE" "$DATE_NOW"
print_line "UPTIME" "$UPTIME"
print_line "UPTIME_SEC" "$UPTIME_SEC"
print_line "IP" "$IP"
print_line "MASK" "$MASK"
print_line "GATEWAY" "$GATEWAY"
print_line "RAM_TOTAL" "$RAM_TOTAL"
print_line "RAM_USED" "$RAM_USED"
print_line "RAM_FREE" "$RAM_FREE"
print_line "SPACE_ROOT" "$SPACE_ROOT"
print_line "SPACE_ROOT_USED" "$SPACE_ROOT_USED"
print_line "SPACE_ROOT_FREE" "$SPACE_ROOT_FREE"

echo

if [[ -z "$column1_background" ]]; then
    echo "Column 1 background = default ($(get_name "$bg1"))"
else
    echo "Column 1 background = $bg1 ($(get_name "$bg1"))"
fi

if [[ -z "$column1_font_color" ]]; then
    echo "Column 1 font color = default ($(get_name "$font1"))"
else
    echo "Column 1 font color = $font1 ($(get_name "$font1"))"
fi

if [[ -z "$column2_background" ]]; then
    echo "Column 2 background = default ($(get_name "$bg2"))"
else
    echo "Column 2 background = $bg2 ($(get_name "$bg2"))"
fi

if [[ -z "$column2_font_color" ]]; then
    echo "Column 2 font color = default ($(get_name "$font2"))"
else
    echo "Column 2 font color = $font2 ($(get_name "$font2"))"
fi