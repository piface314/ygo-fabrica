@echo off
setlocal enabledelayedexpansion

rem === Set locale ===

for /F "delims==" %%A in ('systeminfo.exe ^|  findstr ";"') do  (
    for /F "usebackq tokens=2-3 delims=:;" %%B in (`echo %%A`) do (
        for /F "usebackq tokens=1 delims=-" %%C in (`echo %%B`) do (
            for /F "usebackq tokens=1 delims= " %%D in (`echo %%C`) do (
                set locale=%%D
            )
        )
    set | findstr /I locale
    goto :GOTLOCALE
    )
)
:GOTLOCALE

rem === Install program files ===
luajit\luajit make.lua install --locale !locale!
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
luajit\luajit make.lua config "%1" --locale !locale!
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
pause
