// Copyright 2025 Fries_I23
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
import 'package:provider/provider.dart';

typedef ViewModelProxyProviderBuilder<T, R> = R Function(
  BuildContext context,
  T value,
  R previous,
);

typedef ViewModelProxyProviderBuilder2<T1, T2, R> = R Function(
  BuildContext context,
  T1 value1,
  T2 value2,
  R previous,
);

typedef ViewModelProxyProviderBuilder3<T1, T2, T3, R> = R Function(
  BuildContext context,
  T1 value1,
  T2 value2,
  T3 value3,
  R previous,
);

typedef ViewModelProxyProviderPostCallback<T, R> = void Function(
  Duration t,
  T value,
  R vm,
);

typedef ViewModelProxyProviderPostCallback2<T1, T2, R> = void Function(
  Duration t,
  T1 value1,
  T2 value2,
  R vm,
);

typedef ViewModelProxyProviderPostCallback3<T1, T2, T3, R> = void Function(
  Duration t,
  T1 value1,
  T2 value2,
  T3 value3,
  R vm,
);

class ViewModelProxyProvider<T, R extends ChangeNotifier?>
    extends ChangeNotifierProxyProvider<T, R> {
  static R _defaultCreater<R>(BuildContext context) => context.read<R>();
  static R _defaultUpdater<T, R>(BuildContext context, T value, R previous) =>
      previous;

  ViewModelProxyProvider({
    super.key,
    Create<R>? create,
    ViewModelProxyProviderBuilder<T, R>? update,
    ViewModelProxyProviderPostCallback<T, R>? post,
    super.lazy,
  }) : super(
          create: create ?? _defaultCreater<R>,
          update: (context, value, previous) {
            assert(previous != null);
            final vm =
                (update ?? _defaultUpdater)(context, value, previous as R);
            if (post != null) {
              WidgetsBinding.instance
                  .addPostFrameCallback((t) => post(t, value, vm));
            }
            return vm;
          },
        );
}

class ViewModelProxyProvider2<T1, T2, R extends ChangeNotifier?>
    extends ChangeNotifierProxyProvider2<T1, T2, R> {
  static R _defaultCreater<R>(BuildContext context) => context.read<R>();
  static R _defaultUpdater<T1, T2, R>(
          BuildContext context, T1 value1, T2 value2, R previous) =>
      previous;

  ViewModelProxyProvider2({
    super.key,
    Create<R>? create,
    ViewModelProxyProviderBuilder2<T1, T2, R>? update,
    ViewModelProxyProviderPostCallback2<T1, T2, R>? post,
    super.lazy,
  }) : super(
          create: create ?? _defaultCreater<R>,
          update: (context, value1, value2, previous) {
            assert(previous != null);
            final vm = (update ?? _defaultUpdater)(
                context, value1, value2, previous as R);
            if (post != null) {
              WidgetsBinding.instance
                  .addPostFrameCallback((t) => post(t, value1, value2, vm));
            }
            return vm;
          },
        );
}

class ViewModelProxyProvider3<T1, T2, T3, R extends ChangeNotifier?>
    extends ChangeNotifierProxyProvider3<T1, T2, T3, R> {
  static R _defaultCreater<R>(BuildContext context) => context.read<R>();
  static R _defaultUpdater<T1, T2, T3, R>(
          BuildContext context, T1 value1, T2 value2, T3 value3, R previous) =>
      previous;

  ViewModelProxyProvider3({
    super.key,
    Create<R>? create,
    ViewModelProxyProviderBuilder3<T1, T2, T3, R>? update,
    ViewModelProxyProviderPostCallback3<T1, T2, T3, R>? post,
    super.lazy,
  }) : super(
          create: create ?? _defaultCreater<R>,
          update: (context, value1, value2, value3, previous) {
            assert(previous != null);
            final vm = (update ?? _defaultUpdater)(
                context, value1, value2, value3, previous as R);
            if (post != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (t) => post(t, value1, value2, value3, vm));
            }
            return vm;
          },
        );
}
