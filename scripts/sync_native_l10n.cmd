@rem Copyright 2026 Fries_I23
@rem Licensed under the Apache License, Version 2.0.
@echo off
setlocal enabledelayedexpansion
goto main

:fill_native_strings
set "ARB_DIR=%~1"
set "OUTPUT_ROOT=%~2"
set "REFS=%~3"
set "TABLE_NAME=%~4"
if defined CHECK (
  echo Checking !OUTPUT_ROOT!...
) else (
  echo Generating !OUTPUT_ROOT!...
)
set "FOUND="
for %%F in ("%ARB_DIR%\*.arb") do (
  if exist "%%~fF" (
    set "FOUND=1"
    set "LOCALE=%%~nF"
    set "NATIVE_LOCALE=!LOCALE:_=-!"
    if /I "!LOCALE!"=="zh" set "NATIVE_LOCALE=zh-Hans"
    if /I "!LOCALE!"=="zh_hant" set "NATIVE_LOCALE=zh-Hant"
    set "REQUIRE="
    if "!LOCALE!"=="en" set "REQUIRE=--require-sources"
    "%POETRY_PYTHON%" bin\fill_strings_from_arb.py ^
      --input "%%~fF" ^
      --output "!OUTPUT_ROOT!\!NATIVE_LOCALE!.lproj\!TABLE_NAME!" ^
      --refs "!REFS!" !CHECK! !REQUIRE!
    set "STATUS=!errorlevel!"
    if !STATUS! GEQ 2 exit /b !STATUS!
    if !STATUS!==1 set "RESULT=1"
  )
)
if not defined FOUND (
  echo No ARB files found in %ARB_DIR%
  exit /b 2
)
exit /b 0

:main
for %%I in ("%~dp0..") do set "REPO_ROOT=%%~fI"
set "CHECK="
if not "%~2"=="" goto usage_error
if "%~1"=="" goto environment
if "%~1"=="--check" (
  set "CHECK=--check"
  goto environment
)
if "%~1"=="--help" goto help
if "%~1"=="-h" goto help
goto usage_error

:environment
where poetry >nul 2>nul
if errorlevel 1 (
  echo Poetry is required but not found in PATH.
  exit /b 2
)
pushd "%REPO_ROOT%\scripts\python-scripts" >nul
if errorlevel 1 exit /b 2
set "POETRY_ENV_PATH="
for /f "usebackq delims=" %%I in (`poetry env info --path 2^>nul`) do set "POETRY_ENV_PATH=%%I"
if not defined POETRY_ENV_PATH (
  echo Failed to resolve Poetry environment path.
  set "EXIT_CODE=2"
  goto cleanup
)
set "POETRY_PYTHON=%POETRY_ENV_PATH%\Scripts\python.exe"
if not exist "%POETRY_PYTHON%" set "POETRY_PYTHON=%POETRY_ENV_PATH%\bin\python"
if not exist "%POETRY_PYTHON%" (
  echo Poetry environment python not found: %POETRY_ENV_PATH%
  set "EXIT_CODE=2"
  goto cleanup
)
set "RESULT=0"

@rem Native table calls.
call :fill_native_strings ^
  "%REPO_ROOT%\assets\l10n" ^
  "%REPO_ROOT%\ios\HabitWidget\Extension" ^
  "%REPO_ROOT%\configs\l10n_strings_refs.json" ^
  "Localizable.strings"
if errorlevel 2 goto fill_error
@rem End native table calls.

set "EXIT_CODE=%RESULT%"
goto cleanup

:fill_error
set "EXIT_CODE=%errorlevel%"

:cleanup
popd >nul
exit /b %EXIT_CODE%

:help
echo Usage: %~nx0 [--check]
exit /b 0

:usage_error
echo Invalid arguments. Use --help for usage.
exit /b 2
