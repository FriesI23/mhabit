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

@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "TOOLS_DIR=%REPO_ROOT%\tools"

if defined DART (
  set "DART_BIN=%DART%"
) else if exist "%REPO_ROOT%\.flutter\bin\dart.bat" (
  set "DART_BIN=%REPO_ROOT%\.flutter\bin\dart.bat"
) else (
  set "DART_BIN=dart"
)

pushd "%TOOLS_DIR%" >nul || exit /b 1

call :run_icon_target "..\assets\icons\sort_icons" "..\assets\fonts\sort_icons.otf" "..\lib\theme\_icons\sort_icons.g.dart" "HabitSortIcons" "HabitSortIcons"
if errorlevel 1 goto :fail

call :run_icon_target "..\assets\icons\calendar_icons" "..\assets\fonts\cal_icons.otf" "..\lib\theme\_icons\cal_icons.g.dart" "HabitCalIcons" "HabitCalIcons"
if errorlevel 1 goto :fail

call :run_icon_target "..\assets\icons\progress_icons" "..\assets\fonts\progress_icons.otf" "..\lib\theme\_icons\progress_icons.g.dart" "HabitProgressIcons" "HabitProgressIcons"
if errorlevel 1 goto :fail

call :run_icon_target "..\assets\icons\common_icons" "..\assets\fonts\common_icons.otf" "..\lib\theme\_icons\common_icons.g.dart" "CommonIcons" "CommonIcons"
if errorlevel 1 goto :fail

popd >nul
exit /b 0

:run_icon_target
"%DART_BIN%" run bin\gen_icons.dart "%~1" "%~2" --output-class-file="%~3" --class-name=%~4 --font-name=%~5 --format
exit /b %errorlevel%

:fail
set "EXIT_CODE=%errorlevel%"
popd >nul
exit /b %EXIT_CODE%