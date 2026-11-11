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
import 'package:flutter/services.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../common/enums.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/support/about_info.dart';
import '../../../widgets/helpers.dart';
import '../../../widgets/widgets.dart';

enum DonateDialogResult { noAction, copied, donated }

/// Donation destinations and availability shared by all donation entry points.
class DonateConfig {
  const DonateConfig({
    required this.info,
    this.alipayQRCodePath = 'assets/images/donate-alipay.jpg',
    this.wechatPayQRCodePath = 'assets/images/donate-wechatpay.png',
  });

  final AboutInfo info;
  final String alipayQRCodePath;
  final String wechatPayQRCodePath;

  Set<DonateWay> configuredWays(String value) => value
      .split(',')
      .map(DonateWay.getDonateWayByName)
      .whereType<DonateWay>()
      .toSet();

  bool hasAvailableMethod(String configured) =>
      configuredWays(configured).any(isAvailable);

  bool isAvailable(DonateWay way) => switch (way) {
    DonateWay.buyMeACoffee => info.donateBuyMeACoffeeToken.isNotEmpty,
    DonateWay.paypal => info.donatePaypalToken.isNotEmpty,
    DonateWay.alipay => alipayQRCodePath.isNotEmpty,
    DonateWay.wechatPay => wechatPayQRCodePath.isNotEmpty,
    DonateWay.cryptoCurrencyAll => CryptoDonateButtonType.values.any(
      (type) => cryptoAddress(type).isNotEmpty,
    ),
  };

  String cryptoAddress(CryptoDonateButtonType type) => switch (type) {
    CryptoDonateButtonType.btc => info.donateCryptoBTCAddr,
    CryptoDonateButtonType.eth => info.donateCryptoETHAddr,
    CryptoDonateButtonType.bnb => info.donateCryptoBNBAddr,
    CryptoDonateButtonType.avax => info.donateCryptoAVAXAddr,
    CryptoDonateButtonType.ftm => info.donateCryptoFTMAddr,
  };
}

Future<DonateDialogResult?> showDonateDialog(
  BuildContext context, {
  required DonateConfig config,
}) async {
  final l10n = L10n.of(context);
  return showAdaptiveSheet<DonateDialogResult>(
    context: context,
    builder: (_) => AdaptiveModal(
      title: l10n != null ? Text(l10n.appAbout_donateTile_titleText) : null,
      automaticallyImplyCloseButton: false,
      size: const AdaptiveModalSize.constrained(minWidth: 800, maxWidth: 800),
      body: DonateContent(config: config),
    ),
  );
}

class DonateContent extends StatefulWidget {
  const DonateContent({super.key, required this.config});

  final DonateConfig config;

  @override
  State<DonateContent> createState() => _DonateContentState();
}

class _DonateContentState extends State<DonateContent> {
  Future<bool> _onLaunchExternalUrl(String urlString) async {
    return launchExternalUrl(Uri.parse(urlString));
  }

  void _onDonation(DonateWay dw) {
    if (!mounted) return;
    Navigator.of(context).pop(DonateDialogResult.donated);
  }

  Future<void> _openDonation(DonateWay donateWay, String url) async {
    try {
      await _onLaunchExternalUrl(url);
    } catch (error) {
      debugPrint('Failed to open donation URL: $error');
    }
    _onDonation(donateWay);
  }

