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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../extensions/color_extensions.dart';
import '../../theme/color.dart';

enum CryptoDonateButtonType { btc, eth, bnb, avax, ftm }

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
        return SimpleIcons.bitcoin;
      case CryptoDonateButtonType.eth:
        return SimpleIcons.ethereum;
      case CryptoDonateButtonType.bnb:
        return SimpleIcons.binance;
      case CryptoDonateButtonType.avax:
        return Icons.change_history;
      case CryptoDonateButtonType.ftm:
        return SimpleIcons.fantom;
    }
  }

  ButtonStyle getButtonStyle() => ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(brandColor),
    iconColor: WidgetStatePropertyAll(brandForegroundColor),
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (states) =>
          states.contains(WidgetState.pressed) ? brandColor.darken(0.1) : null,
    ),
  );

  // Dark icons keep the brighter brand backgrounds legible.
  Color get brandForegroundColor => switch (cryptoType) {
    CryptoDonateButtonType.avax => Colors.white,
    CryptoDonateButtonType.btc ||
    CryptoDonateButtonType.eth ||
    CryptoDonateButtonType.bnb ||
    CryptoDonateButtonType.ftm => Colors.black,
  };

  Color get brandColor => switch (cryptoType) {
    CryptoDonateButtonType.btc => colorBTC,
    CryptoDonateButtonType.eth => colorETH,
    CryptoDonateButtonType.bnb => colorBNB,
    CryptoDonateButtonType.avax => colorAVAX,
    CryptoDonateButtonType.ftm => colorFTM,
  };

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPressed,
      style: address.isNotEmpty ? getButtonStyle() : null,
      child: Icon(buttonIcon),
    ),
    AdaptiveStyle.apple => CupertinoButton(
      onPressed: onPressed,
      onLongPress: onLongPressed,
      color: brandColor,
      foregroundColor: onPressed != null || onLongPressed != null
          ? brandForegroundColor
          : CupertinoColors.secondaryLabel.resolveFrom(context),
      child: Icon(buttonIcon),
    ),
  };
}
