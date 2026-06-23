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

for %%I in ("%~dp0") do set "SCRIPT_DIR=%%~fI"

pushd "%SCRIPT_DIR%\python-scripts"
for /f "usebackq delims=" %%I in (`poetry env info --path`) do set "POETRY_ENV_PATH=%%I"
popd

set "POETRY_PYTHON=%POETRY_ENV_PATH%\Scripts\python.exe"
if not exist "%POETRY_PYTHON%" set "POETRY_PYTHON=%POETRY_ENV_PATH%\bin\python"

"%POETRY_PYTHON%" "%SCRIPT_DIR%\python-scripts\bin\release_postgen.py" %*
exit /b %errorlevel%
