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
setlocal

for %%I in ("%~dp0..") do set "REPO_ROOT=%%~fI"
set "WORK_DIR=%TEMP%\mhabit-verify-%RANDOM%%RANDOM%"

mkdir "%WORK_DIR%" >nul 2>nul
if errorlevel 1 (
  echo Failed to create temp directory: %WORK_DIR%
  exit /b 1
)

set "BEFORE_STATUS=%WORK_DIR%\before.status"
set "AFTER_STATUS=%WORK_DIR%\after.status"
set "BEFORE_DIFF=%WORK_DIR%\before.diff"
set "AFTER_DIFF=%WORK_DIR%\after.diff"

if exist "%REPO_ROOT%\.flutter\bin" (
  set "PATH=%REPO_ROOT%\.flutter\bin;%PATH%"
)

pushd "%REPO_ROOT%"
git status --porcelain --untracked-files=all > "%BEFORE_STATUS%"
if errorlevel 1 goto fail
git diff --binary --no-ext-diff > "%BEFORE_DIFF%"
if errorlevel 1 goto fail

call "%~dp0normalize_arb.cmd"
if errorlevel 1 goto fail
call "%~dp0build_runner.cmd"
if errorlevel 1 goto fail

git status --porcelain --untracked-files=all > "%AFTER_STATUS%"
if errorlevel 1 goto fail
git diff --binary --no-ext-diff > "%AFTER_DIFF%"
if errorlevel 1 goto fail

fc /b "%BEFORE_STATUS%" "%AFTER_STATUS%" >nul
set "STATUS_COMPARE=%errorlevel%"
if %STATUS_COMPARE% GEQ 2 goto fail

fc /b "%BEFORE_DIFF%" "%AFTER_DIFF%" >nul
set "DIFF_COMPARE=%errorlevel%"
if %DIFF_COMPARE% GEQ 2 goto fail

if not "%STATUS_COMPARE%"=="0" goto delta
if not "%DIFF_COMPARE%"=="0" goto delta

popd
rmdir /s /q "%WORK_DIR%"
exit /b 0

:delta
echo Detected changes after generation:
git status --short
echo ------------------------
echo Details:
git diff
set "ERR=1"
goto cleanup

:fail
set "ERR=%errorlevel%"

:cleanup
popd
rmdir /s /q "%WORK_DIR%"
exit /b %ERR%