#!/bin/bash

HOSTNAME=$(hostname)

TIMEZONE="$(cat /etc/timezone 2>/dev/null) UTC $(date +%z | sed 's/\(..\)$/ \1/' | awk '{print $1}')"

USER_NAME="$USER"

OS="$(uname -s) $(uname -r)"

DATE_NOW=$(date +"%d %b %Y %H:%M:%S")

UPTIME=$(uptime -p | sed 's/up //')

UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)

IP_INFO=$(ip -o -f inet addr show | awk '!/127.0.0.1/ {print $4; exit}')
IP=$(echo "$IP_INFO" | cut -d/ -f1)
PREFIX=$(echo "$IP_INFO" | cut -d/ -f2)

MASK=$(ipcalc "$IP_INFO" 2>/dev/null | awk -F= '/NETMASK/ {print $2}')

GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

RAM_TOTAL=$(free | awk '/Mem:/ {printf "%.3f GB", $2/1024/1024}')
RAM_USED=$(free | awk '/Mem:/ {printf "%.3f GB", $3/1024/1024}')
RAM_FREE=$(free | awk '/Mem:/ {printf "%.3f GB", $4/1024/1024}')

SPACE_ROOT=$(df / --block-size=1M | awk 'NR==2 {printf "%.2f MB", $2}')
SPACE_ROOT_USED=$(df / --block-size=1M | awk 'NR==2 {printf "%.2f MB", $3}')
SPACE_ROOT_FREE=$(df / --block-size=1M | awk 'NR==2 {printf "%.2f MB", $4}')

OUTPUT="HOSTNAME = $HOSTNAME
TIMEZONE = $TIMEZONE
USER = $USER_NAME
OS = $OS
DATE = $DATE_NOW
UPTIME = $UPTIME
UPTIME_SEC = $UPTIME_SEC
IP = $IP
MASK = $MASK
GATEWAY = $GATEWAY
RAM_TOTAL = $RAM_TOTAL
RAM_USED = $RAM_USED
RAM_FREE = $RAM_FREE
SPACE_ROOT = $SPACE_ROOT
SPACE_ROOT_USED = $SPACE_ROOT_USED
SPACE_ROOT_FREE = $SPACE_ROOT_FREE"

echo "$OUTPUT"

read -p "Write data to a file? (Y/N): " answer

if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    FILE_NAME=$(date +"%d_%m_%y_%H_%M_%S").status
    echo "$OUTPUT" > "$FILE_NAME"
fi