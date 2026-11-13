// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';
import 'dart:ui' show instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> mount(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
    await tester.pump();
  }

  Finder image() => find.descendant(
    of: find.byType(BuyMeACoffeeIcon),
    matching: find.byType(Image),
  );

  RawImage frame(WidgetTester tester) => tester.widget<RawImage>(
    find.descendant(of: image(), matching: find.byType(RawImage)),
  );

  Future<void> advanceImages(WidgetTester tester, int frames) async {
    for (var frame = 0; frame < frames; frame++) {
      // Engine codec futures resolve outside the widget test's fake clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  test(
    'coffee asset plays one hundred frames once over five seconds',
    () async {
      final data = await rootBundle.load(
        'assets/images/app-support-coffee.gif',
      );
      final codec = await instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      addTearDown(codec.dispose);
      expect(codec.frameCount, 100);
      expect(codec.repetitionCount, 0);
      var duration = Duration.zero;
      for (var frame = 0; frame < codec.frameCount; frame++) {
        final decoded = await codec.getNextFrame();
        duration += decoded.duration;
        decoded.image.dispose();
      }
      expect(duration, const Duration(seconds: 5));
    },
  );

  testWidgets('default and updated sizes keep a square and preserve playback', (
    tester,
  ) async {
    final size = ValueNotifier<double?>(null);
    addTearDown(size.dispose);
    await mount(
      tester,
      ValueListenableBuilder<double?>(
        valueListenable: size,
        builder: (context, value, _) => value == null
            ? const BuyMeACoffeeIcon()
            : BuyMeACoffeeIcon(size: value),
      ),
    );
    await advanceImages(tester, 4);
    expect(
      tester.getSize(find.byType(BuyMeACoffeeIcon)),
      const Size.square(40),
    );
    expect(tester.getSize(image()), const Size.square(40));
    final provider = tester.widget<Image>(image()).image;
    size.value = 64;
    await tester.pump();
    expect(
      tester.getSize(find.byType(BuyMeACoffeeIcon)),
      const Size.square(64),
    );
    expect(tester.getSize(image()), const Size.square(64));
    expect(tester.widget<Image>(image()).image, same(provider));
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.imageCache.statusForKey(provider).untracked, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('animated changes pause and resume the existing image stream', (
    tester,
  ) async {
    final animated = ValueNotifier(false);
    addTearDown(animated.dispose);
    await mount(
      tester,
      ValueListenableBuilder<bool>(
        valueListenable: animated,
        builder: (context, value, _) => BuyMeACoffeeIcon(animated: value),
      ),
    );
    await advanceImages(tester, 4);
    final provider = tester.widget<Image>(image()).image;
    final paused = frame(tester).image;
    expect(paused, isNotNull);
    await advanceImages(tester, 8);
    expect(frame(tester).image, same(paused));
    animated.value = true;
    await tester.pump();
    await advanceImages(tester, 4);
    expect(tester.widget<Image>(image()).image, same(provider));
    expect(frame(tester).image, isNot(same(paused)));
    animated.value = false;
    await tester.pump();
    await advanceImages(tester, 2);
    final pausedAgain = frame(tester).image;
    await advanceImages(tester, 6);
    expect(frame(tester).image, same(pausedAgain));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  for (final restriction in ['ticker', 'reduced motion']) {
    testWidgets('animated respects inherited $restriction', (tester) async {
      final allowed = ValueNotifier(false);
      addTearDown(allowed.dispose);
      await mount(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: allowed,
          builder: (context, value, _) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: restriction == 'reduced motion' && !value,
            ),
            child: TickerMode(
              enabled: restriction != 'ticker' || value,
              child: const BuyMeACoffeeIcon(),
            ),
          ),
        ),
      );
      await advanceImages(tester, 4);
      final provider = tester.widget<Image>(image()).image;
      final paused = frame(tester).image;
      expect(paused, isNotNull);
      await advanceImages(tester, 8);
      expect(frame(tester).image, same(paused));
      allowed.value = true;
      await tester.pump();
      await advanceImages(tester, 4);
      expect(tester.widget<Image>(image()).image, same(provider));
      expect(frame(tester).image, isNot(same(paused)));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  for (final failure in ['loading', 'decoding']) {
    testWidgets('custom fallback covers pending and failed $failure', (
      tester,
    ) async {
      final pending = Completer<ByteData>();
      await mount(
        tester,
        DefaultAssetBundle(
          bundle: _PendingCoffeeAssetBundle(pending.future),
          child: const BuyMeACoffeeIcon(
            size: 56,
            fallback: Text('Coffee unavailable'),
          ),
        ),
      );
      expect(find.text('Coffee unavailable'), findsOneWidget);
      expect(image(), findsNothing);
      expect(
        tester.getSize(find.byType(BuyMeACoffeeIcon)),
        const Size.square(56),
      );
      if (failure == 'loading') {
        pending.completeError(StateError('coffee asset unavailable'));
      } else {
        pending.complete(Uint8List.fromList([1, 2, 3]).buffer.asByteData());
      }
      await advanceImages(tester, 4);
      expect(find.text('Coffee unavailable'), findsOneWidget);
      expect(
        tester.getSize(find.byType(BuyMeACoffeeIcon)),
        const Size.square(56),
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}

class _PendingCoffeeAssetBundle extends CachingAssetBundle {
  _PendingCoffeeAssetBundle(this.coffee);

  final Future<ByteData> coffee;

  @override
  Future<ByteData> load(String key) =>
      key.endsWith('app-support-coffee.gif') ? coffee : rootBundle.load(key);
}
