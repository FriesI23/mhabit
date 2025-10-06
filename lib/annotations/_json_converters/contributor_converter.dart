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

import '../../models/contributor.dart';

class ContributorCollectionConverter
    implements JsonConverter<ContributorCollection, Map<String, dynamic>> {
  const ContributorCollectionConverter();

  Iterable<ContributorInfo> buildDefinedContributors(Iterable rawData) =>
      rawData.whereType<Map<String, dynamic>>().map(ContributorInfo.fromJson);

  Iterable<ContributorInfo> buildContributors(Iterable rawData,
      [Map<int, ContributorInfo> definedContributors = const {}]) sync* {
    for (var d in rawData) {
      switch (d) {
        case int():
          if (definedContributors.containsKey(d)) yield definedContributors[d]!;
          break;
        case Map<String, dynamic>():
          yield ContributorInfo.fromJson(d);
        default:
          continue;
      }
    }
  }

  @override
  ContributorCollection fromJson(Map<String, dynamic> json) {
    final rawDefinedContributors = json["_contributor"];
    final definedContributors =
        rawDefinedContributors != null && rawDefinedContributors is List
            ? Map<int, ContributorInfo>.fromIterable(
                buildDefinedContributors(rawDefinedContributors),
                key: (e) => (e as ContributorInfo).id!)
            : const <int, ContributorInfo>{};

    List<ContributorInfo> contributorListbuilder(dynamic rawData) =>
        rawData != null && rawData is List
            ? List<ContributorInfo>.unmodifiable(
                buildContributors(rawData, definedContributors))
            : const <ContributorInfo>[];

    SplayTreeMap<Locale, List<ContributorInfo>> translationsMapBuilder(
        dynamic rawData) {
      final translations = SplayTreeMap<Locale, List<ContributorInfo>>(
          (a, b) => a.toLanguageTag().compareTo(b.toLanguageTag()));
      for (var entry in (rawData != null && rawData is Map<String, dynamic>
              ? rawData
              : const <String, dynamic>{})
          .entries) {
        final locale = Locale.tryParse(entry.key);
        if (locale == null) continue;
        final transList = contributorListbuilder(entry.value);
        if (transList.isNotEmpty) translations[locale] = transList;
      }
      return translations;
    }

    return ContributorCollection(
      contributors: contributorListbuilder(json["contributors"]),
      translations: translationsMapBuilder(json["translations"]),
    );
  }

  @override
  Map<String, dynamic> toJson(ContributorCollection object) =>
      throw UnimplementedError();
}
