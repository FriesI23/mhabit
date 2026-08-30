import 'package:adaptive_actions/cupertino.dart';
import 'package:adaptive_actions/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

final _editId = ActionId('edit');
final _archiveId = ActionId('archive');

AdaptiveAction<String> _action({
  required ActionId id,
  required String label,
  required String payload,
  ActionPlacement placement = ActionPlacement.automatic,
  bool isEnabled = true,
}) => AdaptiveAction.action(
  id: id,
  metadata: ActionMetadata(label: label, tooltip: label),
  payload: payload,
  isEnabled: isEnabled,
  placementPolicy: ActionPlacementPolicy(placement: placement),
);

ActionCollection<String> _collection({
  bool includeArchive = true,
  bool editEnabled = true,
}) => ActionCollection(
  roots: [
    _action(
      id: _editId,
      label: 'Edit',
      payload: 'edit',
      placement: ActionPlacement.pinned,
      isEnabled: editEnabled,
    ),
    if (includeArchive)
      _action(
        id: _archiveId,
        label: 'Archive',
        payload: 'archive',
        placement: ActionPlacement.overflowOnly,
      ),
  ],
);

Widget _host({
  required Widget actions,
  TextDirection textDirection = TextDirection.ltr,
  TargetPlatform? platform,
}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  home: Directionality(
    textDirection: textDirection,
    child: Scaffold(appBar: AppBar(actions: [actions])),
  ),
);

Rect _rectFor(BuildContext context) {
  final box = context.findRenderObject()! as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}

void main() {
  testWidgets('default constructor dispatches from adaptive style', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>(
          collection: _collection(),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
        ),
      ),
    );
    expect(find.byType(MaterialAdaptiveActions<String>), findsOneWidget);

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        actions: AdaptiveAppBarActions<String>(
          collection: _collection(),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAdaptiveActions<String>), findsOneWidget);
  });

  testWidgets('forced constructors select their platform renderer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.material(
          collection: _collection(),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
        ),
      ),
    );
    expect(find.byType(MaterialAdaptiveActions<String>), findsOneWidget);

    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.apple(
          collection: _collection(),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
        ),
      ),
    );
    expect(find.byType(CupertinoAdaptiveActions<String>), findsOneWidget);
  });

  testWidgets('material keeps one primary action and invokes its payload', (
    tester,
  ) async {
    String? invoked;
    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.material(
          collection: _collection(),
          onInvoke: (_, payload) => invoked = payload,
          primaryCapacity: 96,
          maxPrimaryActions: 1,
          materialIconBuilder: (context, action) =>
              Icon(action.id == _editId ? Icons.edit : Icons.archive_outlined),
        ),
      ),
    );

    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit));
    expect(invoked, 'edit');

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Archive'), findsOneWidget);
  });

  testWidgets('disabled primary action suppresses invocation', (tester) async {
    var invocationCount = 0;
    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.material(
          collection: _collection(editEnabled: false),
          onInvoke: (_, _) => invocationCount += 1,
          primaryCapacity: 96,
          materialIconBuilder: (context, action) => const Icon(Icons.edit),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    expect(invocationCount, 0);
  });

  testWidgets('apple controls keep 44 point targets and logical RTL order', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        textDirection: TextDirection.rtl,
        actions: AdaptiveAppBarActions<String>.apple(
          collection: _collection(),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
          maxPrimaryActions: 1,
          appleIconBuilder: (context, action) => Icon(
            action.id == _editId
                ? CupertinoIcons.pencil
                : CupertinoIcons.archivebox,
          ),
        ),
      ),
    );

    final edit = find.byIcon(CupertinoIcons.pencil);
    final more = find.byIcon(CupertinoIcons.ellipsis);
    expect(tester.getSize(edit).height, lessThanOrEqualTo(44));
    expect(
      tester
          .getSize(
            find
                .ancestor(of: edit, matching: find.byType(CupertinoButton))
                .first,
          )
          .height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(of: more, matching: find.byType(CupertinoButton))
                .first,
          )
          .height,
      greaterThanOrEqualTo(44),
    );
    expect(tester.getCenter(edit).dx, greaterThan(tester.getCenter(more).dx));
  });

  testWidgets('apple reports the exact primary or overflow trigger anchor', (
    tester,
  ) async {
    BuildContext? anchorContext;
    String? invoked;
    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.apple(
          collection: _collection(),
          onInvoke: (context, payload) {
            anchorContext = context;
            invoked = payload;
          },
          primaryCapacity: 96,
          maxPrimaryActions: 1,
          appleIconBuilder: (context, action) => Icon(
            action.id == _editId
                ? CupertinoIcons.pencil
                : CupertinoIcons.archivebox,
          ),
        ),
      ),
    );

    final editButton = find
        .ancestor(
          of: find.byIcon(CupertinoIcons.pencil),
          matching: find.byType(CupertinoButton),
        )
        .first;
    await tester.tap(editButton);
    expect(invoked, 'edit');
    expect(_rectFor(anchorContext!), tester.getRect(editButton));

    anchorContext = null;
    invoked = null;
    final moreButton = find
        .ancestor(
          of: find.byIcon(CupertinoIcons.ellipsis),
          matching: find.byType(CupertinoButton),
        )
        .first;
    final moreRect = tester.getRect(moreButton);
    await tester.tap(moreButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(invoked, 'archive');
    expect(_rectFor(anchorContext!), moreRect);
  });

  testWidgets('rebuilding collection removes only the omitted action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.material(
          collection: _collection(),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
          materialIconBuilder: (context, action) => const Icon(Icons.edit),
        ),
      ),
    );
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.pumpWidget(
      _host(
        actions: AdaptiveAppBarActions<String>.material(
          collection: _collection(includeArchive: false),
          onInvoke: (_, _) {},
          primaryCapacity: 96,
          materialIconBuilder: (context, action) => const Icon(Icons.edit),
        ),
      ),
    );
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });
}
