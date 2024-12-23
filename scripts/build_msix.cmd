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

set VERSION="unknown"
for /f "tokens=2 delims=:" %%a in ('findstr /R "^version:" pubspec.yaml') do set VERSION=%%a
set VERSION=%VERSION: =%

echo "Building %VERSION%"
dart run msix:create --architecture x64 --output-name mhabit_%VERSION%_x64