  void _onCopyCryptoAddressToClipboard(CryptoDonateButtonType t) async {
    await Clipboard.setData(
      ClipboardData(text: widget.config.cryptoAddress(t)),
    );
    if (!mounted) return;
    final l10n = L10n.of(context);
    if (l10n == null) return;
    final snackBar = buildSnackBarWithDismiss(
      context,
      duration: const Duration(seconds: 4),
      content: Text(
        l10n.appAbout_donateDialog_copiedCrypto_msg(getCryptoLabel(t, l10n)),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.of(context).pop(DonateDialogResult.copied);
  }

  String getCryptoLabel(CryptoDonateButtonType t, [L10n? l10n]) {
    switch (t) {
      case CryptoDonateButtonType.btc:
        return l10n?.donateWay_cryptoCurrency_BTC ?? '';
      case CryptoDonateButtonType.eth:
        return l10n?.donateWay_cryptoCurrency_ETH ?? '';
      case CryptoDonateButtonType.bnb:
        return l10n?.donateWay_cryptoCurrency_BNB ?? '';
      case CryptoDonateButtonType.avax:
        return l10n?.donateWay_cryptoCurrency_AVAX ?? '';
      case CryptoDonateButtonType.ftm:
        return l10n?.donateWay_cryptoCurrency_FTM ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final config = widget.config;
    final donateWays = config.configuredWays(
      l10n?.appAbout_donateTile_ways ?? '',
    );

    Widget buildBuyMeACoffeeList() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: _DonateBrandButton(
            onPressed: !config.isAvailable(DonateWay.buyMeACoffee)
                ? null
                : () => _openDonation(
                    DonateWay.buyMeACoffee,
                    'https://www.buymeacoffee.com/'
                    '${config.info.donateBuyMeACoffeeToken}',
                  ),
            minimumSize: const Size(200, 42),
            backgroundColor: const Color(0xffffdd00),
            foregroundColor: Colors.black,
            icon: const Icon(SimpleIcons.buymeacoffee),
            label: const Text(
              'Buy me a Coffee',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );

    Widget buildPaypalList() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DonateBrandButton(
          onPressed: !config.isAvailable(DonateWay.paypal)
              ? null
              : () => _openDonation(
                  DonateWay.paypal,
                  'https://www.paypal.com/donate?hosted_button_id='
                  '${config.info.donatePaypalToken}',
                ),
          backgroundColor: Colors.blue[600]!,
          icon: const Icon(SimpleIcons.paypal),
          label: const Text('Donate with Paypal'),
        ),
      ],
    );

    Widget buildCryptoButtonList() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List<Widget>.generate(
            CryptoDonateButtonType.values.length,
            (index) {
              final t = CryptoDonateButtonType.values[index];
              final addr = widget.config.cryptoAddress(t);
              return Tooltip(
                triggerMode: TooltipTriggerMode.longPress,
                message: getCryptoLabel(t, l10n),
                child: CryptoDonateButton(
                  cryptoType: t,
                  address: addr,
                  onPressed: addr.isNotEmpty
                      ? () => _onCopyCryptoAddressToClipboard(t)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );

    Widget buildQRSection() {
      final hasAlipay =
          donateWays.contains(DonateWay.alipay) &&
          config.isAvailable(DonateWay.alipay);
      final hasWechat =
          donateWays.contains(DonateWay.wechatPay) &&
          config.isAvailable(DonateWay.wechatPay);
      if (!hasAlipay && !hasWechat) return const SizedBox.shrink();

      return WindowSizeClassLayoutBuilder(
        builder: (context, windowSize, _) {
          final wide = windowSize.width >= WindowSizeClass.medium;
          final screenWidth = MediaQuery.sizeOf(context).width;
          final qrHeight = wide
              ? 300.0
              : (screenWidth * 0.55).clamp(180.0, 280.0);

          Widget qrImage(String path) =>
              Image.asset(path, height: qrHeight, fit: BoxFit.contain);
          Widget alipayQR() => qrImage(config.alipayQRCodePath);
          Widget wechatQR() => qrImage(config.wechatPayQRCodePath);

          if (wide) {
            return _DonateSection(
              title: l10n?.donateWay_firstQRGroup,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                runSpacing: 6.0,
                children: [
                  if (hasAlipay) alipayQR(),
                  if (hasWechat) wechatQR(),
                ],
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasAlipay)
                _DonateSection(
                  title: l10n?.donateWay_alipay,
                  child: Center(child: alipayQR()),
                ),
              if (hasWechat)
                _DonateSection(
                  title: l10n?.donateWay_wechatPay,
                  child: Center(child: wechatQR()),
                ),
            ],
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (donateWays.contains(DonateWay.cryptoCurrencyAll))
          _DonateSection(
            title: l10n?.donateWay_cryptoCurrency,
            child: buildCryptoButtonList(),
          ),
        if (donateWays.contains(DonateWay.buyMeACoffee))
          _DonateSection(
            title: l10n?.donateWay_buyMeACoffee,
            child: buildBuyMeACoffeeList(),
          ),
        if (donateWays.contains(DonateWay.paypal) &&
            config.isAvailable(DonateWay.paypal))
          _DonateSection(
            title: l10n?.donateWay_paypal,
            child: buildPaypalList(),
          ),
        if (donateWays.contains(DonateWay.alipay) ||
            donateWays.contains(DonateWay.wechatPay))
          buildQRSection(),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Groups the existing branded content without turning controls into rows.
class _DonateSection extends StatelessWidget {
  const _DonateSection({required this.title, required this.child});
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) => AdaptiveListSection(
    header: title == null ? null : Text(title!),
    children: [Padding(padding: const EdgeInsets.all(16), child: child)],
  );
}

class _DonateBrandButton extends StatelessWidget {
  const _DonateBrandButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.minimumSize,
  });
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Size? minimumSize;
  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: minimumSize,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      icon: icon,
      label: label,
    ),
    AdaptiveStyle.apple => CupertinoButton(
      onPressed: onPressed,
      color: backgroundColor,
      foregroundColor: foregroundColor ?? CupertinoColors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Flexible(child: label),
        ],
      ),
    ),
  };
}
