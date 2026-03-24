#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

passed=0
failed=0

print_ok() {
    echo -e "${GREEN}[OK]${RESET} $1"
    ((passed++))
}

print_fail() {
    echo -e "${RED}[FAIL]${RESET} $1"
    ((failed++))
}

print_info() {
    echo -e "${YELLOW}[INFO]${RESET} $1"
}

check_contains() {
    local output="$1"
    local expected="$2"
    local test_name="$3"

    if echo "$output" | grep -Fq "$expected"; then
        print_ok "$test_name"
    else
        print_fail "$test_name"
        echo "Expected to find: $expected"
        echo "Actual output:"
        echo "$output"
        echo
    fi
}

check_file_exists() {
    local file="$1"
    local test_name="$2"

    if [[ -f "$file" ]]; then
        print_ok "$test_name"
    else
        print_fail "$test_name"
    fi
}

cleanup_status_files() {
    find . -maxdepth 1 -type f -name "*.status" -delete 2>/dev/null
}

print_info "Проверка наличия файлов скриптов"

for script in script01.sh script02.sh script03.sh script04.sh script05.sh; do
    if [[ -f "$script" ]]; then
        print_ok "Файл $script найден"
    else
        print_fail "Файл $script отсутствует"
    fi
done

echo
print_info "Проверка script01.sh"

if [[ -f script01.sh ]]; then
    chmod +x script01.sh

    out=$(./script01.sh hello 2>/dev/null)
    check_contains "$out" "hello" "script01: вывод текстового параметра"

    out=$(./script01.sh 123 2>/dev/null)
    check_contains "$out" "Invalid input" "script01: число считается некорректным вводом"
fi

echo
print_info "Проверка script02.sh"

if [[ -f script02.sh ]]; then
    chmod +x script02.sh

    cleanup_status_files
    out=$(printf 'N\n' | ./script02.sh 2>/dev/null)

    check_contains "$out" "HOSTNAME =" "script02: вывод HOSTNAME"
    check_contains "$out" "TIMEZONE =" "script02: вывод TIMEZONE"
    check_contains "$out" "USER =" "script02: вывод USER"
    check_contains "$out" "OS =" "script02: вывод OS"
    check_contains "$out" "DATE =" "script02: вывод DATE"
    check_contains "$out" "UPTIME =" "script02: вывод UPTIME"
    check_contains "$out" "UPTIME_SEC =" "script02: вывод UPTIME_SEC"
    check_contains "$out" "IP =" "script02: вывод IP"
    check_contains "$out" "MASK =" "script02: вывод MASK"
    check_contains "$out" "GATEWAY =" "script02: вывод GATEWAY"
    check_contains "$out" "RAM_TOTAL =" "script02: вывод RAM_TOTAL"
    check_contains "$out" "RAM_USED =" "script02: вывод RAM_USED"
    check_contains "$out" "RAM_FREE =" "script02: вывод RAM_FREE"
    check_contains "$out" "SPACE_ROOT =" "script02: вывод SPACE_ROOT"
    check_contains "$out" "SPACE_ROOT_USED =" "script02: вывод SPACE_ROOT_USED"
    check_contains "$out" "SPACE_ROOT_FREE =" "script02: вывод SPACE_ROOT_FREE"

    cleanup_status_files
    printf 'Y\n' | ./script02.sh >/dev/null 2>/dev/null
    status_file=$(find . -maxdepth 1 -type f -name "*.status" | head -n 1)

    if [[ -n "$status_file" ]]; then
        print_ok "script02: создаёт .status файл при ответе Y"
        rm -f "$status_file"
    else
        print_fail "script02: не создал .status файл при ответе Y"
    fi
fi

echo
print_info "Проверка script03.sh"

if [[ -f script03.sh ]]; then
    chmod +x script03.sh

    out=$(./script03.sh 1 3 4 5 2>/dev/null)
    check_contains "$out" "HOSTNAME" "script03: запускается с корректными параметрами"
    check_contains "$out" "TIMEZONE" "script03: выводит TIMEZONE"

    out=$(./script03.sh 1 1 4 5 2>/dev/null)
    check_contains "$out" "Ошибка" "script03: ловит одинаковые цвета в первом столбце"

    out=$(./script03.sh 1 3 4 4 2>/dev/null)
    check_contains "$out" "Ошибка" "script03: ловит одинаковые цвета во втором столбце"

    out=$(./script03.sh 9 3 4 5 2>/dev/null)
    check_contains "$out" "Ошибка" "script03: ловит неверный диапазон параметров"
