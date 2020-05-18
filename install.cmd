@echo off
setlocal enabledelayedexpansion

set target=%LOCALAPPDATA%\YGOFabrica

rem ==========================================
rem Copy luajit and vips
rem ==========================================

if not exist "%target%" mkdir "%target%"
xcopy luajit "%target%\luajit" /s/h/e/k/c/y/i
xcopy vips "%target%\vips" /s/h/e/k/c/y/i

rem ==========================================
rem Set environment variables
rem ==========================================

set contains=0

goto :code
:pathvar_iter
  set list=%1
  set list=%list:"=%
  for /f "tokens=1* delims=;" %%a IN ("%list%") do (
    if not "%%a" == "" call :check "%%a"
    if not "%%b" == "" call :pathvar_iter "%%b"
  )
  exit /b

:check
  set token=%1
  set token=%token:"=%
  if "%token%" == "%target%" ( set "contains=1" )
  exit /b

:code
for /f "usebackq tokens=2,*" %%A in (`reg query HKCU\Environment /v PATH`) do (
  set user_path=%%B
)

call :pathvar_iter "%user_path%"

if !contains! neq 0 ( goto :dont_set_env )

echo %user_path% > user-path-backup.txt
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
set "user_path=%target%;%user_path%"
setx PATH "%user_path%"
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )

:dont_set_env

rem ==========================================
rem Install program files
rem ==========================================

luajit\luajit make.lua install "%target%"
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
luajit\luajit make.lua config "%1"
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
if exist fonts ( luajit\luajit make.lua fonts )
echo Go to https://github.com/piface314/ygo-fabrica/wiki to learn how to use^^! :D
pause
