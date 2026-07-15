// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';

/// Minimal [AppSyncWorkflowAccess] stub suitable for most widget/view-model
/// tests.  May be used directly or extended when a test needs to override
/// specific members.
class StubAppSyncWorkflowAccess extends ChangeNotifier
    implements AppSyncWorkflowAccess {
  @override
  bool get canStartSync => true;

  @override
  Stream<AppSyncNeedConfirmEvent> get confirmEvents => const Stream.empty();

  @override
  Future? get syncProcessing => null;

  @override
  AppSyncStatusSnapshot? get syncStatus => null;

  @override
  Stream<String> get startSyncEvents => const Stream.empty();

  @override
  void onL10nUpdate(L10n? l10n) {}

  @override
  Future<void> startSync({Duration? initWait}) async {}

  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {}

  @override
  void cancelSync() {}
}
