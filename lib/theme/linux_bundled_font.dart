// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';
import 'dart:ui' show loadFontFromList;

import 'package:flutter/foundation.dart';

const linuxBundledFontFamily = 'mhabit Noto Sans CJK SC';
const linuxBundledFontPath = '/app/share/fonts/NotoSansCJKsc-Regular.otf';

typedef LinuxFontRegistrar =
    Future<void> Function(Uint8List bytes, String family);

/// Registers the Flatpak-bundled font directly with Flutter's font collection.
///
/// Flutter's Linux system font manager does not reliably discover app fonts in
/// every Flatpak environment. Registering the OTF before starting the widget
/// tree makes the family deterministic while leaving non-Flatpak Linux builds
/// unchanged when the file is absent.
Future<bool> loadLinuxBundledFont({
  TargetPlatform? platform,
  String path = linuxBundledFontPath,
  Future<bool> Function(String path)? fileExists,
  Future<Uint8List> Function(String path)? readFile,
  LinuxFontRegistrar? registerFont,
}) async {
  if ((platform ?? defaultTargetPlatform) != TargetPlatform.linux) return false;

  final exists = fileExists ?? (String path) => File(path).exists();
  if (!await exists(path)) return false;

  final read = readFile ?? (String path) => File(path).readAsBytes();
  final register = registerFont ?? _registerFont;
  await register(await read(path), linuxBundledFontFamily);
  return true;
}

Future<void> _registerFont(Uint8List bytes, String family) {
  return loadFontFromList(bytes, fontFamily: family);
}
