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

enum LoggerType {
  /// debugger
  debugger,

  /// UI component rebuilding
  build,

  /// Change Property's value
  value,

  /// Navigation between pages
  navi,

  /// Database operation
  db,

  /// App Profile
  profile,

  /// App data loaded
  load,

  /// Notifaction
  notify,

  /// Import data
  import,

  /// Export data
  export,

  /// Habit operation
  habit,

  /// Network about
  network,

  /// Json encode/decode
  json,

  /// Localization
  l10n,

  /// App cache
  cache,

  /// App sync process
  appsync,

  /// App sync process - for task
  appsynctask,
}
