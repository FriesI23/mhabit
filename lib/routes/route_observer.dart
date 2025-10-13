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

class CurrentRouteObserver extends NavigatorObserver {
  RouteSettings? route;

  String? get routeName => route?.name;

  @override
  void didPush(Route route, Route? previousRoute) {
    this.route = route.settings;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    this.route = previousRoute?.settings;
  }
}
