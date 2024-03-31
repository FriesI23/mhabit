// Copyright 2024 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../extension/async_extensions.dart';
import '../logging/helper.dart';
import 'profile_provider.dart';

class ProfileBuilder extends SingleChildStatelessWidget {
  final TransitionBuilder builder;
  final TransitionBuilder? loadingBuilder;
  final ErrorWidgetBuilder? errorBuilder;
  final Iterable<ProfileHandlerBuilder> handlers;

  const ProfileBuilder({
    super.key,
    super.child,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.handlers = const [],
  });

  Future _loadingHelper(BuildContext context) async {
    appLog.db.info("$runtimeType._loadingHelper", ex: ["processing"]);
    final helper = context.read<ProfileViewModel>();
    if (helper.mounted && !helper.inited) await helper.init();
    appLog.db.info("$runtimeType._loadingHelper", ex: ["done"]);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) =>
      ChangeNotifierProvider(
        create: (context) =>
            ProfileViewModel(Map.fromIterable(handlers))..init(),
        lazy: false,
        child: child,
        builder: (context, child) => FutureBuilder(
          future: _loadingHelper(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (errorBuilder != null) {
                return errorBuilder!(FlutterErrorDetails(
                    exception: snapshot.error!,
                    stack: snapshot.stackTrace,
                    library: "profile_builder"));
              } else {
                throw FlutterError("profile build failed");
              }
            } else if (snapshot.isDone) {
              return builder(context, child);
            } else {
              return loadingBuilder?.call(context, child) ?? const SizedBox();
            }
          },
        ),
      );
}
