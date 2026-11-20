import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show BuildContext, Locale;

import '../l10n/localizations.dart';
import 'consts.dart';

/// Keeps Flutter's application title and the native title bar in sync.
String appWindowTitle(BuildContext context) {
  // FIXME: Restore localized Windows titles after window_manager/cnativeapi
  // preserves Unicode window procedures. cnativeapi 0.5.10 and 0.6.1 omit the
  // Unicode build definitions, so its ANSI subclass turns non-ASCII into '?'.
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    return lookupL10n(const Locale('en')).appName;
  }
  return L10n.of(context)?.appName ?? appName;
}
