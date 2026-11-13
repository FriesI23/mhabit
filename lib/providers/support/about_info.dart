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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/consts.dart';

part 'about_info.g.dart';

@JsonSerializable(createToJson: false)
class AboutInfo {
  final String sourceCodeUrl;
  final String issueTrackerUrl;
  final String contactEmail;
  final String donateBuyMeACoffeeToken;
  final String donatePaypalToken;
  final String donateCryptoBTCAddr;
  final String donateCryptoETHAddr;
  final String donateCryptoBNBAddr;
  final String donateCryptoAVAXAddr;
  final String donateCryptoFTMAddr;

  /// Project HTTP(S) destination, or null for invalid URLs or embedded credentials.
  Uri? get sourceCodeUri => _webUri(sourceCodeUrl);

  /// Issue destination, with the same validation as [sourceCodeUri].
  Uri? get issueTrackerUri => _webUri(issueTrackerUrl);

  static Uri? _webUri(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
            (uri.scheme == 'https' || uri.scheme == 'http') &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? uri
        : null;
  }

  const AboutInfo({
    required this.sourceCodeUrl,
    required this.issueTrackerUrl,
    required this.contactEmail,
    required this.donateBuyMeACoffeeToken,
    required this.donatePaypalToken,
    required this.donateCryptoBTCAddr,
    required this.donateCryptoETHAddr,
    required this.donateCryptoBNBAddr,
    required this.donateCryptoAVAXAddr,
    required this.donateCryptoFTMAddr,
  });

  const AboutInfo.empty()
    : sourceCodeUrl = '',
      issueTrackerUrl = '',
      contactEmail = '',
      donateBuyMeACoffeeToken = '',
      donatePaypalToken = '',
      donateCryptoBTCAddr = '',
      donateCryptoETHAddr = '',
      donateCryptoBNBAddr = '',
      donateCryptoAVAXAddr = '',
      donateCryptoFTMAddr = '';

  factory AboutInfo.fromJson(Map<String, dynamic> json) =>
      _$AboutInfoFromJson(json);
}

/// Loads the shared project configuration from the app's asset bundle.
Future<AboutInfo> loadAboutInfo({AssetBundle? bundle}) async {
  final raw = await (bundle ?? rootBundle).loadString(aboutInfoFilePath);
  final Map<String, dynamic> data = jsonDecode(raw);
  return AboutInfo.fromJson(data);
}
