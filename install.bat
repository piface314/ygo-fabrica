@echo off
setlocal enabledelayedexpansion

set target=%LOCALAPPDATA%\YGOFabrica
set path_ygofab=%target%
set path_lua=%target%\luajit
set path_vips=%target%\vips\bin

rem ==========================================
rem Copy luajit and vips
rem ==========================================

if not exist "%target%" mkdir "%target%"
xcopy luajit "%target%\luajit" /s/h/e/k/c/y/i
xcopy vips "%target%\vips" /s/h/e/k/c/y/i

rem ==========================================
rem Set environment variables
rem ==========================================

set contains_ygofab=0
set contains_lua=0
set contains_vips=0

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
  if "%token%" == "%path_ygofab%" ( set "contains_ygofab=1" )
  if "%token%" == "%path_lua%" ( set "contains_lua=1" )
  if "%token%" == "%path_vips%" ( set "contains_vips=1" )
  exit /b

:code
for /f "usebackq tokens=2,*" %%A in (`reg query HKCU\Environment /v PATH`) do (
  set user_path=%%B
)

call :pathvar_iter "%user_path%"

set should_set_env=0
if "!contains_vips!" == "0" (
  set "user_path=%path_vips%;%user_path%"
  set should_set_env=1
)
if "!contains_lua!" == "0" (
  set "user_path=%path_lua%;%user_path%"
  set should_set_env=1
)
if "!contains_ygofab!" == "0" (
  set "user_path=%path_ygofab%;%user_path%"
  set should_set_env=1
)

if "!should_set_env!" == "0" ( goto :dont_set_env )
  echo %user_path% > user-path-backup.txt
  if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
  setx PATH "%user_path%"
  if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
  :dont_set_env

rem ==========================================
rem Install program files
rem ==========================================

luajit\luajit make.lua install "%target%"
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
luajit\luajit make.lua config
if %ERRORLEVEL% neq 0 ( exit /b %ERRORLEVEL% )
if exist fonts ( luajit\luajit make.lua fonts )
echo.
pause
