#!/usr/bin/env sh
set -eu

# 1. Определяем папку скрипта, чтобы путь работал отовсюду
SCRIPT_DIR=$(dirname "$0")
FILE="${SCRIPT_DIR}/../assets/VERSION"

# 2. Если файла нет — создаем
if [ ! -f "$FILE" ]; then
    printf "1.0" > "$FILE"
    echo "[INFO] Created VERSION file with 1.0"
    exit 0
fi

# 3. Читаем версию (чистим от пробелов и CR/LF)
current=$(cat "$FILE" | tr -d ' \r\n')

# 4. Проверяем формат (X.Y)
if ! echo "$current" | grep -qE '^[0-9]+\.[0-9]+$'; then
    echo "[ERROR] Invalid version format in $FILE: '$current'" >&2
    exit 1
fi

major=$(echo "$current" | cut -d. -f1)
minor=$(echo "$current" | cut -d. -f2)

# 5. Инкремент
minor=$((minor + 1))
if [ "$minor" -gt 9 ]; then
    major=$((major + 1))
    minor=0
fi

# 6. Запись в файл (printf безопаснее echo)
printf '%s.%s' "$major" "$minor" > "$FILE"

echo "[INFO] Version incremented from $current to $major.$minor"
