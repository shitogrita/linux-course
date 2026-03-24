#!/bin/bash

if [[ $# -ne 4 ]]; then
    echo "Ошибка: скрипт должен запускаться с 4 параметрами."
    exit 1
fi

for param in "$1" "$2" "$3" "$4"; do
    if ! [[ "$param" =~ ^[1-6]$ ]]; then
        echo "Ошибка: параметры должны быть числами от 1 до 6."
        exit 1
    fi
done

if [[ "$1" -eq "$2" ]]; then
    echo "Ошибка: цвет фона и цвет шрифта названий совпадают."
    exit 1
fi

if [[ "$3" -eq "$4" ]]; then
    echo "Ошибка: цвет фона и цвет шрифта значений совпадают."
    exit 1
fi

get_bg_color() {
    case "$1" in
        1) echo 47 ;;
        2) echo 41 ;;
        3) echo 42 ;;
        4) echo 44 ;;
        5) echo 45 ;;
        6) echo 40 ;;
    esac
}

get_font_color() {
    case "$1" in
        1) echo 37 ;;
        2) echo 31 ;;
        3) echo 32 ;;
        4) echo 34 ;;
        5) echo 35 ;;
        6) echo 30 ;;
    esac
}

BG_NAME=$(get_bg_color "$1")
FONT_NAME=$(get_font_color "$2")
BG_VALUE=$(get_bg_color "$3")
FONT_VALUE=$(get_font_color "$4")

HOSTNAME=$(hostname)

TIMEZONE_NAME=$(timedatectl show --property=Timezone --value 2>/dev/null)
if [[ -z "$TIMEZONE_NAME" ]]; then
    TIMEZONE_NAME=$(cat /etc/timezone 2>/dev/null)
fi
UTC_OFFSET=$(date +%z | sed 's/\(..\)$/:\1/' | sed 's/^+0*/+/' | sed 's/^-0*/-/')
TIMEZONE="$TIMEZONE_NAME UTC $UTC_OFFSET"

USER_NAME="$USER"

OS="$(uname -s) $(uname -r)"

DATE_NOW=$(date +"%d %b %Y %H:%M:%S")

UPTIME=$(uptime -p | sed 's/up //')

UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)

IP_INFO=$(ip -o -4 addr show | awk '!/127.0.0.1/ {print $4; exit}')
IP=$(echo "$IP_INFO" | cut -d/ -f1)
PREFIX=$(echo "$IP_INFO" | cut -d/ -f2)

prefix_to_mask() {
    local prefix=$1
    local mask=""
    local full_octets=$((prefix / 8))
    local remainder=$((prefix % 8))
    local i
    local octet

    for ((i = 0; i < 4; i++)); do
        if ((i < full_octets)); then
            octet=255
        elif ((i == full_octets)); then
            if ((remainder == 0)); then
                octet=0
            else
                octet=$((256 - 2 ** (8 - remainder)))
            fi
        else
            octet=0
        fi

        if [[ $i -eq 0 ]]; then
            mask="$octet"
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

print_row() {
    local name="$1"
    local value="$2"
    echo -e "\e[${BG_NAME};${FONT_NAME}m${name}\e[0m = \e[${BG_VALUE};${FONT_VALUE}m${value}\e[0m"
}

print_row "HOSTNAME" "$HOSTNAME"
print_row "TIMEZONE" "$TIMEZONE"
print_row "USER" "$USER_NAME"
print_row "OS" "$OS"
print_row "DATE" "$DATE_NOW"
print_row "UPTIME" "$UPTIME"
print_row "UPTIME_SEC" "$UPTIME_SEC"
print_row "IP" "$IP"
print_row "MASK" "$MASK"
print_row "GATEWAY" "$GATEWAY"
print_row "RAM_TOTAL" "$RAM_TOTAL"
print_row "RAM_USED" "$RAM_USED"
print_row "RAM_FREE" "$RAM_FREE"
print_row "SPACE_ROOT" "$SPACE_ROOT"
print_row "SPACE_ROOT_USED" "$SPACE_ROOT_USED"
print_row "SPACE_ROOT_FREE" "$SPACE_ROOT_FREE"