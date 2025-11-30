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

import 'dart:collection';

import 'package:intl/locale.dart';
import 'package:json_annotation/json_annotation.dart';

import '../annotations/json_annotations.dart';

part 'contributor.g.dart';

@JsonSerializable(createToJson: false)
class ContributorInfo {
  final int? id;
  final String name;
  final String? url;
  final String? comment;

  const ContributorInfo({this.id, required this.name, this.url, this.comment});

  factory ContributorInfo.fromJson(Map<String, dynamic> json) =>
      _$ContributorInfoFromJson(json);

  @override
  String toString() {
    return "$runtimeType(id=$id,name=$name,url=$url,comment=$comment)";
  }
}

abstract interface class Contributors {
  Iterable<Locale> get locales;

  Iterable<ContributorInfo>? getTranslations(Locale locale);
  Iterable<ContributorInfo> getContributors();

  const Contributors();

  factory Contributors.fromJson(Map<String, dynamic> json) =>
      _Contributors(ContributorCollection.fromJson(json));
}

class _Contributors implements Contributors {
  final ContributorCollection data;

  const _Contributors(this.data);

  @override
  Iterable<ContributorInfo> getContributors() => data.contributors;

  @override
  Iterable<ContributorInfo>? getTranslations(Locale locale) =>
      data.translations[locale];

  @override
  Iterable<Locale> get locales => data.translations.keys;
}

class ContributorCollection {
  final List<ContributorInfo> contributors;
  final SplayTreeMap<Locale, List<ContributorInfo>> translations;

  const ContributorCollection({
    required this.contributors,
    required this.translations,
  });

  factory ContributorCollection.fromJson(Map<String, dynamic> json) =>
      const ContributorCollectionConverter().fromJson(json);
}
