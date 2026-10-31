import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/material_localizations.dart';

class _ReloadingDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _ReloadingDelegate(this.revision);

  final int revision;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.delegate.load(locale);

  @override
  bool shouldReload(covariant _ReloadingDelegate old) =>
      old.revision != revision;
}

void main() {
  test('unchanged proxy passes the underlying delegate to shouldReload', () {
    final previous = MaterialLocalizatiosProxy.delegateProxyOf(
      GlobalMaterialLocalizations.delegate,
      overrides: {'firstDayOfWeekIndex': 1},
    );
    final next = MaterialLocalizatiosProxy.delegateProxyOf(
      GlobalMaterialLocalizations.delegate,
      overrides: {'firstDayOfWeekIndex': 1},
    );
    expect(next.shouldReload(previous), isFalse);
  });

  test('first day override changes invalidate the localizations', () {
    final previous = MaterialLocalizatiosProxy.delegateProxyOf(
      DefaultMaterialLocalizations.delegate,
      overrides: {'firstDayOfWeekIndex': 1},
    );
    final next = MaterialLocalizatiosProxy.delegateProxyOf(
      DefaultMaterialLocalizations.delegate,
      overrides: {'firstDayOfWeekIndex': 0},
    );
    expect(next.shouldReload(previous), isTrue);
  });

  test('base delegate changes reload without crossing covariant types', () {
    final previous = MaterialLocalizatiosProxy.delegateProxyOf(
      DefaultMaterialLocalizations.delegate,
    );
    final next = MaterialLocalizatiosProxy.delegateProxyOf(
      GlobalMaterialLocalizations.delegate,
    );
    expect(next.shouldReload(previous), isTrue);
  });

  test('same-type base delegates retain their own reload policy', () {
    final previous = MaterialLocalizatiosProxy.delegateProxyOf(
      const _ReloadingDelegate(1),
    );
    final unchanged = MaterialLocalizatiosProxy.delegateProxyOf(
      const _ReloadingDelegate(1),
    );
    final next = MaterialLocalizatiosProxy.delegateProxyOf(
      const _ReloadingDelegate(2),
    );
    expect(unchanged.shouldReload(previous), isFalse);
    expect(next.shouldReload(previous), isTrue);
  });

  test(
    'loading retains the configured first day and base translations',
    () async {
      final delegate = MaterialLocalizatiosProxy.delegateProxyOf(
        GlobalMaterialLocalizations.delegate,
        overrides: {'firstDayOfWeekIndex': 1},
      );
      const locale = Locale('en');
      final value = await delegate.load(locale);
      final original = await GlobalMaterialLocalizations.delegate.load(locale);
      expect(value.firstDayOfWeekIndex, 1);
      expect(value.okButtonLabel, original.okButtonLabel);
      expect(value.narrowWeekdays, original.narrowWeekdays);
    },
  );
}
