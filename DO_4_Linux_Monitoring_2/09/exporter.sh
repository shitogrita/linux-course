#!/usr/bin/env bash

set -euo pipefail

OUT_FILE="/var/www/html/metrics.prom"

get_cpu_usage_percent() {
    local cpu_line1 cpu_line2
    local user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 total1 idle_total1
    local user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 total2 idle_total2
    local total_delta idle_delta

    read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 _ < /proc/stat
    total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1 + steal1))
    idle_total1=$((idle1 + iowait1))

    sleep 1

    read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ < /proc/stat
    total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))
    idle_total2=$((idle2 + iowait2))

    total_delta=$((total2 - total1))
    idle_delta=$((idle_total2 - idle_total1))

    awk "BEGIN {
        if ($total_delta == 0) print 0;
        else printf \"%.2f\", (100 * ($total_delta - $idle_delta) / $total_delta)
    }"
}

get_mem_available_bytes() {
    awk '/MemAvailable:/ {print $2 * 1024}' /proc/meminfo
}

get_mem_total_bytes() {
    awk '/MemTotal:/ {print $2 * 1024}' /proc/meminfo
}

get_disk_total_bytes() {
    df -B1 / | awk 'NR==2 {print $2}'
}

get_disk_free_bytes() {
    df -B1 / | awk 'NR==2 {print $4}'
}

write_metrics() {
    local cpu_usage
    local mem_total
    local mem_available
    local disk_total
    local disk_free
    local ts

    cpu_usage="$(get_cpu_usage_percent)"
    mem_total="$(get_mem_total_bytes)"
    mem_available="$(get_mem_available_bytes)"
    disk_total="$(get_disk_total_bytes)"
    disk_free="$(get_disk_free_bytes)"
    ts="$(date +%s)"

    cat > "$OUT_FILE" <<EOF
# HELP my_node_cpu_usage_percent CPU usage percent.
# TYPE my_node_cpu_usage_percent gauge
my_node_cpu_usage_percent $cpu_usage

# HELP my_node_memory_total_bytes Total memory in bytes.
# TYPE my_node_memory_total_bytes gauge
my_node_memory_total_bytes $mem_total

# HELP my_node_memory_available_bytes Available memory in bytes.
# TYPE my_node_memory_available_bytes gauge
my_node_memory_available_bytes $mem_available

# HELP my_node_disk_total_bytes Total disk size of root filesystem in bytes.
# TYPE my_node_disk_total_bytes gauge
my_node_disk_total_bytes $disk_total

# HELP my_node_disk_free_bytes Free disk size of root filesystem in bytes.
# TYPE my_node_disk_free_bytes gauge
my_node_disk_free_bytes $disk_free

# HELP my_node_exporter_last_update_seconds Last metrics update unix time.
# TYPE my_node_exporter_last_update_seconds gauge
my_node_exporter_last_update_seconds $ts
EOF
}

write_metrics