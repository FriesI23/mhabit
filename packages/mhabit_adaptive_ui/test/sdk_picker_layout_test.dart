import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart' as native;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/material.dart';

const _window = Size(951, 669);
const _verticalFold = DisplayFeature(
  bounds: Rect.fromLTWH(455.5, 0, 40, 669),
  type: DisplayFeatureType.fold,
  state: DisplayFeatureState.postureHalfOpened,
);
const _horizontalFold = DisplayFeature(
  bounds: Rect.fromLTWH(0, 314.5, 951, 40),
  type: DisplayFeatureType.fold,
  state: DisplayFeatureState.postureHalfOpened,
);

Widget _app({
  required ValueNotifier<MediaQueryData> media,
  required VoidCallback Function(BuildContext) onOpen,
  bool material3 = true,
  TargetPlatform? platform,
}) => MaterialApp(
  theme: ThemeData(useMaterial3: material3, platform: platform),
  builder: (context, child) => ValueListenableBuilder<MediaQueryData>(
    valueListenable: media,
    child: child,
    builder: (context, data, child) => MediaQuery(data: data, child: child!),
  ),
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(onPressed: onOpen(context), child: const Text('Open')),
    ),
  ),
);

void _configureView(WidgetTester tester) {
  tester.view.physicalSize = _window;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _expectInPane(WidgetTester tester, Rect pane) {
  final dialog = tester.getRect(find.byType(Dialog));
  expect(dialog.left, greaterThanOrEqualTo(pane.left));
  expect(dialog.top, greaterThanOrEqualTo(pane.top));
  expect(dialog.right, lessThanOrEqualTo(pane.right));
  expect(dialog.bottom, lessThanOrEqualTo(pane.bottom));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'SDK route keeps window orientation until the picker is wrapped',
    (tester) async {
      _configureView(tester);
      final media = ValueNotifier(
        const MediaQueryData(size: _window, displayFeatures: [_verticalFold]),
      );
      addTearDown(media.dispose);
      var wrap = false;
      MediaQueryData? pickerMedia;
      BoxConstraints? routeConstraints;
      await tester.pumpWidget(
        _app(
          media: media,
          onOpen: (context) => () {
            final showPicker = wrap ? showDatePicker : native.showDatePicker;
            showPicker(
              context: context,
              initialDate: DateTime(2026, 10, 20),
              firstDate: DateTime(2026),
              lastDate: DateTime(2026, 12, 31),
              builder: (context, child) => LayoutBuilder(
                builder: (context, constraints) {
                  routeConstraints = constraints;
                  final picker = Builder(
                    builder: (context) {
                      pickerMedia = MediaQuery.of(context);
                      return child!;
                    },
                  );
                  return picker;
                },
              ),
            );
          },
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(routeConstraints!.biggest, const Size(455.5, 669));
      expect(pickerMedia!.size, _window);
      expect(pickerMedia!.orientation, Orientation.landscape);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      wrap = true;
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(pickerMedia!.size, const Size(455.5, 669));
      expect(pickerMedia!.orientation, Orientation.portrait);
      _expectInPane(tester, const Rect.fromLTWH(0, 0, 455.5, 669));
    },
  );

  testWidgets('picker keeps the route-projected keyboard inset', (
    tester,
  ) async {
    _configureView(tester);
    final media = ValueNotifier(
      const MediaQueryData(
        size: _window,
        displayFeatures: [_horizontalFold],
        viewInsets: EdgeInsets.only(bottom: 200),
      ),
    );
    addTearDown(media.dispose);
    MediaQueryData? pickerMedia;
    await tester.pumpWidget(
      _app(
        media: media,
        onOpen: (context) => () {
          showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 15, minute: 25),
            builder: (context, child) {
              pickerMedia = MediaQuery.of(context);
              return child!;
            },
          );
        },
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(pickerMedia!.size, const Size(951, 314.5));
    expect(pickerMedia!.orientation, Orientation.landscape);
    expect(pickerMedia!.viewInsets.bottom, 0);
    expect(pickerMedia!.displayFeatures, isEmpty);
    _expectInPane(tester, const Rect.fromLTWH(0, 0, 951, 314.5));
  });

  testWidgets(
    'date picker forwards its anchor and runs the custom builder locally',
    (tester) async {
      _configureView(tester);
      final media = ValueNotifier(
        const MediaQueryData(size: _window, displayFeatures: [_verticalFold]),
      );
      addTearDown(media.dispose);
      Size? builderSize;
      DateTime? result;
      await tester.pumpWidget(
        _app(
          media: media,
          onOpen: (context) => () async {
            result = await showDatePicker(
              context: context,
              initialDate: DateTime(2026, 10, 20),
              firstDate: DateTime(2026),
              lastDate: DateTime(2026, 12, 31),
              anchorPoint: const Offset(800, 300),
              confirmText: 'Choose date',
              cancelText: 'Keep date',
              builder: (context, child) {
                builderSize = MediaQuery.sizeOf(context);
                return Theme(
                  data: Theme.of(context).copyWith(
                    datePickerTheme: const DatePickerThemeData(
                      headerBackgroundColor: Colors.teal,
                    ),
                  ),
                  child: child!,
                );
              },
            );
          },
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(builderSize, const Size(455.5, 669));
      _expectInPane(tester, const Rect.fromLTWH(495.5, 0, 455.5, 669));
      expect(
        DatePickerTheme.of(
          tester.element(find.byType(DatePickerDialog)),
        ).headerBackgroundColor,
        Colors.teal,
      );
      expect(find.text('Keep date'), findsOneWidget);
      await tester.tap(find.text('Choose date'));
      await tester.pumpAndSettle();
      expect(result, DateTime(2026, 10, 20));
    },
  );

  for (final material3 in [false, true]) {
    for (final fold in [_verticalFold, _horizontalFold]) {
      final vertical = fold == _verticalFold;
      final pane = vertical
          ? const Rect.fromLTWH(0, 0, 455.5, 669)
          : const Rect.fromLTWH(0, 0, 951, 314.5);
      testWidgets('M${material3 ? 3 : 2} SDK date at 1.3 scale in '
          '${vertical ? 'vertical' : 'horizontal'} pane selects and cancels', (
        tester,
      ) async {
        _configureView(tester);
        final media = ValueNotifier(
          MediaQueryData(
            size: _window,
            displayFeatures: [fold],
            textScaler: const TextScaler.linear(1.3),
          ),
        );
        addTearDown(media.dispose);
        DateTime? result;
        var completions = 0;
        await tester.pumpWidget(
          _app(
            media: media,
            material3: material3,
            onOpen: (context) => () async {
              result = await showDatePicker(
                context: context,
                initialDate: DateTime(2026, 10, 20),
                firstDate: DateTime(2026),
                lastDate: DateTime(2026, 12, 31),
              );
              completions++;
            },
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        _expectInPane(tester, pane);
        await tester.tap(find.text('21'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(result, DateTime(2026, 10, 21));
        expect(completions, 1);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(material3 ? 'Cancel' : 'CANCEL'));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(completions, 2);
      });

      testWidgets('M${material3 ? 3 : 2} SDK time at 1.3 scale in '
          '${vertical ? 'vertical' : 'horizontal'} pane selects and cancels', (
        tester,
      ) async {
        _configureView(tester);
        final media = ValueNotifier(
          MediaQueryData(
            size: _window,
            displayFeatures: [fold],
            textScaler: const TextScaler.linear(1.3),
          ),
        );
        addTearDown(media.dispose);
        TimeOfDay? result;
        var completions = 0;
        await tester.pumpWidget(
          _app(
            media: media,
            material3: material3,
            onOpen: (context) => () async {
              result = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 15, minute: 25),
              );
              completions++;
            },
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        _expectInPane(tester, pane);
        final inputMode = find.byTooltip('Switch to text input mode');
        await tester.ensureVisible(inputMode);
        await tester.pumpAndSettle();
        await tester.tap(inputMode);
        await tester.pumpAndSettle();
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), '4');
        await tester.enterText(fields.at(1), '30');
        await tester.ensureVisible(find.text('OK'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(result, const TimeOfDay(hour: 16, minute: 30));
        expect(completions, 1);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final cancel = find.text(material3 ? 'Cancel' : 'CANCEL');
        await tester.ensureVisible(cancel);
        await tester.pumpAndSettle();
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(completions, 2);
      });
    }

    testWidgets(
      'M${material3 ? 3 : 2} calendar selection survives fold and rotation',
      (tester) async {
        _configureView(tester);
        final media = ValueNotifier(
          const MediaQueryData(size: _window, displayFeatures: [_verticalFold]),
        );
        addTearDown(media.dispose);
        DateTime? result;
        await tester.pumpWidget(
          _app(
            media: media,
            material3: material3,
            onOpen: (context) => () async {
              result = await showDatePicker(
                context: context,
                initialDate: DateTime(2026, 10, 20),
                firstDate: DateTime(2026),
                lastDate: DateTime(2026, 12, 31),
                initialEntryMode: DatePickerEntryMode.calendarOnly,
              );
            },
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('22'));
        await tester.pumpAndSettle();
        media.value = const MediaQueryData(
          size: _window,
          displayFeatures: [_horizontalFold],
        );
        await tester.pumpAndSettle();
        _expectInPane(tester, const Rect.fromLTWH(0, 0, 951, 314.5));
        tester.view.physicalSize = const Size(669, 951);
        media.value = const MediaQueryData(size: Size(669, 951));
        await tester.pumpAndSettle();
        _expectInPane(tester, const Rect.fromLTWH(0, 0, 669, 951));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(result, DateTime(2026, 10, 22));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'time input keeps its editing state during keyboard fold rotation',
    (tester) async {
      _configureView(tester);
      final media = ValueNotifier(
        const MediaQueryData(
          size: _window,
          displayFeatures: [_verticalFold],
          viewInsets: EdgeInsets.only(bottom: 220),
          alwaysUse24HourFormat: true,
        ),
      );
      addTearDown(media.dispose);
      TimeOfDay? result;
      var completions = 0;
      await tester.pumpWidget(
        _app(
          media: media,
          onOpen: (context) => () async {
            result = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 15, minute: 25),
              initialEntryMode: TimePickerEntryMode.input,
              errorInvalidText: 'Invalid time',
            );
            completions++;
          },
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), '99');
      await tester.enterText(fields.at(1), '53');
      await tester.showKeyboard(fields.at(0));
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '99',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();
      final dialogState = tester.state(find.byType(TimePickerDialog));
      final hourState = tester.state(fields.at(0));
      final hour = tester.widget<EditableText>(fields.at(0));
      final minute = tester.widget<EditableText>(fields.at(1));
      final hourValue = hour.controller.value;

      for (final step in [
        (
          const Size(669, 951),
          const [
            DisplayFeature(
              bounds: Rect.fromLTWH(0, 455.5, 669, 40),
              type: DisplayFeatureType.fold,
              state: DisplayFeatureState.postureHalfOpened,
            ),
          ],
        ),
        (_window, const [_verticalFold]),
        (const Size(466, 678), const <DisplayFeature>[]),
      ]) {
        tester.view.physicalSize = step.$1;
        media.value = media.value.copyWith(
          size: step.$1,
          displayFeatures: step.$2,
        );
        for (var frame = 0; frame < 16; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.takeException(), isNull);
          expect(
            tester.state(find.byType(TimePickerDialog)),
            same(dialogState),
          );
          expect(tester.state(fields.at(0)), same(hourState));
          final currentHour = tester.widget<EditableText>(fields.at(0));
          expect(currentHour.controller, same(hour.controller));
          expect(currentHour.controller.value, hourValue);
          expect(currentHour.focusNode, same(hour.focusNode));
          expect(currentHour.focusNode.hasFocus, isTrue);
          expect(
            tester.widget<EditableText>(fields.at(1)).controller,
            same(minute.controller),
          );
          expect(minute.controller.text, '53');
          expect(completions, 0);
        }
      }

      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid time'), findsWidgets);
      expect(hour.controller.text, '99');
      expect(completions, 0);
      await tester.enterText(fields.at(0), '08');
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, const TimeOfDay(hour: 8, minute: 53));
      expect(completions, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('time input scrolls within a short pane above the keyboard', (
    tester,
  ) async {
    _configureView(tester);
    final media = ValueNotifier(
      const MediaQueryData(
        size: _window,
        displayFeatures: [_verticalFold],
        viewInsets: EdgeInsets.only(bottom: 440),
        alwaysUse24HourFormat: true,
      ),
    );
    addTearDown(media.dispose);
    MediaQueryData? builderMedia;
    TimeOfDay? result;
    await tester.pumpWidget(
      _app(
        media: media,
        onOpen: (context) => () async {
          result = await showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 15, minute: 25),
            initialEntryMode: TimePickerEntryMode.inputOnly,
            builder: (context, child) {
              builderMedia = MediaQuery.of(context);
              return Theme(
                data: Theme.of(context).copyWith(
                  timePickerTheme: const TimePickerThemeData(
                    padding: EdgeInsets.all(32),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(builderMedia!.size, const Size(455.5, 669));
    expect(builderMedia!.viewInsets.bottom, 440);
    expect(
      TimePickerTheme.of(tester.element(find.byType(TimePickerDialog))).padding,
      const EdgeInsets.all(32),
    );
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), '08');
    await tester.enterText(fields.at(1), '53');
    await tester.ensureVisible(find.text('OK'));
    await tester.pumpAndSettle();
    final action = tester.getRect(find.text('OK'));
    expect(action.top, greaterThanOrEqualTo(0));
    expect(action.bottom, lessThanOrEqualTo(669 - 440));
    expect(action.right, lessThanOrEqualTo(455.5));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, const TimeOfDay(hour: 8, minute: 53));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop time input stays usable in a short window without folds',
    (tester) async {
      _configureView(tester);
      const window = Size(480, 240);
      tester.view.physicalSize = window;
      final media = ValueNotifier(
        const MediaQueryData(size: window, alwaysUse24HourFormat: true),
      );
      addTearDown(media.dispose);
      TimeOfDay? result;
      var completions = 0;
      await tester.pumpWidget(
        _app(
          media: media,
          platform: TargetPlatform.macOS,
          onOpen: (context) => () async {
            result = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 15, minute: 25),
              initialEntryMode: TimePickerEntryMode.inputOnly,
            );
            completions++;
          },
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), '08');
      await tester.enterText(fields.at(1), '53');
      await tester.ensureVisible(find.text('OK'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('OK')).bottom, lessThanOrEqualTo(240));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, const TimeOfDay(hour: 8, minute: 53));
      expect(completions, 1);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(completions, 2);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(result, isNull);
      expect(completions, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
