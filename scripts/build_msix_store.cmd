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

set VERSION="unknown"
for /f "tokens=2 delims=:" %%a in ('findstr /R "^version:" pubspec.yaml') do set VERSION=%%a
set VERSION=%VERSION: =%
set "BUILD_ARCH=x64"
call .flutter\bin\dart.bat --version 2>&1 | findstr /C:"windows_arm64" >nul
if not errorlevel 1 set "BUILD_ARCH=arm64"
echo "Building %VERSION% f_store"
call .flutter\bin\flutter.bat build windows --release --flavor f_store --dart-define=APP_DISTRIBUTION=microsoft_store
if errorlevel 1 exit /b %errorlevel%
if not exist "build\windows\%BUILD_ARCH%\f_store\runner\Release\mhabit.exe" (
  echo Native Windows build output was not found. >&2
  exit /b 1
)

@rem Keep the MSIX input-layout adapter outside the native build configuration.
set "BUNDLE_PATH=%CD%\build\windows\%BUILD_ARCH%\f_store\runner\Release"
set "MSIX_INPUT_PATH=%CD%\build\windows\runner\Release"
if exist "build\windows\%BUILD_ARCH%\runner" (
  echo Clear legacy Windows build outputs before packaging. >&2
  exit /b 1
)
if not exist "build\windows\runner" mkdir "build\windows\runner"
mklink /J "%MSIX_INPUT_PATH%" "%BUNDLE_PATH%" >nul
if errorlevel 1 exit /b %errorlevel%
call .flutter\bin\dart.bat run msix:create ^
  --build-windows false ^
  --architecture %BUILD_ARCH% ^
  --output-path "%BUNDLE_PATH%" ^
  --store ^
  --publisher-display-name "Friesi23" ^
  --identity-name "Friesi23.TableHabit" ^
  --publisher "CN=3BB3CB8F-3864-4B77-A661-8BDE306E6916" ^
  --toast-activator-clsid "b945836b-7d0d-4c60-b3fa-df184e2a9893" ^
  --toast-activator-display-name "Table Habit" ^
  --output-name "mhabit_%VERSION%_%BUILD_ARCH%_store"
set "MSIX_EXIT_CODE=%errorlevel%"
rmdir "%MSIX_INPUT_PATH%"
if "%MSIX_EXIT_CODE%"=="0" if defined GITHUB_OUTPUT (
  echo msix-path=build/windows/%BUILD_ARCH%/f_store/runner/Release/mhabit_%VERSION%_%BUILD_ARCH%_store.msix>>"%GITHUB_OUTPUT%"
)
exit /b %MSIX_EXIT_CODE%
