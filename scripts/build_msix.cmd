@rem Copyright 2024 Fries_I23
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

echo "Building %VERSION%"
call .flutter\bin\flutter.bat build windows --release --flavor f_generic
if errorlevel 1 exit /b %errorlevel%
if not exist "build\windows\%BUILD_ARCH%\f_generic\runner\Release\mhabit.exe" (
  echo Native Windows build output was not found. >&2
  exit /b 1
)

@rem MSIX 3.18 only reads legacy input paths. Map the existing native bundle
@rem for packaging, then remove only the junction (never its target).
set "BUNDLE_PATH=%CD%\build\windows\%BUILD_ARCH%\f_generic\runner\Release"
set "MSIX_INPUT_PATH=%CD%\build\windows\runner\Release"
if exist "build\windows\%BUILD_ARCH%\runner" (
  echo Clear legacy Windows build outputs before packaging. >&2
  exit /b 1
)
if not exist "build\windows\runner" mkdir "build\windows\runner"
mklink /J "%MSIX_INPUT_PATH%" "%BUNDLE_PATH%" >nul
if errorlevel 1 exit /b %errorlevel%
call .flutter\bin\dart.bat run msix:create --build-windows false --architecture %BUILD_ARCH% --output-path "%BUNDLE_PATH%" --output-name mhabit_%VERSION%_%BUILD_ARCH%
set "MSIX_EXIT_CODE=%errorlevel%"
rmdir "%MSIX_INPUT_PATH%"
exit /b %MSIX_EXIT_CODE%
