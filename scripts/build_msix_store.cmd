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

set VERSION="unknown"
for /f "tokens=2 delims=:" %%a in ('findstr /R "^version:" pubspec.yaml') do set VERSION=%%a
set VERSION=%VERSION: =%
set APP_FLAVOR_WIN=f_store

(
flutter clean
) & (
flutter pub get
) & (
echo "Building %VERSION% %APP_FLAVOR_WIN%"
dart run msix:create ^
  --store ^
  --publisher-display-name "Friesi23" ^
  --identity-name "Friesi23.TableHabit" ^
  --publisher "CN=3BB3CB8F-3864-4B77-A661-8BDE306E6916" ^
  --toast-activator-clsid "b945836b-7d0d-4c60-b3fa-df184e2a9893" ^
  --toast-activator-display-name "Table Habit" ^
  --architecture "x64" ^
  --output-name "mhabit_%VERSION%_x64_store"
)