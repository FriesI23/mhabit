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

for %%I in ("%~dp0") do set "SCRIPT_DIR=%%~fI"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"

pushd "%SCRIPT_DIR%\python-scripts"
for /f "usebackq delims=" %%I in (`poetry env info --path`) do set "POETRY_ENV_PATH=%%I"
popd

set "POETRY_PYTHON=%POETRY_ENV_PATH%\Scripts\python.exe"
if not exist "%POETRY_PYTHON%" set "POETRY_PYTHON=%POETRY_ENV_PATH%\bin\python"

"%POETRY_PYTHON%" "%SCRIPT_DIR%\python-scripts\bin\bump_version.py" %*
if errorlevel 1 exit /b 1

cd "%REPO_ROOT%"
call flutter clean
if errorlevel 1 exit /b 1
call make aio-full
if errorlevel 1 exit /b 1
