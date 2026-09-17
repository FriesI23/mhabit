// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/common/_widgets/donate_dialog.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Crypto icon contrast and disabled Apple color $brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: AdaptiveStyleScope(
            override: AdaptiveStyle.apple,
            child: Scaffold(
              body: Wrap(
                children: [
                  for (final type in CryptoDonateButtonType.values)
                    CryptoDonateButton(
                      cryptoType: type,
                      address: 'address',
                      onPressed: () {},
                    ),
                  const CryptoDonateButton(
                    cryptoType: CryptoDonateButtonType.btc,
                    address: '',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final buttons = tester
          .widgetList<CryptoDonateButton>(find.byType(CryptoDonateButton))
          .toList();
      for (final button in buttons.take(5)) {
        final background = button.brandColor.computeLuminance();
        final foreground = button.brandForegroundColor.computeLuminance();
        final ratio = background > foreground
            ? (background + 0.05) / (foreground + 0.05)
            : (foreground + 0.05) / (background + 0.05);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: button.cryptoType.name,
        );
        expect(
          button.getButtonStyle().iconColor!.resolve({}),
          button.brandForegroundColor,
        );
      }
      final disabled = find.byType(CupertinoButton).last;
      final context = tester.element(disabled);
      expect(
        tester.widget<CupertinoButton>(disabled).foregroundColor,
        CupertinoColors.secondaryLabel.resolveFrom(context),
      );
      expect(tester.widget<CupertinoButton>(disabled).onPressed, isNull);
    });
  }
  for (final style in AdaptiveStyle.values) {
    for (final width in [320.0, 1000.0]) {
      testWidgets('Donate original layout $style width $width', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1000);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_host(style));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveModal), findsOneWidget);
        expect(find.byType(AdaptiveModalMaterialBridge), findsNothing);
        expect(
          find.byType(AdaptiveListSection),
          findsNWidgets(width == 320 ? 5 : 4),
        );
        expect(find.byType(CryptoDonateButton), findsNWidgets(5));
        expect(find.text(_address), findsNothing);
        expect(find.byType(Image), findsNWidgets(2));
        final content = tester.element(find.byType(DonateContent));
        expect(AdaptiveStyle.of(content), style);
        final buttons = find.descendant(
          of: find.byType(DonateContent),
          matching: find.byType(
            style == AdaptiveStyle.apple ? CupertinoButton : ElevatedButton,
          ),
        );
        expect(buttons, findsNWidgets(7));
        final disabled = tester.widget<CryptoDonateButton>(
          find.byWidgetPredicate(
            (widget) =>
                widget is CryptoDonateButton &&
                widget.cryptoType == CryptoDonateButtonType.eth,
          ),
        );
        expect(disabled.onPressed, isNull);
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -2500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('Donate missing tokens disable or hide channels $style', (
      tester,
    ) async {
      await tester.pumpWidget(_host(style, emptyTokens: true));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final l10n = L10n.of(tester.element(find.byType(DonateContent)))!;
      expect(find.text(l10n.donateWay_paypal), findsNothing);
      final coffee = find.widgetWithText(
        style == AdaptiveStyle.apple ? CupertinoButton : ElevatedButton,
        'Buy me a Coffee',
      );
      if (style == AdaptiveStyle.apple) {
        expect(tester.widget<CupertinoButton>(coffee).onPressed, isNull);
      } else {
        expect(tester.widget<ElevatedButton>(coffee).onPressed, isNull);
      }
      expect(tester.takeException(), isNull);
    });
    testWidgets('Donate long press shows name without copying $style', (
      tester,
    ) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(_host(style));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final l10n = L10n.of(tester.element(find.byType(DonateContent)))!;
      await tester.longPress(find.byType(CryptoDonateButton).first);
      await tester.pumpAndSettle();
      expect(find.text(l10n.donateWay_cryptoCurrency_BTC), findsOneWidget);
      expect(
        calls.where((call) => call.method == 'Clipboard.setData'),
        isEmpty,
      );
      expect(find.byType(DonateContent), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Donate copy returns copied $style', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      DonateDialogResult? result;
      await tester.pumpWidget(
        _host(style, onResult: (value) => result = value),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CryptoDonateButton).first);
      await tester.pumpAndSettle();
      expect(
        calls
            .where((call) => call.method == 'Clipboard.setData')
            .single
            .arguments,
        {'text': _address},
      );
      expect(result, DonateDialogResult.copied);
      expect(find.byType(DonateContent), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Donate external link returns donated $style', (tester) async {
      final calls = <MethodCall>[];
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return true;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      DonateDialogResult? result;
      await tester.pumpWidget(
        _host(style, onResult: (value) => result = value),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final paypal = find.text('Donate with Paypal');
      await Scrollable.ensureVisible(tester.element(paypal), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(paypal);
      await tester.pumpAndSettle();
      expect(
        calls.single.arguments['url'],
        'https://www.paypal.com/donate?hosted_button_id=paypal-token',
      );
      expect(result, DonateDialogResult.donated);
      expect(find.byType(DonateContent), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

const _address = 'bc1q0123456789012345678901234567890123456789';

Widget _host(
  AdaptiveStyle style, {
  ValueChanged<DonateDialogResult?>? onResult,
  bool emptyTokens = false,
}) => AdaptiveStyleScope(
  override: style,
  child: MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    locale: const Locale('de'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(2)),
      child: Directionality(textDirection: TextDirection.rtl, child: child!),
    ),
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showDonateDialog(
              context,
              donateBuyMeACoffeeToken: emptyTokens ? '' : 'coffee-token',
              donatePaypalToken: emptyTokens ? '' : 'paypal-token',
              btcAddress: _address,
            );
            onResult?.call(result);
          },
          child: const Text('Open'),
        ),
      ),
    ),
  ),
);
