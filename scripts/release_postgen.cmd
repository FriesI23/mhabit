@rem Copyright 2026 Fries_I23
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
@rem
@rem Wiki steps 4-6 executor: fastlane (Android), Apple platform release
@rem notes (stable only), and Flatpak/Flathub metainfo generation.
@rem Sequencing logic lives in bin\release_postgen.py.
@rem See: docs/wiki/Dev꞉-Push-To-New-Version.md
@echo off
setlocal

if /I "%~1"=="--release" set "MODE=--release"
if /I "%~1"=="--pre" set "MODE=--pre"
if not defined MODE goto usage

for %%I in ("%~dp0") do set "SCRIPT_DIR=%%~fI"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "PYTHON_SCRIPTS_DIR=%SCRIPT_DIR%\python-scripts"

where poetry >nul 2>nul
if errorlevel 1 (
  echo Poetry is required but not found in PATH.
  exit /b 1
)

pushd "%PYTHON_SCRIPTS_DIR%" >nul
if errorlevel 1 (
  echo Failed to enter directory: %PYTHON_SCRIPTS_DIR%
  exit /b 1
)

set "POETRY_ENV_PATH="
for /f "usebackq delims=" %%I in (`poetry env info --path 2^>nul`) do set "POETRY_ENV_PATH=%%I"
if not defined POETRY_ENV_PATH (
  echo Failed to resolve Poetry environment path.
  popd >nul
  exit /b 1
)

set "POETRY_PYTHON=%POETRY_ENV_PATH%\Scripts\python.exe"
if not exist "%POETRY_PYTHON%" set "POETRY_PYTHON=%POETRY_ENV_PATH%\bin\python"
if not exist "%POETRY_PYTHON%" (
  echo Poetry environment python not found: %POETRY_ENV_PATH%
  popd >nul
  exit /b 1
)

"%POETRY_PYTHON%" bin\release_postgen.py %MODE%
set "ERR=%errorlevel%"

popd >nul
exit /b %ERR%

:usage
echo Usage: %~nx0 --release ^| --pre
exit /b 2
