import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'harness/adaptive_ui_theme.dart';

const _headerKey = ValueKey('adaptive-modal-app-bar');
const _confirmKey = ValueKey('adaptive-modal-confirm');
const _closeKey = ValueKey('adaptive-modal-implied-close');

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style $direction fold dialog projects safe edges in view coordinates',
        (tester) async {
          const initialSize = Size(1600, 900);
          const safeArea = EdgeInsets.only(left: 72, right: 96);
          tester.view.devicePixelRatio = 2;
          tester.view.physicalSize = initialSize * 2;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);

          MediaQueryData geometry(
            Size size,
            double foldLeft, {
            EdgeInsets padding = EdgeInsets.zero,
          }) => MediaQueryData(
            size: size,
            padding: padding,
            viewPadding: padding,
            displayFeatures: [
              DisplayFeature(
                bounds: Rect.fromLTWH(foldLeft, 0, 20, size.height),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ],
          );

          final media = ValueNotifier(geometry(initialSize, 790));
          addTearDown(media.dispose);
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => Directionality(
                textDirection: direction,
                child: ValueListenableBuilder<MediaQueryData>(
                  valueListenable: media,
                  child: child,
                  builder: (_, data, child) => MediaQuery(
                    data: data,
                    child: TestAdaptiveUiTheme(
                      update: (theme) => theme.copyWith(style: style),
                      child: child!,
                    ),
                  ),
                ),
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showAdaptiveSheet<void>(
                      context: context,
                      showDragHandle: false,
                      builder: (_) => AdaptiveModalNavigator<void>(
                        size: const AdaptiveModalSize.constrained(
                          maxHeight: 720,
                        ),
                        builder: (_) => AdaptiveModal(
                          title: const Text('Create Group'),
                          confirmAction: AdaptiveModalConfirmAction(
                            label: 'Save',
                            onPressed: () {},
                          ),
                          body: const SizedBox(
                            height: 200,
                            child: Text('Form'),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final header = find.byKey(_headerKey);
          final headerElement = tester.element(header);
          final leftControl = find.byKey(
            direction == TextDirection.ltr ? _closeKey : _confirmKey,
          );
          final rightControl = find.byKey(
            direction == TextDirection.ltr ? _confirmKey : _closeKey,
          );

          for (final (size, foldLeft) in [
            (initialSize, 790.0),
            // The RTL pane moves while its local size stays 790 by 900.
            (const Size(1800, 900), 990.0),
            // A narrower pane still needs the part of each safe edge that
            // actually overlaps the dialog, rather than clearing all padding.
            (const Size(1300, 900), 640.0),
          ]) {
            final partialOverlap = size.width == 1300;
            final expectedPadding = !partialOverlap
                ? EdgeInsets.zero
                : switch (direction) {
                    TextDirection.ltr => const EdgeInsets.only(left: 32),
                    TextDirection.rtl => const EdgeInsets.only(right: 56),
                  };
            tester.view.physicalSize = size * 2;
            media.value = geometry(size, foldLeft, padding: safeArea);
            await tester.pumpAndSettle();
            expect(
              MediaQuery.paddingOf(tester.element(header)),
              expectedPadding,
            );
            media.value = geometry(size, foldLeft);
            await tester.pumpAndSettle();
            final bounds = tester.getRect(header);
            final leftGap = tester.getRect(leftControl).left - bounds.left;
            final rightGap = bounds.right - tester.getRect(rightControl).right;
            media.value = geometry(size, foldLeft, padding: safeArea);
            await tester.pumpAndSettle();
            expect(tester.element(header), same(headerElement));
            final headerMedia = MediaQuery.of(tester.element(header));
            expect(headerMedia.size.width, lessThan(size.width));
            expect(headerMedia.padding, expectedPadding);
            expect(headerMedia.viewPadding, expectedPadding);
            final paddedBounds = tester.getRect(header);
            expect(paddedBounds, bounds);
            expect(
              tester.getRect(leftControl).left - paddedBounds.left,
              closeTo(leftGap + expectedPadding.left, 0.1),
            );
            expect(
              paddedBounds.right - tester.getRect(rightControl).right,
              closeTo(rightGap + expectedPadding.right, 0.1),
            );
            expect(leftControl.hitTestable(), findsOneWidget);
            expect(rightControl.hitTestable(), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        },
      );
    }

    for (final dialog in [false, true]) {
      testWidgets(
        '$style ${dialog ? 'centered dialog clears' : 'edge sheet keeps'} horizontal safe area for Save and Close',
        (tester) async {
          final size = Size(dialog ? 1600 : 500, 900);
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final geometry = ValueNotifier(MediaQueryData(size: size));
          addTearDown(geometry.dispose);
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) =>
                  ValueListenableBuilder<MediaQueryData>(
                    valueListenable: geometry,
                    builder: (_, data, _) => MediaQuery(
                      data: data,
                      child: TestAdaptiveUiTheme(
                        update: (theme) => theme.copyWith(style: style),
                        child: child!,
                      ),
                    ),
                  ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showAdaptiveSheet<void>(
                      context: context,
                      showDragHandle: false,
                      // Production Group editing uses this automatic route
                      // and nested Navigator, rather than fixed showDialog.
                      builder: (_) => AdaptiveModalNavigator<void>(
                        size: const AdaptiveModalSize.constrained(
                          maxHeight: 720,
                        ),
                        builder: (_) => AdaptiveModal(
                          title: const Text('Create Group'),
                          confirmAction: AdaptiveModalConfirmAction(
                            label: 'Save',
                            onPressed: () {},
                          ),
                          body: const SizedBox(
                            height: 200,
                            child: Text('Form'),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final headerBefore = tester.getRect(find.byKey(_headerKey));
          final confirmBefore = tester.getRect(find.byKey(_confirmKey));
          final closeBefore = tester.getRect(find.byKey(_closeKey));
          final endGapBefore = headerBefore.right - confirmBefore.right;
          final startGapBefore = closeBefore.left - headerBefore.left;
          expect(
            MediaQuery.paddingOf(tester.element(find.byKey(_headerKey))),
            EdgeInsets.zero,
          );

          const safeArea = EdgeInsets.only(left: 72, right: 96);
          geometry.value = geometry.value.copyWith(
            padding: safeArea,
            viewPadding: safeArea,
          );
          await tester.pumpAndSettle();
          final headerAfter = tester.getRect(find.byKey(_headerKey));
          final confirmAfter = tester.getRect(find.byKey(_confirmKey));
          final closeAfter = tester.getRect(find.byKey(_closeKey));
          final endGapAfter = headerAfter.right - confirmAfter.right;
          final startGapAfter = closeAfter.left - headerAfter.left;
          // Read before AppBar's own SafeArea consumes the incoming padding.
          final toolbarPadding = MediaQuery.paddingOf(
            tester.element(find.byKey(_headerKey)),
          );
          if (dialog) {
            // The full header already lies inside the safe horizontal edges.
            expect(headerAfter.left, greaterThan(72));
            expect(headerAfter.right, lessThan(size.width - 96));
            expect(toolbarPadding, EdgeInsets.zero);
            expect(endGapAfter, closeTo(endGapBefore, 0.1));
            expect(startGapAfter, closeTo(startGapBefore, 0.1));
          } else {
            expect(headerAfter.left, closeTo(0, 0.1));
            expect(headerAfter.right, closeTo(size.width, 0.1));
            expect(toolbarPadding, safeArea);
            expect(endGapAfter, closeTo(endGapBefore + 96, 0.1));
            expect(startGapAfter, closeTo(startGapBefore + 72, 0.1));
          }
          expect(find.byKey(_confirmKey).hitTestable(), findsOneWidget);
          expect(find.byKey(_closeKey).hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
