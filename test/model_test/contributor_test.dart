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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/locale.dart';
import 'package:mhabit/annotation/contributor_converter.dart';
import 'package:mhabit/model/contributor.dart';

void testContributorInfo() => group("test ContributorInfo", () {
      test("init", () {
        const contributor = ContributorInfo(id: 1, name: "John Doe");
        expect(contributor.id, 1);
        expect(contributor.name, "John Doe");
      });
      test("fromJson", () {
        final json = {'id': 1, 'name': 'Jane Smith'};
        final contributor = ContributorInfo.fromJson(json);
        expect(contributor.id, 1);
        expect(contributor.name, 'Jane Smith');
      });
    });

void testContributorCollectionConverter() =>
    group("test ContributorCollectionConverter", () {
      const converter = ContributorCollectionConverter();

      test("fromJson", () {
        final jsonData = jsonDecode("""{
  "contributors": [
    {"name": "John Doe"},
    {"name": "Jane Smith"}
  ],
  "translations": {
    "en": [
      {"name": "John Doe"},
      {"name": "Jane Smith"}
    ],
    "fr_FR": [
      {"name": "Jean Dupont"}
    ],
    "de": []
  }
}""");

        final contributorCollection = converter.fromJson(jsonData);

        expect(contributorCollection, isNotNull);
        expect(contributorCollection.contributors, isNotEmpty);
        expect(contributorCollection.contributors.length, 2);

        expect(contributorCollection.contributors[0].name, "John Doe");
        expect(contributorCollection.contributors[1].name, "Jane Smith");

        expect(contributorCollection.translations, isNotEmpty);
        expect(contributorCollection.translations.length, 2);

        final enTranslation =
            contributorCollection.translations[Locale.parse("en")];
        expect(enTranslation, isNotNull);
        expect(enTranslation!.length, 2);
        expect(enTranslation[0].name, "John Doe");
        expect(enTranslation[1].name, "Jane Smith");

        final frFRTranslation =
            contributorCollection.translations[Locale.parse("fr_FR")];
        expect(frFRTranslation, isNotNull);
        expect(frFRTranslation!.length, 1);
        expect(frFRTranslation[0].name, "Jean Dupont");

        final deTranslation =
            contributorCollection.translations[Locale.parse("de")];
        expect(deTranslation, isNull);

        final faTranslation =
            contributorCollection.translations[Locale.parse("fa")];
        expect(faTranslation, isNull);
      });

      test("fromJson with _contributor", () {
        final jsonData = jsonDecode("""{
  "_contributor": [
    {"id": 1, "name": "John Doe"},
    {"id": 2, "name": "Jane Smith"},
    {"id": 3, "name": "Marry Jahn"}
  ],
  "contributors": [
    1, 2
  ],
  "translations": {
    "en": [
      {"name": "Bob Li"}, 3
    ],
    "fr_FR": [
      2, {"name": "Jean Dupont"}, 1
    ],
    "de": []
  }
}""");

        final contributorCollection = converter.fromJson(jsonData);

        expect(contributorCollection, isNotNull);
        expect(contributorCollection.contributors, isNotEmpty);
        expect(contributorCollection.contributors.length, 2);

        expect(contributorCollection.contributors[0].name, "John Doe");
        expect(contributorCollection.contributors[1].name, "Jane Smith");

        expect(contributorCollection.translations, isNotEmpty);
        expect(contributorCollection.translations.length, 2);

        final enTranslation =
            contributorCollection.translations[Locale.parse("en")];
        expect(enTranslation, isNotNull);
        expect(enTranslation!.length, 2);
        expect(enTranslation[0].name, "Bob Li");
        expect(enTranslation[1].name, "Marry Jahn");

        final frFRTranslation =
            contributorCollection.translations[Locale.parse("fr_FR")];
        expect(frFRTranslation, isNotNull);
        expect(frFRTranslation!.length, 3);
        expect(frFRTranslation[0].name, "Jane Smith");
        expect(frFRTranslation[1].name, "Jean Dupont");
        expect(frFRTranslation[2].name, "John Doe");

        final deTranslation =
            contributorCollection.translations[Locale.parse("de")];
        expect(deTranslation, isNull);

        final faTranslation =
            contributorCollection.translations[Locale.parse("fa")];
        expect(faTranslation, isNull);
      });
    });

void testContributors() => group("test Contributors", () {
      final json = jsonDecode("""{
  "contributors": [
    {"name": "Jane Smith"},
    {"name": "John Doe"}
  ],
  "translations": {
    "fr_FR": [
      {"name": "Jean Dupont"}
    ],
    "zh": [
      {"name": "Jack Chen"}
    ],
    "en": [
      {"name": "John Doe"},
      {"name": "Jane Smith"}
    ],
    "de": []
  }
}""");
      final c = Contributors.fromJson(json);

      test("locales", () {
        expect(
            c.locales.toList(),
            equals([
              Locale.fromSubtags(languageCode: "en"),
              Locale.fromSubtags(languageCode: "fr", countryCode: "FR"),
              Locale.fromSubtags(languageCode: "zh"),
            ]));
      });

      test("getTranslations", () {
        final r = c.getTranslations(Locale.fromSubtags(languageCode: "en"));
        expect(r, isNotNull);
        expect(r, isNotEmpty);
        expect(r!.first.name, "John Doe");
      });

      test("getTranslations not found", () {
        for (var l in [
          Locale.fromSubtags(languageCode: "en", countryCode: "US"),
          Locale.fromSubtags(languageCode: "de"),
          Locale.fromSubtags(languageCode: "fa"),
        ]) {
          expect(c.getTranslations(l), isNull);
        }
      });

      test("getContributors", () {
        final r = c.getContributors().toList();
        expect(r[0].name, "Jane Smith");
        expect(r[1].name, "John Doe");
      });
    });

void main() async {
  testContributorInfo();
  testContributorCollectionConverter();
  testContributors();
}
