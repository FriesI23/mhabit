// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:mhabit/providers/support/about_info.dart';

AboutInfo stubAboutInfo({
  String sourceCodeUrl = 'https://example.com/project',
  String issueTrackerUrl = '',
}) => AboutInfo(
  sourceCodeUrl: sourceCodeUrl,
  issueTrackerUrl: issueTrackerUrl,
  contactEmail: '',
  donateBuyMeACoffeeToken: '',
  donatePaypalToken: '',
  donateCryptoBTCAddr: '',
  donateCryptoETHAddr: '',
  donateCryptoBNBAddr: '',
  donateCryptoAVAXAddr: '',
  donateCryptoFTMAddr: '',
);
