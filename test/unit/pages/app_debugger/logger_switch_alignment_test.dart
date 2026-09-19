import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/app_debugger/widgets.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('Apple logger pause centers on native thumb $direction', (
      tester,
    ) async {
      // Flutter widget tests otherwise render icon fonts as test rectangles.
      await tester.runAsync(() async {
        final loader = FontLoader('MaterialIcons')
          ..addFont(
            File(
              '.flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        await loader.load();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Directionality(
            textDirection: direction,
            child: const Center(
              child: ChangeLogsSwitcherTile(
                value: true,
                onChanged: _ignoreChange,
              ),
            ),
          ),
        ),
      );
      final switchWidget = tester.widget<CupertinoSwitch>(
        find.byType(CupertinoSwitch),
      );
      // Isolate the actual configured switch from page text/background pixels.
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Center(
              child: RepaintBoundary(key: key, child: switchWidget),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      final image = (await tester.runAsync(
        () => boundary.toImage(pixelRatio: 3),
      ))!;
      addTearDown(image.dispose);
      final bytes = (await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      bool matchesColor(int offset, Color color) =>
          (bytes.getUint8(offset) - (color.r * 255).round()).abs() < 8 &&
          (bytes.getUint8(offset + 1) - (color.g * 255).round()).abs() < 8 &&
          (bytes.getUint8(offset + 2) - (color.b * 255).round()).abs() < 8 &&
          bytes.getUint8(offset + 3) > 245;
      final thumbColor = switchWidget.thumbColor ?? CupertinoColors.white;
      final iconColor = switchWidget.thumbIcon!.resolve({
        WidgetState.selected,
      })!.color!;
      var minX = image.width, minY = image.height, maxX = 0, maxY = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final i = (y * image.width + x) * 4;
          if (matchesColor(i, thumbColor)) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
      expect(maxX, greaterThan(minX));
      expect(maxY, greaterThan(minY));
      var sumX = 0.0, sumY = 0.0, count = 0;
      // Exclude the rounded thumb edge and the track outside it.
      final inset = ((maxX - minX) * 0.15).ceil();
      for (var y = minY + inset; y < maxY - inset; y++) {
        for (var x = minX + inset; x < maxX - inset; x++) {
          final i = (y * image.width + x) * 4;
          if (matchesColor(i, iconColor)) {
            sumX += x;
            sumY += y;
            count++;
          }
        }
      }
      expect(count, greaterThan(0));
      expect((sumX / count - (minX + maxX) / 2) / 3, closeTo(0, 0.5));
      expect((sumY / count - (minY + maxY) / 2) / 3, closeTo(0, 0.5));
    });
  }
}

void _ignoreChange(bool value) {}
