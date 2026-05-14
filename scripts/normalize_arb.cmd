@rem Copyright 2025 Fries_I23
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "L10N_DIR=%REPO_ROOT%\assets\l10n"
set "TEMPLATE_FILE=%L10N_DIR%\en.arb"
set "L10N_REFS_FILE=%REPO_ROOT%\configs\l10n_refs.json"
set "PYTHON_BIN="

if defined PYTHON (
  call :verify_python "%PYTHON%"
  if errorlevel 1 (
    echo Python 3.9+ interpreter not found: %PYTHON%
    exit /b 1
  )
  set "PYTHON_BIN=%PYTHON%"
) else (
  call :verify_python python3
  if errorlevel 1 (
    echo Python 3.9+ interpreter not found.
    exit /b 1
  )
  set "PYTHON_BIN=python3"
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

exit /b 0

:verify_python
%~1 -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 9) else 1)" >nul 2>nul
exit /b %errorlevel%