@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "L10N_DIR=%REPO_ROOT%\assets\l10n"
set "TEMPLATE_FILE=%L10N_DIR%\en.arb"
set "L10N_REFS_FILE=%REPO_ROOT%\configs\l10n_refs.json"

if defined PYTHON (
  set "PYTHON_BIN=%PYTHON%"
) else (
  where python >nul 2>nul
  if not errorlevel 1 (
    set "PYTHON_BIN=python"
  ) else (
    where python3 >nul 2>nul
    if not errorlevel 1 (
      set "PYTHON_BIN=python3"
    ) else (
      echo Python interpreter not found.
      exit /b 1
    )
  )
)

echo Normalizing ARB files from %L10N_DIR%
for %%F in ("%L10N_DIR%\*.arb") do (
  if /I "%%~fF"=="%TEMPLATE_FILE%" (
    "%PYTHON_BIN%" "%SCRIPT_DIR%normalize_arb.py" ^
      -i "%%~fF" -t "%TEMPLATE_FILE%" -o "%%~fF" --refs "%L10N_REFS_FILE%" ^
      --indent 4
  ) else (
    "%PYTHON_BIN%" "%SCRIPT_DIR%normalize_arb.py" ^
      -i "%%~fF" -t "%TEMPLATE_FILE%" -o "%%~fF" --refs "%L10N_REFS_FILE%" ^
      --indent 4 --ignore-empty-meta
  )

  if errorlevel 1 (
    set "ERR=!errorlevel!"
    exit /b !ERR!
  )

  echo Done[0]: %%~fF
)