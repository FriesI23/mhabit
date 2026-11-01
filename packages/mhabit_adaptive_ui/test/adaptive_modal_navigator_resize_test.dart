import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show BoxParentData, RenderAnimatedSize;
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable/foldable.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'harness/adaptive_ui_theme.dart';

FoldableData _snapshot(HingeStatus status) => FoldableData(
  capabilities: const FoldableCapabilities(
    supportLevel: FoldableSupportLevel.available,
    isFoldable: true,
    hingeApiPresent: true,
    regionApiPresent: true,
    angleUnitVerified: true,
    strategy: 'test',
  ),
  status: status,
  angleDegrees: status == HingeStatus.partiallyOpen ? 90 : 0,
  regions: const [
    ReservedRegion(
      kind: ReservedRegionKind.division,
      bounds: Rect.fromLTWH(610, 0, 20, 800),
      isActive: true,
    ),
  ],
  displayFeatures: const [],
);

class _FoldSource extends FoldablePlatform {
  final controller = StreamController<FoldableData>.broadcast();
  FoldableData current = _snapshot(HingeStatus.partiallyOpen);

  @override
  Future<FoldableData> getSnapshot() async => current;

  @override
  Stream<FoldableData> get events => controller.stream;
}

class _GroupDraft extends StatefulWidget {
  const _GroupDraft();

  @override
  State<_GroupDraft> createState() => _GroupDraftState();
}

class _GroupDraftState extends State<_GroupDraft> {
  final controller = TextEditingController();
  final focus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: controller, focusNode: focus),
        TextButton(
          onPressed: () => AdaptiveModalNavigator.pop(context, controller.text),
          child: const Text('Save group'),
        ),
      ],
    ),
  );
}

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style modal navigator clears dialog alignment when closing to a sheet during resize',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1600, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final previous = FoldablePlatform.instance;
        final source = _FoldSource();
        String? result;
        FoldablePlatform.instance = source;
        addTearDown(() async {
          FoldablePlatform.instance = previous;
          await source.controller.close();
        });
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => AdaptiveDisplayFeatureLayout(
              child: TestAdaptiveUiTheme(
                update: (theme) => theme.copyWith(style: style),
                child: child!,
              ),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showAdaptiveSheet<String>(
                      context: context,
                      builder: (_) => AdaptiveModalNavigator<String>(
                        // Same sizing contract used by the production Group
                        // editor; this owns a Navigator inside the modal.
                        size: const AdaptiveModalSize.constrained(
                          maxHeight: 720,
                        ),
                        builder: (_) => const AdaptiveModal(
                          title: Text('Edit group'),
                          body: _GroupDraft(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Unfinished group');
        await tester.pump();
        final content = tester.state<_GroupDraftState>(
          find.byType(_GroupDraft),
        );
        final innerNavigator = Navigator.of(content.context);
        expect(innerNavigator.canPop(), isFalse);
        final innerRoute = ModalRoute.of(content.context);
        final outerRoute = ModalRoute.of(innerNavigator.context);
        final innerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Navigator && widget.key == innerNavigator.widget.key,
        );
        final sizeFinder = find
            .ancestor(of: innerFinder, matching: find.byType(AnimatedSize))
            .first;
        final animated = tester.renderObject<RenderAnimatedSize>(sizeFinder);

        // Hinge status can clear the fold before cover-display metrics arrive.
        // Start expanding the dialog, then close before its 200ms animation
        // settles. This creates the real nonzero center-alignment offset.
        source.current = _snapshot(HingeStatus.closed);
        source.controller.add(source.current);
        await tester.pump();
        final expandingOffset =
            (animated.child!.parentData! as BoxParentData).offset;
        expect(expandingOffset.dx, lessThan(0));

        // Logical window measured from the reported Duo runtime. MediaQuery
        // follows the view normally; no synthetic stale-size override is used.
        tester.view.physicalSize = const Size(466, 678);
        await tester.pump();

        void expectSheetFrame(String phase) {
          final bounds = tester.getRect(innerFinder);
          expect(bounds.left, closeTo(0, 0.1), reason: phase);
          expect(bounds.right, closeTo(466, 0.1), reason: phase);
          expect(
            tester
                .renderObject<RenderBox>(innerFinder)
                .localToGlobal(
                  Offset.zero,
                  ancestor: tester.renderObject<RenderBox>(
                    find.byWidgetPredicate(
                      (widget) => widget is AdaptiveModalNavigator,
                    ),
                  ),
                ),
            Offset.zero,
            reason: phase,
          );
          expect(
            tester.state<_GroupDraftState>(find.byType(_GroupDraft)),
            same(content),
            reason: phase,
          );
          expect(
            Navigator.of(content.context),
            same(innerNavigator),
            reason: phase,
          );
          expect(innerNavigator.canPop(), isFalse, reason: phase);
          expect(
            ModalRoute.of(content.context),
            same(innerRoute),
            reason: phase,
          );
          expect(
            ModalRoute.of(innerNavigator.context),
            same(outerRoute),
            reason: phase,
          );
          expect(content.controller.text, 'Unfinished group', reason: phase);
          expect(content.focus.hasFocus, isTrue, reason: phase);
          expect(tester.takeException(), isNull, reason: phase);
        }

        expectSheetFrame('first cover-display frame');
        await tester.pumpAndSettle();
        expectSheetFrame('settled cover display');
        await tester.tap(find.text('Save group'));
        await tester.pumpAndSettle();
        expect(result, 'Unfinished group');
        expect(find.byType(_GroupDraft), findsNothing);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }
}
