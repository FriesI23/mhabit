// Copyright 2023 Fries_I23
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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

mixin XShare<T extends StatefulWidget> on State<T> {
  Future<ShareResult> shareXFiles(List<XFile> files,
      {BuildContext? context,
      String? subject,
      String? text,
      List<String>? fileNameOverrides}) async {
    if (Platform.isIOS) {
      final box = (context ?? this.context).findRenderObject() as RenderBox?;
      return Share.shareXFiles(files,
          subject: subject,
          text: text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          fileNameOverrides: fileNameOverrides);
    } else {
      return Share.shareXFiles(files,
          subject: subject, text: text, fileNameOverrides: fileNameOverrides);
    }
  }

  Future<bool> pickAndSaveToFile(String savedFile,
      {String? fileName, String? subject}) async {
    fileName ??= path.basename(savedFile);
    final saveLocation = await getSaveLocation(suggestedName: fileName);
    if (saveLocation == null) return false;
    final savedFileFp = XFile(savedFile);
    await savedFileFp.saveTo(saveLocation.path);
    return await File(saveLocation.path).exists();
  }
}
