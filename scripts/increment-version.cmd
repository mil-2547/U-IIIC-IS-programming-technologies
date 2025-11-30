@echo off
setlocal EnableDelayedExpansion

:: %~dp0 — это путь к папке скрипта (например, C:\Project\scripts\)
:: Мы поднимаемся на уровень выше (..) и заходим в assets
set "FILE=%~dp0..\assets\VERSION"

:: Нормализация пути (убираем .. чтобы было красиво), необязательно, но полезно
for %%I in ("%FILE%") do set "FILE=%%~fI"

if not exist "%FILE%" (
    echo 1.0> "%FILE%"
    echo [INFO] Created VERSION file with 1.0
    exit /b 0
)

:: Читаем текущую версию
for /f "usebackq tokens=1,2 delims=." %%A in ("%FILE%") do (
    set "major=%%A"
    set "minor=%%B"
)

:: Сохраняем старую версию для красивого вывода
set "old_major=!major!"
set "old_minor=!minor!"

:: Убираем пробелы (на всякий случай)
for /f "tokens=* delims= " %%A in ("!major!") do set "major=%%A"
for /f "tokens=* delims= " %%B in ("!minor!") do set "minor=%%B"

:: Математика
set /a minor+=1
if !minor! GTR 9 (
    set /a major+=1
    set minor=0
)

:: Записываем БЕЗ пробела перед >
echo !major!.!minor!> "%FILE%"

echo [INFO] Version incremented from !old_major!.!old_minor! to !major!.!minor!

endlocal
