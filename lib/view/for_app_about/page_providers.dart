// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../model/about_info.dart';

class PageProviders extends SingleChildStatelessWidget {
  const PageProviders({super.key, super.child});

  Future<AboutInfo> loadAboutInfoData() async {
    String rawJson = await rootBundle.loadString(aboutInfoFilePath);
    Map<String, Object?> data = jsonDecode(rawJson);
    return AboutInfo.fromJson(data);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          FutureProvider<AboutInfo>(
            create: (_) async => loadAboutInfoData(),
            initialData: const AboutInfo(),
          ),
        ],
        child: child,
      );
}
