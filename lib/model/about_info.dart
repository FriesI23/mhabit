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

enum _AboutInfoKey {
  sourceCodeUrl,
  issueTrackerUrl,
  contactEmail,
  donateBuyMeACoffeeToken,
  donatePaypalToken,
  donateCryptoBTCAddr,
  donateCryptoETHAddr,
  donateCryptoBNBAddr,
  donateCryptoAVAXAddr,
  donateCryptoFTMAddr
}

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

  const AboutInfo({
    this.sourceCodeUrl = '',
    this.issueTrackerUrl = '',
    this.contactEmail = '',
    this.donateBuyMeACoffeeToken = '',
    this.donatePaypalToken = '',
    this.donateCryptoBTCAddr = '',
    this.donateCryptoETHAddr = '',
    this.donateCryptoBNBAddr = '',
    this.donateCryptoAVAXAddr = '',
    this.donateCryptoFTMAddr = '',
  });

  factory AboutInfo.fromJson(Map<String, dynamic> json) {
    return AboutInfo(
      sourceCodeUrl: json[_AboutInfoKey.sourceCodeUrl.name] ?? '',
      issueTrackerUrl: json[_AboutInfoKey.issueTrackerUrl.name] ?? '',
      contactEmail: json[_AboutInfoKey.contactEmail.name] ?? '',
      donateBuyMeACoffeeToken:
          json[_AboutInfoKey.donateBuyMeACoffeeToken.name] ?? '',
      donatePaypalToken: json[_AboutInfoKey.donatePaypalToken.name] ?? '',
      donateCryptoBTCAddr: json[_AboutInfoKey.donateCryptoBTCAddr.name] ?? '',
      donateCryptoETHAddr: json[_AboutInfoKey.donateCryptoETHAddr.name] ?? '',
      donateCryptoBNBAddr: json[_AboutInfoKey.donateCryptoBNBAddr.name] ?? '',
      donateCryptoAVAXAddr: json[_AboutInfoKey.donateCryptoAVAXAddr.name] ?? '',
      donateCryptoFTMAddr: json[_AboutInfoKey.donateCryptoFTMAddr.name] ?? '',
    );
  }
}
