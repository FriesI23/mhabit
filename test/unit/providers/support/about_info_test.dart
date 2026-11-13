// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/providers/support/about_info.dart';

class _Bundle extends CachingAssetBundle {
  final requests = <String>[];
  bool fail = false;
  @override
  Future<ByteData> load(String key) async {
    requests.add(key);
    if (fail) throw StateError('asset failed');
    return ByteData.sublistView(
      Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'sourceCodeUrl': 'https://example.com/project',
            'issueTrackerUrl': 'https://example.com/issues',
            'contactEmail': '',
            'donateBuyMeACoffeeToken': '',
            'donatePaypalToken': '',
            'donateCryptoBTCAddr': '',
            'donateCryptoETHAddr': '',
            'donateCryptoBNBAddr': '',
            'donateCryptoAVAXAddr': '',
            'donateCryptoFTMAddr': '',
          }),
        ),
      ),
    );
  }
}

void main() {
  test(
    'loads and decodes the canonical bundled project configuration',
    () async {
      final bundle = _Bundle();
      final info = await loadAboutInfo(bundle: bundle);
      expect(bundle.requests, [aboutInfoFilePath]);
      expect(info.sourceCodeUrl, 'https://example.com/project');
      expect(info.issueTrackerUrl, 'https://example.com/issues');
    },
  );

  test('asset errors propagate to the workflow owner', () async {
    await expectLater(
      loadAboutInfo(bundle: _Bundle()..fail = true),
      throwsStateError,
    );
  });
}
