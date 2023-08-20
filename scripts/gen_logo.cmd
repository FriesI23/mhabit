@rem Copyright 2023 Fries_I23
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.

(
flutter pub run flutter_launcher_icons --file flutter_launcher_momo_icons.yaml
) & (
flutter pub run flutter_launcher_icons
) & (
set "SOURCE_FILE=configs\flutter_launcher_incons\ic_launcher.xml"
set "TARGET_FILE=android\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml"

if not exist "%SOURCE_FILE%" (
    echo Source file does not exist: %SOURCE_FILE%
    exit /b 1
)

copy "%SOURCE_FILE%" "%TARGET_FILE%" /Y
echo Copied to: %TARGET_FILE%.
)
