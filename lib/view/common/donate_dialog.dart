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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_donation_buttons/flutter_donation_buttons.dart';

import '../../common/enums.dart';
import '../../common/utils.dart';
import '../../component/helper.dart';
import '../../component/widgets/crypto_donate_button.dart';
import '../../l10n/localizations.dart';

enum DonateDialogResult { noAction, copied, donated }

Future<DonateDialogResult?> showDonateDialog(
  BuildContext context, {
  String donateBuyMeACoffeeToken = '',
  String donatePaypalToken = '',
  String btcAddress = '',
  String ethAddress = '',
  String bnbAddress = '',
  String avaxAddress = '',
  String ftmAddress = '',
  String alipayQRCodePath = 'assets/images/donate-alipay.jpg',
  String wechatPayQRCodePath = 'assets/images/donate-wechatpay.png',
}) async {
  return showDialog<DonateDialogResult>(
    context: context,
    builder: (context) => DonateDialog(
      donateBuyMeACoffeeToken: donateBuyMeACoffeeToken,
      donatePaypalToken: donatePaypalToken,
      btcAddress: btcAddress,
      ethAddress: ethAddress,
      bnbAddress: bnbAddress,
      avaxAddress: avaxAddress,
      ftmAddress: ftmAddress,
      alipayQRCodePath: alipayQRCodePath,
      wechatPayQRCodePath: wechatPayQRCodePath,
    ),
  );
}

class DonateDialog extends StatefulWidget {
  final String donateBuyMeACoffeeToken;
  final String donatePaypalToken;
  final String btcAddress;
  final String ethAddress;
  final String bnbAddress;
  final String avaxAddress;
  final String ftmAddress;
  final String alipayQRCodePath;
  final String wechatPayQRCodePath;

  const DonateDialog({
    super.key,
    required this.donateBuyMeACoffeeToken,
    required this.donatePaypalToken,
    required this.btcAddress,
    required this.ethAddress,
    required this.bnbAddress,
    required this.avaxAddress,
    required this.ftmAddress,
    required this.alipayQRCodePath,
    required this.wechatPayQRCodePath,
  });

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  Future<bool> _onLaunchExternelUrl(String urlString) async {
    return launchExternalUrl(Uri.parse(urlString));
  }

  void _onDonation(DonateWay dw) async {
    if (!mounted) return;
    Navigator.of(context).pop(DonateDialogResult.donated);
  }

  void _onCopyCryptoAddressToClipboard(CryptoDonateButtonType t) async {
    await Clipboard.setData(ClipboardData(text: getCryptoAddress(t)));
    if (!mounted) return;
    final l10n = L10n.of(context);
    if (l10n == null) return;
    final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(
      context,
      duration: const Duration(seconds: 4),
      content: Text(
        l10n.appAbout_donateDialog_copiedCrypto_msg(getCryptoLabel(t, l10n)),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.of(context).pop(DonateDialogResult.copied);
  }

  String getCryptoAddress(CryptoDonateButtonType t) {
    switch (t) {
      case CryptoDonateButtonType.btc:
        return widget.btcAddress;
      case CryptoDonateButtonType.eth:
        return widget.ethAddress;
      case CryptoDonateButtonType.bnb:
        return widget.bnbAddress;
      case CryptoDonateButtonType.avax:
        return widget.avaxAddress;
      case CryptoDonateButtonType.ftm:
        return widget.ftmAddress;
    }
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

    final donateWays = <DonateWay>{};
    if (l10n != null) {
      for (var name in l10n.appAbout_donateTile_ways.split(',')) {
        final way = DonateWay.getDonateWayByName(name);
        if (way == null) continue;
        donateWays.add(way);
      }
    }

    Iterable<Widget> buildBuyMeACoffeeList(BuildContext context) => [
          if (l10n != null)
            ListTile(
              title: Text(l10n.donateWay_buyMeACoffee),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          BuyMeACoffeeButton(
            buyMeACoffeeName: widget.donateBuyMeACoffeeToken,
            onLaunchURL: _onLaunchExternelUrl,
            onDonation: () => _onDonation(DonateWay.buyMeACoffee),
          ),
        ];

    Iterable<Widget> buildPaypalList(BuildContext context) => [
          if (l10n != null)
            ListTile(
              title: Text(l10n.donateWay_paypal),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          PayPalButton(
            paypalButtonId: widget.donatePaypalToken,
            onLaunchURL: _onLaunchExternelUrl,
            onDonation: () => _onDonation(DonateWay.paypal),
          ),
        ];

    Iterable<Widget> buildAlipayList(BuildContext context) => [
          if (l10n != null)
            ListTile(
              title: Text(l10n.donateWay_alipay),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          Image.asset(widget.alipayQRCodePath, width: 300),
        ];

    Iterable<Widget> buildWechatPayList(BuildContext context) => [
          if (l10n != null)
            ListTile(
              title: Text(l10n.donateWay_wechatPay),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          Image.asset(widget.wechatPayQRCodePath, width: 300),
        ];

    Iterable<Widget> buildCrytoButtonList(BuildContext context) => [
          if (l10n != null)
            ListTile(
              title: Text(l10n.donateWay_cryptoCurrency),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          Wrap(
            spacing: 8.0,
            children: List<Widget>.generate(
                CryptoDonateButtonType.values.length, (index) {
              final t = CryptoDonateButtonType.values[index];
              final addr = getCryptoAddress(t);
              return Tooltip(
                triggerMode: TooltipTriggerMode.longPress,
                message: getCryptoLabel(t, l10n),
                child: CryptoDonateButton(
                  cryptoType: t,
                  address: addr,
                  onPressed: addr != ''
                      ? () => _onCopyCryptoAddressToClipboard(t)
                      : null,
                ),
              );
            }),
          )
        ];

    Iterable<Widget> buildFirstQRGroup(BuildContext context) {
      switch (MediaQuery.orientationOf(context)) {
        case Orientation.portrait:
          return [
            if (donateWays.contains(DonateWay.alipay))
              ...buildAlipayList(context),
            if (donateWays.contains(DonateWay.wechatPay))
              ...buildWechatPayList(context),
          ];
        case Orientation.landscape:
          return [
            if (l10n != null)
              ListTile(
                title: Text(l10n.donateWay_firstQRGroup),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            if (l10n != null)
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (donateWays.contains(DonateWay.alipay))
                  Image.asset(widget.alipayQRCodePath, height: 300),
                if (donateWays.contains(DonateWay.wechatPay))
                  const SizedBox(width: 8.0),
                if (donateWays.contains(DonateWay.wechatPay))
                  Image.asset(widget.wechatPayQRCodePath, height: 300),
              ]),
          ];
      }
    }

    return AlertDialog(
      scrollable: true,
      title: l10n != null ? Text(l10n.appAbout_donateTile_titleText) : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (donateWays.contains(DonateWay.cryptoCurrencyAll))
            ...buildCrytoButtonList(context),
          if (donateWays.contains(DonateWay.buyMeACoffee))
            ...buildBuyMeACoffeeList(context),
          if (donateWays.contains(DonateWay.paypal) &&
              widget.donatePaypalToken.isNotEmpty)
            ...buildPaypalList(context),
          ...buildFirstQRGroup(context),
        ],
      ),
    );
  }
}