fi

echo
print_info "Проверка script04.sh"

if [[ -f script04.sh ]]; then
    chmod +x script04.sh

    cat > config.conf <<EOF
column1_background=2
column1_font_color=4
column2_background=5
column2_font_color=1
EOF

    out=$(./script04.sh 2>/dev/null)
    check_contains "$out" "HOSTNAME" "script04: выводит системную информацию"
    check_contains "$out" "Column 1 background = 2" "script04: читает column1_background из config.conf"
    check_contains "$out" "Column 1 font color = 4" "script04: читает column1_font_color из config.conf"
    check_contains "$out" "Column 2 background = 5" "script04: читает column2_background из config.conf"
    check_contains "$out" "Column 2 font color = 1" "script04: читает column2_font_color из config.conf"

    cat > config.conf <<EOF
column1_background=
column1_font_color=
column2_background=
column2_font_color=
EOF

    out=$(./script04.sh 2>/dev/null)
    check_contains "$out" "Column 1 background = default" "script04: подставляет default для column1_background"
    check_contains "$out" "Column 1 font color = default" "script04: подставляет default для column1_font_color"
    check_contains "$out" "Column 2 background = default" "script04: подставляет default для column2_background"
    check_contains "$out" "Column 2 font color = default" "script04: подставляет default для column2_font_color"
fi

echo
print_info "Проверка script05.sh"

if [[ -f script05.sh ]]; then
    chmod +x script05.sh

    rm -rf test_dir
    mkdir -p test_dir/inner/deep
    mkdir -p test_dir/logs
    mkdir -p test_dir/bin

    echo "hello config" > test_dir/app.conf
    echo "log line" > test_dir/logs/app.log
    echo "plain text" > test_dir/readme.txt
    echo "another text" > test_dir/inner/note.txt
    echo "1234567890" > test_dir/archive.tar
    ln -sf readme.txt test_dir/link_to_readme

    cat > test_dir/bin/run.sh <<EOF
#!/bin/bash
echo hello
EOF
    chmod +x test_dir/bin/run.sh

    dd if=/dev/zero of=test_dir/bigfile.bin bs=1024 count=50 >/dev/null 2>&1
    dd if=/dev/zero of=test_dir/bin/bigexec bs=1024 count=30 >/dev/null 2>&1
    chmod +x test_dir/bin/bigexec

    out=$(./script05.sh test_dir/ 2>/dev/null)

    check_contains "$out" "Total number of folders" "script05: выводит число папок"
    check_contains "$out" "TOP 5 folders of maximum size" "script05: выводит top-5 папок"
    check_contains "$out" "Total number of files" "script05: выводит число файлов"
    check_contains "$out" "Configuration files" "script05: считает .conf файлы"
    check_contains "$out" "Text files" "script05: считает текстовые файлы"
    check_contains "$out" "Executable files" "script05: считает исполняемые файлы"
    check_contains "$out" "Log files" "script05: считает .log файлы"
    check_contains "$out" "Archive files" "script05: считает архивы"
    check_contains "$out" "Symbolic links" "script05: считает символьные ссылки"
    check_contains "$out" "TOP 10 files of maximum size" "script05: выводит top-10 файлов"
    check_contains "$out" "TOP 10 executable files of the maximum size" "script05: выводит top-10 исполняемых файлов"
    check_contains "$out" "Script execution time" "script05: выводит время выполнения"

    out=$(./script05.sh test_dir 2>/dev/null)
    check_contains "$out" "Error" "script05: отклоняет путь без завершающего /"
fi

echo
echo "Passed: $passed"
echo "Failed: $failed"

if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}Все проверки пройдены.${RESET}"
    exit 0
else
    echo -e "${RED}Есть непройденные проверки.${RESET}"
    exit 1
fi
