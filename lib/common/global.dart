// Copyright 2023 Fries_I23
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

import 'package:flutter/material.dart' show ScaffoldMessengerState;
import 'package:flutter/widgets.dart'
    show GlobalKey, NavigatorState, PageRoute, RouteObserver;

import '../logging/level.dart';
import '../routes/route_observer.dart';
import 'utils.dart';

//#region debug options
bool debugClearDBWhenStart = false;
bool debugClearSharedPrefWhenStart = false;
//#endregion

//#region log level
LogLevel kAppLogLevel = getDefaultLogLevel();
//#endregion

//#region ui global key
final snackbarKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
//#endregion

//#region routes
final currentRouteObserver = CurrentRouteObserver();
final pageRouteObserver = RouteObserver<PageRoute>();
//#endregion
