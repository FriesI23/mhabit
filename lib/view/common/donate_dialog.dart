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
import 'package:flutter_donation_buttons/flutter_donation_buttons.dart';

import '../../common/enums.dart';
import '../../l10n/localizations.dart';

enum DonateDialogResult {
  ok;
}

Future<DonateDialogResult?> showDonateDialog(
  BuildContext context, {
  String donateBuyMeACoffeeToken = '',
  String donatePaypalToken = '',
  String alipayQRCodePath = 'assets/images/donate-alipay.jpg',
  String wechatPayQRCodePath = 'assets/images/donate-wechatpay.png',
}) async {
  return showDialog<DonateDialogResult>(
    context: context,
    builder: (context) => DonateDialog(
      donateBuyMeACoffeeToken: donateBuyMeACoffeeToken,
      donatePaypalToken: donatePaypalToken,
      alipayQRCodePath: alipayQRCodePath,
      wechatPayQRCodePath: wechatPayQRCodePath,
    ),
  );
}

class DonateDialog extends StatefulWidget {
  final String donateBuyMeACoffeeToken;
  final String donatePaypalToken;
  final String alipayQRCodePath;
  final String wechatPayQRCodePath;

  const DonateDialog({
    super.key,
    required this.donateBuyMeACoffeeToken,
    required this.donatePaypalToken,
    required this.alipayQRCodePath,
    required this.wechatPayQRCodePath,
  });

  @override
  State<DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
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

    Iterable<Widget> buildBuyMeACoffeeList(BuildContext context) sync* {
      if (l10n != null) {
        yield ListTile(
          title: Text(l10n.donateWay_buyMeACoffee),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }
      yield BuyMeACoffeeButton(
        buyMeACoffeeName: widget.donateBuyMeACoffeeToken,
      );
    }

    Iterable<Widget> buildPaypalList(BuildContext context) sync* {
      if (l10n != null) {
        yield ListTile(
          title: Text(l10n.donateWay_paypal),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }
      yield PayPalButton(paypalButtonId: widget.donatePaypalToken);
    }

    Iterable<Widget> buildAlipayList(BuildContext context) sync* {
      if (l10n != null) {
        yield ListTile(
          title: Text(l10n.donateWay_alipay),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }
      yield Image.asset(widget.alipayQRCodePath, width: 300);
    }

    Iterable<Widget> buildWechatPayList(BuildContext context) sync* {
      if (l10n != null) {
        yield ListTile(
          title: Text(l10n.donateWay_wechatPay),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }
      yield Image.asset(widget.wechatPayQRCodePath, width: 300);
    }

    return AlertDialog(
      scrollable: true,
      title: l10n != null ? Text(l10n.appAbout_donateTile_titleText) : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (donateWays.contains(DonateWay.buyMeACoffee))
            ...buildBuyMeACoffeeList(context),
          if (donateWays.contains(DonateWay.paypal) &&
              widget.donatePaypalToken.isNotEmpty)
            ...buildPaypalList(context),
          if (donateWays.contains(DonateWay.alipay))
            ...buildAlipayList(context),
          if (donateWays.contains(DonateWay.wechatPay))
            ...buildWechatPayList(context),
        ],
      ),
    );
  }
}
