<!--
 Copyright 2024 Fries_I23

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

## [2024-10-10] meet "source value 8 is obsolete and will be removed in a future release" on building apk

If you see the messages below while building your Android app,
it’s because `Android Studio Ladybug` upgrade has updated the JDK version to 21.

```log
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
```

These warnings are harmless; you can choose to ignore them or simply use JDK 17 instead of 21.

```shell
# macos arm64
brew install openjdk@17
flutter config --jdk-dir /opt/homebrew/opt/openjdk@17
```
