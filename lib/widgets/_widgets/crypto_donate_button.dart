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

import '../../extensions/color_extensions.dart';
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
  final void Function()? onPressed;
  final void Function()? onLongPressed;

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
    ButtonStyle buildStyle(WidgetStatePropertyAll<Color> color) => ButtonStyle(
          backgroundColor: color,
          iconColor: const WidgetStatePropertyAll(Colors.white),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed)
                ? color.value.darken(0.1)
                : null,
          ),
        );

    switch (cryptoType) {
      case CryptoDonateButtonType.btc:
        return buildStyle(const WidgetStatePropertyAll(colorBTC));
      case CryptoDonateButtonType.eth:
        return buildStyle(const WidgetStatePropertyAll(colorETH));
      case CryptoDonateButtonType.bnb:
        return buildStyle(const WidgetStatePropertyAll(colorBNB));
      case CryptoDonateButtonType.avax:
        return buildStyle(const WidgetStatePropertyAll(colorAVAX));
      case CryptoDonateButtonType.ftm:
        return buildStyle(const WidgetStatePropertyAll(colorFTM));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      onLongPress: onLongPressed != null ? () => onLongPressed!() : null,
      style: address.isNotEmpty ? getButtonStyle() : null,
      child: Icon(buttonIcon),
    );
  }
}
