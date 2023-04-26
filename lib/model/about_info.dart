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

import '../common/consts.dart';

enum _AboutInfoKey {
  sourceCodeUrl,
  issueTrackerUrl,
  contactEmail,
  donateBuyMeACoffeeToken,
  donatePaypalToken,
}

class AboutInfo {
  String _sourceCodeUrl;
  String _issueTrackerUrl;
  String _contactEmail;
  String _donateBuyMeACoffeeToken;
  String _donatePaypalToken;

  AboutInfo({
    String? sourceCodeUrl,
    String? issueTrackerUrl,
    String? contactEmail,
    String? donateBuyMeACoffeeToken,
    String? donatePaypalToken,
  })  : _sourceCodeUrl = sourceCodeUrl ?? '',
        _issueTrackerUrl = issueTrackerUrl ?? '',
        _contactEmail = contactEmail ?? '',
        _donateBuyMeACoffeeToken = donateBuyMeACoffeeToken ?? '',
        _donatePaypalToken = donatePaypalToken ?? '';

  String get sourceCodeUrl => _sourceCodeUrl;

  String get issueTrackerUrl => _issueTrackerUrl;

  String get contactEmail => _contactEmail;

  String get donateBuyMeACoffeeToken => _donateBuyMeACoffeeToken;

  String get donatePaypalToken => _donatePaypalToken;

  Future<void> loadData() async {
    String rawJson = await rootBundle.loadString(aboutInfoFilePath);
    Map<String, Object?> data = jsonDecode(rawJson);
    if (data.containsKey(_AboutInfoKey.sourceCodeUrl.name)) {
      _sourceCodeUrl = data[_AboutInfoKey.sourceCodeUrl.name] as String;
    }
    if (data.containsKey(_AboutInfoKey.issueTrackerUrl.name)) {
      _issueTrackerUrl = data[_AboutInfoKey.issueTrackerUrl.name] as String;
    }
    if (data.containsKey(_AboutInfoKey.contactEmail.name)) {
      _contactEmail = data[_AboutInfoKey.contactEmail.name] as String;
    }
    if (data.containsKey(_AboutInfoKey.donateBuyMeACoffeeToken.name)) {
      _donateBuyMeACoffeeToken =
          data[_AboutInfoKey.donateBuyMeACoffeeToken.name] as String;
    }
    if (data.containsKey(_AboutInfoKey.donatePaypalToken.name)) {
      _donatePaypalToken = data[_AboutInfoKey.donatePaypalToken.name] as String;
    }
  }
}
