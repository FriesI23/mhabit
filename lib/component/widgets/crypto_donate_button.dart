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

import 'package:cryptofont/cryptofont.dart';
import 'package:flutter/material.dart';

import '../../theme/color.dart';

enum CryptoDonateButtonType {
  btc,
  eth,
  bnb,
  avax,
  ftm,
}

class CryptoDonateButton extends StatelessWidget {
  final CryptoDonateButtonType cryptoType;
  final String address;
  final void Function(CryptoDonateButtonType t)? onPressed;
  final void Function(CryptoDonateButtonType t)? onLongPressed;

  const CryptoDonateButton({
    super.key,
    required this.cryptoType,
    required this.address,
    this.onPressed,
    this.onLongPressed,
  });

  IconData get buttonIcon {
    switch (cryptoType) {
      case CryptoDonateButtonType.btc:
        return CryptoFontIcons.btc;
      case CryptoDonateButtonType.eth:
        return CryptoFontIcons.eth;
      case CryptoDonateButtonType.bnb:
        return CryptoFontIcons.bnb;
      case CryptoDonateButtonType.avax:
        return CryptoFontIcons.avax;
      case CryptoDonateButtonType.ftm:
        return CryptoFontIcons.ftm;
    }
  }

  ButtonStyle? getButtonStyle() {
    switch (cryptoType) {
      case CryptoDonateButtonType.btc:
        return const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(colorBTC),
          iconColor: MaterialStatePropertyAll(Colors.white),
        );
      case CryptoDonateButtonType.eth:
        return const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(colorETH),
          iconColor: MaterialStatePropertyAll(Colors.white),
        );
      case CryptoDonateButtonType.bnb:
        return const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(colorBNB),
          iconColor: MaterialStatePropertyAll(Colors.white),
        );
      case CryptoDonateButtonType.avax:
        return const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(colorAVAX),
          iconColor: MaterialStatePropertyAll(Colors.white),
        );
      case CryptoDonateButtonType.ftm:
        return const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(colorFTM),
          iconColor: MaterialStatePropertyAll(Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed != null ? () => onPressed!(cryptoType) : null,
      onLongPress:
          onLongPressed != null ? () => onLongPressed!(cryptoType) : null,
      style: address.isNotEmpty ? getButtonStyle() : null,
      child: Icon(buttonIcon),
    );
  }
}
