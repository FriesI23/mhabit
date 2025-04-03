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

import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/utils.dart';

import '../common/exceptions.dart';

extension WebDavResourceExtention on WebDavStdResource {
  WebDavStdResourceProp<String> get getetag =>
      find(WebDavElementNames.getetag, namespace: kDavNamespaceUrlStr).first
          as WebDavStdResourceProp<String>;

  WebDavStdResourceProp<ResourceTypes> get resourcetype =>
      find(WebDavElementNames.resourcetype, namespace: kDavNamespaceUrlStr)
          .first as WebDavStdResourceProp<ResourceTypes>;

  bool get isCollection => resourcetype.value?.isCollection ?? false;

  void tryToRaiseError({bool raiseError = true, bool raiseStatus = true}) {
    if (raiseStatus && status > 300) {
      throw HttpStatusException("Http request failed, status=$status", status,
          uri: path);
    }
    if (raiseError) {
      final error = this.error;
      if (error != null) throw error;
    }
  }
}
