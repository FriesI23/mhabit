// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/widgets/widgets.dart' show BuyMeACoffeeIcon;
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../support/adaptive_ui_theme.dart';
import '../../../support/stub/about_info.dart';

const _info = AboutInfo(
  sourceCodeUrl: 'https://example.com/project',
  issueTrackerUrl: 'https://example.com/issues',
  contactEmail: '',
  donateBuyMeACoffeeToken: 'coffee',
  donatePaypalToken: '',
  donateCryptoBTCAddr: '',
  donateCryptoETHAddr: '',
  donateCryptoBNBAddr: '',
  donateCryptoAVAXAddr: '',
  donateCryptoFTMAddr: '',
);

void main() {
  test(
    'donation card follows shared availability and the host hiding policy',
    () {
      const content = AppSupportContent(info: AboutInfo.empty());
      expect(content.hasCards('@cryptoCurrencyAll'), isFalse);
      expect(content.hasCards('@buyMeACoffee,@paypal'), isFalse);
      expect(content.hasCards('@alipay'), isTrue);
      expect(content.hasCards('@unknown'), isFalse);
      const hidden = AppSupportContent(
        info: AboutInfo.empty(),
        hideDonate: true,
      );
      expect(hidden.hasCards('@alipay,@wechatPay'), isFalse);
    },
  );

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    bool reduced = true,
    bool accessible = false,
    Brightness brightness = Brightness.light,
    AdaptiveStyle style = AdaptiveStyle.material,
    GlobalKey<NavigatorState>? navigator,
    TextDirection direction = TextDirection.ltr,
    Locale locale = const Locale('en'),
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        theme: ThemeData(
          brightness: brightness,
          colorSchemeSeed: Colors.purple,
        ),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: locale,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduced,
            accessibleNavigation: accessible,
            textScaler: TextScaler.linear(scale),
          ),
          child: Directionality(textDirection: direction, child: child!),
        ),
        home: TestAdaptiveUiTheme(
          update: (theme) => theme.copyWith(style: style),
          child: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Widget carousel({
    AppSupportContent content = const AppSupportContent(info: _info),
    bool active = true,
  }) => Center(
    child: SizedBox(
      width: 320,
      child: AppSupportCarousel(
        content: content,
        active: active,
        onSelected: (_) {},
      ),
    ),
  );
  int page(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView)).controller!.page!.round();
  Future<void> finishMotion(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  Future<void> advanceImages(WidgetTester tester, int frames) async {
    for (var frame = 0; frame < frames; frame++) {
      // Engine codec futures resolve outside the widget test's fake clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  Finder coffeeImage({Finder? host}) {
    final coffee = find.byType(BuyMeACoffeeIcon, skipOffstage: false);
    return find.descendant(
      of: host == null
          ? coffee
          : find.descendant(of: host, matching: coffee, skipOffstage: false),
      matching: find.byType(Image, skipOffstage: false),
      skipOffstage: false,
    );
  }

  RawImage coffeeFrame(WidgetTester tester, {Finder? host}) =>
      tester.widget<RawImage>(
        find.descendant(
          of: coffeeImage(host: host),
          matching: find.byType(RawImage, skipOffstage: false),
          skipOffstage: false,
        ),
      );

  List<double> starOffsets(WidgetTester tester) => [
    for (var i = 0; i < 5; i++)
      tester
          .widget<Transform>(find.byKey(ValueKey('app-support-star-$i')))
          .transform
          .storage[13],
  ];

  for (final style in AdaptiveStyle.values) {
    for (final locale in [const Locale('en'), const Locale('zh')]) {
      testWidgets(
        'hero, card order and icon actions at large text $style $locale',
        (tester) async {
          await mount(
            tester,
            SingleChildScrollView(child: carousel()),
            style: style,
            locale: locale,
            scale: 2,
          );
          final l10n = L10n.of(
            tester.element(find.byType(AppSupportCarousel)),
          )!;
          final controller = tester
              .widget<PageView>(find.byType(PageView))
              .controller!;
          final buttonType = style == AdaptiveStyle.apple
              ? CupertinoButton
              : FilledButton;
          final pages = [
            ('support', l10n.appSupport_title, [l10n.appSupport_starOnGitHub]),
            (
              'donate',
              l10n.appAbout_donateTile_titleText,
              [l10n.appAbout_donateTile_titleText],
            ),
            (
              'participate',
              l10n.appSupport_participateTitle,
              [
                l10n.appAbout_sourceCodeTile_titleText,
                l10n.appAbout_issueTrackerTile_titleText,
              ],
            ),
          ];
          for (var index = 0; index < pages.length; index++) {
            controller.jumpToPage(index);
            await tester.pumpAndSettle();
            final (kind, title, labels) = pages[index];
            final hero = find.byKey(ValueKey('app-support-hero-$kind'));
            expect(hero, findsOneWidget);
            expect(tester.getSize(hero).height, 44);
            expect(
              tester.getBottomLeft(hero).dy,
              lessThan(tester.getTopLeft(find.text(title).first).dy),
            );
            final bounds = tester.getRect(find.byType(PageView));
            for (final label in labels) {
              final button = find.widgetWithText(buttonType, label);
              expect(button, findsOneWidget);
              await tester.ensureVisible(button);
              await tester.pumpAndSettle();
              expect(
                find.descendant(of: button, matching: find.byType(Icon)),
                findsOneWidget,
              );
              if (kind == 'support') {
                expect(
                  find.descendant(
                    of: button,
                    matching: find.byIcon(Icons.star_rounded),
                  ),
                  findsOneWidget,
                );
              }
              final rect = tester.getRect(button);
              expect(rect.height, greaterThanOrEqualTo(44));
              expect(rect.left, greaterThanOrEqualTo(bounds.left));
              expect(rect.right, lessThanOrEqualTo(bounds.right));
            }
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets('coffee streams are independent and survive leaving their page', (
    tester,
  ) async {
    await mount(
      tester,
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KeyedSubtree(key: const ValueKey('first'), child: carousel()),
          KeyedSubtree(key: const ValueKey('second'), child: carousel()),
        ],
      ),
      reduced: false,
      accessible: true,
    );
    final first = find.byKey(const ValueKey('first'));
    final second = find.byKey(const ValueKey('second'));
    PageController controller(Finder host) => tester
        .widget<PageView>(
          find.descendant(of: host, matching: find.byType(PageView)),
        )
        .controller!;
    controller(first).jumpToPage(1);
    await tester.pump();
    await advanceImages(tester, 12);
    final firstProvider =
        tester.widget<Image>(coffeeImage(host: first)).image as MemoryImage;
    expect(coffeeFrame(tester, host: first).image, isNotNull);
    controller(first).jumpToPage(2);
    controller(second).jumpToPage(1);
    await tester.pump();
    await advanceImages(tester, 4);
    final paused = coffeeFrame(tester, host: first).image;
    final secondProvider =
        tester.widget<Image>(coffeeImage(host: second)).image as MemoryImage;
    expect(identical(firstProvider.bytes, secondProvider.bytes), isFalse);
    await advanceImages(tester, 8);
    expect(coffeeFrame(tester, host: first).image, same(paused));
    controller(first).jumpToPage(1);
    await tester.pump();
    await advanceImages(tester, 4);
    expect(
      tester.widget<Image>(coffeeImage(host: first)).image,
      same(firstProvider),
    );
    expect(coffeeFrame(tester, host: first).image, isNot(same(paused)));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
    expect(
      tester.binding.imageCache.statusForKey(firstProvider).untracked,
      isTrue,
    );
    expect(
      tester.binding.imageCache.statusForKey(secondProvider).untracked,
      isTrue,
    );
  });

  testWidgets('coffee finishes once, survives rebuild and clears its cache', (
    tester,
  ) async {
    final revision = ValueNotifier(0);
    addTearDown(revision.dispose);
    await mount(
      tester,
      ValueListenableBuilder<int>(
        valueListenable: revision,
        builder: (_, value, _) => carousel(
          content: AppSupportContent(info: stubAboutInfo(sourceCodeUrl: '')),
        ),
      ),
      reduced: false,
    );
    await advanceImages(tester, 120);
    final provider = tester.widget<Image>(coffeeImage()).image;
    final finished = coffeeFrame(tester).image;
    expect(finished, isNotNull);
    await advanceImages(tester, 10);
    expect(coffeeFrame(tester).image, same(finished));
    revision.value++;
    await tester.pump();
    await advanceImages(tester, 4);
    expect(tester.widget<Image>(coffeeImage()).image, same(provider));
    expect(coffeeFrame(tester).image, same(finished));
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.imageCache.statusForKey(provider).untracked, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion holds the first coffee frame', (tester) async {
    await mount(
      tester,
      carousel(
        content: AppSupportContent(info: stubAboutInfo(sourceCodeUrl: '')),
      ),
    );
    await advanceImages(tester, 4);
    final frame = coffeeFrame(tester).image;
    expect(frame, isNotNull);
    await advanceImages(tester, 10);
    expect(coffeeFrame(tester).image, same(frame));
    await tester.pumpWidget(const SizedBox());
  });

  for (final mode in [
    'background',
    'modal',
    'branch',
    'offscreen',
    'inactive',
  ]) {
    testWidgets('$mode pauses coffee and resumes its existing stream', (
      tester,
    ) async {
      final active = ValueNotifier(true);
      final scroll = ScrollController();
      final navigator = GlobalKey<NavigatorState>();
      addTearDown(active.dispose);
      addTearDown(scroll.dispose);
      await mount(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: active,
          builder: (_, enabled, _) => TickerMode(
            enabled: mode == 'branch' ? enabled : true,
            child: SingleChildScrollView(
              controller: scroll,
              child: Column(
                children: [
                  carousel(
                    content: AppSupportContent(
                      info: stubAboutInfo(sourceCodeUrl: ''),
                    ),
                    active: mode == 'inactive' ? enabled : true,
                  ),
                  const SizedBox(height: 1600),
                ],
              ),
            ),
          ),
        ),
        reduced: false,
        navigator: navigator,
      );
      await advanceImages(tester, 8);
      final provider = tester.widget<Image>(coffeeImage()).image;
      Future<void>? modal;
      switch (mode) {
        case 'background':
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
        case 'modal':
          modal = showDialog<void>(
            context: navigator.currentContext!,
            builder: (_) => const AlertDialog(content: Text('overlay')),
          );
        case 'branch' || 'inactive':
          active.value = false;
        case 'offscreen':
          scroll.jumpTo(1000);
      }
      await tester.pump();
      await advanceImages(tester, 4);
      final paused = coffeeFrame(tester).image;
      expect(paused, isNotNull);
      await advanceImages(tester, 8);
      expect(coffeeFrame(tester).image, same(paused));
      switch (mode) {
        case 'background':
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        case 'modal':
          navigator.currentState!.pop();
        case 'branch' || 'inactive':
          active.value = true;
        case 'offscreen':
          scroll.jumpTo(0);
      }
      await tester.pump();
      await advanceImages(tester, 8);
      if (modal != null) await modal;
      expect(tester.widget<Image>(coffeeImage()).image, same(provider));
      expect(coffeeFrame(tester).image, isNot(same(paused)));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'coffee asset failures use the static icon without layout errors',
    (tester) async {
      await mount(
        tester,
        DefaultAssetBundle(
          bundle: _MissingCoffeeAssetBundle(),
          child: carousel(
            content: AppSupportContent(info: stubAboutInfo(sourceCodeUrl: '')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.coffee_rounded), findsOneWidget);
      expect(coffeeImage(), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unrelated rebuild preserves the remaining idle interval', (
    tester,
  ) async {
    final revision = ValueNotifier(0);
    addTearDown(revision.dispose);
    await mount(
      tester,
      ValueListenableBuilder<int>(
        valueListenable: revision,
        builder: (_, value, _) => carousel(),
      ),
      reduced: false,
    );
    await tester.pump(const Duration(seconds: 3));
    revision.value++;
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await finishMotion(tester);
    expect(page(tester), 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'motion preference completes stars without replaying or build notifications',
    (tester) async {
      final reduced = ValueNotifier(false);
      addTearDown(reduced.dispose);
      await mount(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: reduced,
          child: carousel(),
          builder: (context, value, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: value),
            child: child!,
          ),
        ),
        reduced: false,
        accessible: true,
      );
      await tester.pump(const Duration(milliseconds: 180));
      expect(starOffsets(tester).first, lessThan(0));
      reduced.value = true;
      await tester.pump();
      expect(starOffsets(tester), everyElement(0));
      reduced.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));
      expect(starOffsets(tester), everyElement(0));
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  for (final reduced in [true, false]) {
    testWidgets(
      'card changes clamp the last page and reattach after empty content ($reduced)',
      (tester) async {
        final content = ValueNotifier(const AppSupportContent(info: _info));
        addTearDown(content.dispose);
        await mount(
          tester,
          ValueListenableBuilder<AppSupportContent>(
            valueListenable: content,
            builder: (_, value, _) => carousel(content: value),
          ),
          reduced: reduced,
          accessible: true,
        );
        tester
            .widget<PageView>(find.byType(PageView))
            .controller!
            .jumpToPage(2);
        await tester.pumpAndSettle();
        expect(page(tester), 2);
        content.value = AppSupportContent(
          info: stubAboutInfo(
            sourceCodeUrl: '',
            issueTrackerUrl: 'https://example.com/issues',
          ),
          hideDonate: true,
        );
        await tester.pumpAndSettle();
        expect(page(tester), 0);
        expect(find.text('Issue tracker'), findsOneWidget);
        content.value = const AppSupportContent(
          info: AboutInfo.empty(),
          hideDonate: true,
        );
        await tester.pumpAndSettle();
        expect(find.byType(PageView), findsNothing);
        content.value = const AppSupportContent(info: _info);
        await tester.pumpAndSettle();
        expect(page(tester), 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'removing cards during a drag allows autoplay after reattachment',
    (tester) async {
      final content = ValueNotifier(const AppSupportContent(info: _info));
      addTearDown(content.dispose);
      await mount(
        tester,
        ValueListenableBuilder<AppSupportContent>(
          valueListenable: content,
          builder: (_, value, _) => carousel(content: value),
        ),
        reduced: false,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      content.value = const AppSupportContent(
        info: AboutInfo.empty(),
        hideDonate: true,
      );
      await tester.pump();
      await gesture.up();
      content.value = const AppSupportContent(info: _info);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await finishMotion(tester);
      expect(page(tester), 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final last in [false, true]) {
    testWidgets(
      'reduced-motion elastic overscroll returns to bounds (last=$last)',
      (tester) async {
        await mount(
          tester,
          ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
            ),
            child: carousel(),
          ),
        );
        final pages = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        if (last) pages.jumpToPage(2);
        await tester.pumpAndSettle();
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PageView)),
        );
        await gesture.moveBy(Offset(last ? -200 : 200, 0));
        await tester.pump(const Duration(milliseconds: 16));
        expect(pages.position.outOfRange, isTrue);
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 16));
        expect(pages.position.outOfRange, isFalse);
        expect(pages.page, last ? 2 : 0);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  for (final operation in ['release', 'resize', 'shrink', 'dispose']) {
    testWidgets('reduced-motion drag aligns directly after $operation', (
      tester,
    ) async {
      final content = ValueNotifier(const AppSupportContent(info: _info));
      addTearDown(content.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      await mount(
        tester,
        ValueListenableBuilder<AppSupportContent>(
          valueListenable: content,
          builder: (_, value, _) => carousel(content: value),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await gesture.moveBy(const Offset(-224, 0));
      await tester.pump(const Duration(milliseconds: 16));
      switch (operation) {
        case 'resize':
          tester.view.physicalSize =
              const Size(260, 800) * tester.view.devicePixelRatio;
          await tester.pump();
        case 'shrink':
          content.value = AppSupportContent(
            info: stubAboutInfo(
              sourceCodeUrl: '',
              issueTrackerUrl: 'https://example.com/issues',
            ),
            hideDonate: true,
          );
          await tester.pump();
        case 'dispose':
          await tester.pumpWidget(const SizedBox());
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 16));
      if (operation != 'dispose') {
        final value = tester
            .widget<PageView>(find.byType(PageView))
            .controller!
            .page!;
        expect(value, closeTo(value.roundToDouble(), 0.000001));
        expect(value, operation == 'shrink' ? 0 : 1);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'stars overlap as two travelling waves, then settle without more ticks',
    (tester) async {
      await mount(tester, carousel(), reduced: false, accessible: true);
      for (var wave = 0; wave < 2; wave++) {
        await tester.pump(const Duration(milliseconds: 120));
        expect(starOffsets(tester).first, lessThan(0));
        expect(starOffsets(tester).skip(1), everyElement(0));
        await tester.pump(const Duration(milliseconds: 240));
        final leading = starOffsets(tester);
        expect(leading[0], closeTo(-8, 0.01));
        expect(leading[1], greaterThan(leading[0]));
        expect(leading[1], lessThan(leading[2]));
        expect(leading[2], lessThan(0));
        expect(leading.skip(3), everyElement(0));
        await tester.pump(const Duration(milliseconds: 480));
        final trailing = starOffsets(tester);
        expect(trailing.first, 0);
        expect(trailing[3], lessThan(0));
        expect(trailing.last, closeTo(-8, 0.01));
        await tester.pump(const Duration(milliseconds: 360));
        expect(starOffsets(tester), everyElement(closeTo(0, 0.01)));
      }
      await tester.pump(const Duration(milliseconds: 1));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(seconds: 10));
      expect(starOffsets(tester), everyElement(0));
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  testWidgets('page changes do not replay stars, new instance does', (
    tester,
  ) async {
    await mount(tester, carousel(), reduced: false, accessible: true);
    await tester.pump(const Duration(milliseconds: 180));
    final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
    pages.jumpToPage(1);
    await tester.pump(const Duration(milliseconds: 360));
    pages.jumpToPage(0);
    await tester.pump();
    // Leaving the current card pauses the unfinished wave.
    expect(starOffsets(tester)[0], closeTo(-4, 0.01));
    expect(starOffsets(tester).skip(2), everyElement(0));
    await tester.pump(const Duration(seconds: 4));
    for (final index in [1, 0]) {
      await tester.tap(find.byKey(ValueKey('app-support-page-$index')));
      await tester.pump();
      await finishMotion(tester);
    }
    await tester.pump(const Duration(milliseconds: 180));
    expect(starOffsets(tester), everyElement(0));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await mount(tester, carousel(), reduced: false, accessible: true);
    await tester.pump(const Duration(milliseconds: 180));
    expect(starOffsets(tester).first, closeTo(-4, 0.01));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion never bounces', (tester) async {
    await mount(tester, carousel());
    await tester.pump(const Duration(milliseconds: 180));
    expect(starOffsets(tester), everyElement(0));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets(
    'invalid configuration omits cards and single card omits controls',
    (tester) async {
      await mount(
        tester,
        carousel(
          content: const AppSupportContent(
            info: AboutInfo.empty(),
            hideDonate: true,
          ),
        ),
      );
      expect(find.byType(PageView), findsNothing);
      await mount(
        tester,
        carousel(
          content: AppSupportContent(
            info: stubAboutInfo(
              sourceCodeUrl: '',
              issueTrackerUrl: 'https://example.com/issues',
            ),
            hideDonate: true,
          ),
        ),
      );
      expect(find.text('Issue tracker'), findsOneWidget);
      expect(find.byType(TabPageSelectorIndicator), findsNothing);
      expect(find.byType(AdaptiveIconButton), findsNothing);
      for (final target in [
        'file:///tmp/test',
        'https://user:pass@example.com',
        'https://',
      ]) {
        await mount(
          tester,
          carousel(
            content: AppSupportContent(
              info: stubAboutInfo(sourceCodeUrl: target),
              hideDonate: true,
            ),
          ),
        );
        expect(find.byType(PageView), findsNothing);
      }
    },
  );

  testWidgets(
    'hidden donation and valid auxiliary configuration set card count',
    (tester) async {
      await mount(
        tester,
        carousel(
          content: const AppSupportContent(info: _info, hideDonate: true),
        ),
      );
      expect(find.byType(TabPageSelectorIndicator).evaluate().length, 2);
      await mount(tester, carousel());
      expect(find.byType(TabPageSelectorIndicator).evaluate().length, 3);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'stars use fixed amber for $brightness independently of accent',
      (tester) async {
        await mount(tester, carousel(), brightness: brightness);
        final stars = tester
            .widgetList<Icon>(
              find.descendant(
                of: find.byKey(const ValueKey('app-support-hero-support')),
                matching: find.byIcon(Icons.star_rounded),
              ),
            )
            .toList();
        expect(stars, hasLength(5));
        expect(
          stars.every(
            (star) =>
                star.color ==
                (brightness == Brightness.dark
                    ? Colors.amber.shade300
                    : Colors.amber.shade600),
          ),
          isTrue,
        );
        expect(find.byIcon(Icons.pause), findsNothing);
        expect(find.byIcon(Icons.play_arrow), findsNothing);
      },
    );
  }

  for (final style in AdaptiveStyle.values) {
    for (final target in [0, 2]) {
      testWidgets(
        'clicking page $target resets idle timer and preserves focus $style',
        (tester) async {
          final semantics = tester.ensureSemantics();
          await mount(tester, carousel(), style: style, reduced: false);
          await tester.pump(const Duration(seconds: 3));
          await tester.tap(find.byKey(ValueKey('app-support-page-$target')));
          await tester.pump();
          await finishMotion(tester);
          expect(page(tester), target);
          final indicator = find.bySemanticsLabel('Page ${target + 1} of 3');
          expect(indicator, findsOneWidget);
          expect(
            tester
                .getSemantics(indicator)
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            Tristate.isTrue,
          );
          await tester.pump(const Duration(seconds: 3));
          expect(page(tester), target);
          await tester.pump(const Duration(seconds: 1));
          await finishMotion(tester);
          expect(page(tester), (target + 1) % 3);
          semantics.dispose();
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets('auto advances after four idle seconds and wraps', (
    tester,
  ) async {
    await mount(tester, carousel(), reduced: false);
    await tester.pump(const Duration(milliseconds: 3999));
    expect(page(tester), 0);
    await tester.pump(const Duration(milliseconds: 1));
    await finishMotion(tester);
    expect(page(tester), 1);
    await tester.pump(const Duration(seconds: 4));
    await finishMotion(tester);
    expect(page(tester), 2);
    await tester.pump(const Duration(seconds: 4));
    await finishMotion(tester);
    expect(page(tester), 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('touch restarts the entire idle interval', (tester) async {
    await mount(tester, carousel(), reduced: false);
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(
      find.text(
        'Your support helps improve Table Habit and reach more people.',
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(page(tester), 0);
    await tester.pump(const Duration(seconds: 1));
    await finishMotion(tester);
    expect(page(tester), 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'manual drag resets timer after settling and keeps height stable',
    (tester) async {
      await mount(tester, carousel(), reduced: false);
      final height = tester.getSize(find.byType(PageView)).height;
      await tester.pump(const Duration(seconds: 3));
      await tester.drag(find.byType(PageView), const Offset(-320, 0));
      await finishMotion(tester);
      expect(page(tester), 1);
      expect(tester.getSize(find.byType(PageView)).height, height);
      await tester.pump(const Duration(seconds: 3));
      expect(page(tester), 1);
      await tester.pump(const Duration(seconds: 1));
      await finishMotion(tester);
      expect(page(tester), 2);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final mode in ['background', 'modal', 'branch', 'offscreen']) {
    testWidgets('$mode stops playback and resumes with a new interval', (
      tester,
    ) async {
      final active = ValueNotifier(true);
      final scroll = ScrollController();
      final navigator = GlobalKey<NavigatorState>();
      addTearDown(active.dispose);
      addTearDown(scroll.dispose);
      final child = ValueListenableBuilder<bool>(
        valueListenable: active,
        builder: (_, enabled, _) => TickerMode(
          enabled: enabled,
          child: SingleChildScrollView(
            controller: scroll,
            child: Column(children: [carousel(), const SizedBox(height: 1600)]),
          ),
        ),
      );
      await mount(tester, child, reduced: false, navigator: navigator);
      await tester.pump(const Duration(seconds: 3));
      Future<void>? modal;
      switch (mode) {
        case 'background':
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
        case 'modal':
          modal = showDialog<void>(
            context: navigator.currentContext!,
            builder: (_) => const AlertDialog(content: Text('overlay')),
          );
        case 'branch':
          active.value = false;
        case 'offscreen':
          scroll.jumpTo(1000);
      }
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      expect(page(tester), 0);
      switch (mode) {
        case 'background':
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        case 'modal':
          navigator.currentState!.pop();
        case 'branch':
          active.value = true;
        case 'offscreen':
          scroll.jumpTo(0);
      }
      await tester.pump();
      await finishMotion(tester);
      if (modal != null) await modal;
      await tester.pump(const Duration(seconds: 2));
      expect(page(tester), 0);
      await tester.pump(const Duration(seconds: 2));
      await finishMotion(tester);
      expect(page(tester), 1);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('root modal pauses a retained nested navigator carousel', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await mount(
      tester,
      Navigator(
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => carousel()),
      ),
      navigator: navigator,
      reduced: false,
    );
    await tester.pump(const Duration(seconds: 3));
    final modal = showDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => const AlertDialog(content: Text('root overlay')),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(page(tester), 0);
    navigator.currentState!.pop();
    await finishMotion(tester);
    await modal;
    await tester.pump(const Duration(seconds: 4));
    await finishMotion(tester);
    expect(page(tester), 1);
    await tester.pumpWidget(const SizedBox());
  });

  for (final reduced in [true, false]) {
    testWidgets('accessibility navigation holds the current page ($reduced)', (
      tester,
    ) async {
      await mount(tester, carousel(), reduced: reduced, accessible: true);
      await tester.pump(const Duration(seconds: 10));
      expect(page(tester), 0);
      expect(find.byType(AdaptiveIconButton), findsNothing);
      expect(find.byType(TabPageSelectorIndicator), findsNWidgets(3));
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      'keyboard, semantics and reduced-motion manual navigation $style',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await mount(tester, carousel(), style: style);
        expect(find.bySemanticsLabel('Star on GitHub'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(page(tester), 1);
        expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);
        final donation = find.widgetWithText(
          style == AdaptiveStyle.apple ? CupertinoButton : FilledButton,
          'Donate',
        );
        expect(donation, findsOneWidget);
        final semanticButton = find.descendant(
          of: donation,
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          ),
        );
        expect(semanticButton, findsOneWidget);
        final data = tester.getSemantics(semanticButton).getSemanticsData();
        expect(data.label, 'Donate');
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        expect(find.bySemanticsLabel('Source code'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(page(tester), 2);
        expect(find.bySemanticsLabel('Source code'), findsOneWidget);
        expect(find.bySemanticsLabel('Issue tracker'), findsOneWidget);
        expect(find.bySemanticsLabel('Star on GitHub'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(page(tester), 0);
        // From the carousel root: support action, then the three page buttons.
        for (var tab = 0; tab < 4; tab++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(page(tester), 2);
        semantics.dispose();
      },
    );
  }
}

class _MissingCoffeeAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => key.endsWith('app-support-coffee.gif')
      ? Future.error(StateError('coffee asset unavailable'))
      : rootBundle.load(key);
}
