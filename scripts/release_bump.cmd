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
@rem Wiki step 1 (Bump App Version) executor: confirms a version string in
@rem the terminal (logic lives in bin\bump_version.py), then runs
@rem flutter clean && make aio-full.
@rem See: docs/wiki/Dev꞉-Push-To-New-Version.md
@echo off
setlocal

if /I not "%~1"=="--version" goto usage
if "%~2"=="" goto usage
set "SUGGESTED=%~2"

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

"%POETRY_PYTHON%" bin\bump_version.py --version "%SUGGESTED%"
if errorlevel 1 (
  popd >nul
  exit /b 1
)
popd >nul

cd "%REPO_ROOT%"
echo Running flutter clean...
call flutter clean
if errorlevel 1 exit /b 1
echo Running make aio-full...
call make aio-full
if errorlevel 1 exit /b 1

exit /b 0

:usage
echo Usage: %~nx0 --version ^<x.y.z+a[-pre]^>
exit /b 2
