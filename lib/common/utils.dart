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

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../extension/datetime_extensions.dart';
import '../logging/level.dart';
import '../theme/color.dart';
import 'consts.dart';

ThemeMode transToMaterialThemeType(AppThemeType themeType) {
  switch (themeType) {
    case AppThemeType.light:
      return ThemeMode.light;
    case AppThemeType.dark:
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

Iterable<T> combineIterables<T>(Iterable<T> first, Iterable<T> second,
    {required int Function(T a, T b) compare}) sync* {
  final firstIterator = first.iterator;
  final secondIterator = second.iterator;

  var firstHasNext = firstIterator.moveNext();
  var secondHasNext = secondIterator.moveNext();

  while (firstHasNext && secondHasNext) {
    final firstElement = firstIterator.current;
    final secondElement = secondIterator.current;

    if (compare(firstElement, secondElement) <= 0) {
      yield firstElement;
      firstHasNext = firstIterator.moveNext();
    } else {
      yield secondElement;
      secondHasNext = secondIterator.moveNext();
    }
  }

  while (firstHasNext) {
    yield firstIterator.current;
    firstHasNext = firstIterator.moveNext();
  }

  while (secondHasNext) {
    yield secondIterator.current;
    secondHasNext = secondIterator.moveNext();
  }
}

Size calcTextSize(String text, TextStyle? style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

// Copyright github@creativecreatorormaybenot
// see:　https://gist.github.com/creativecreatorormaybenot/7c57666a53cbf21f2adab08b4ad84ef5
class TemplateString {
  final List<String> fixedComponents;
  final Map<int, String> genericComponents;

  int totalComponents;

  TemplateString(String template)
      : fixedComponents = <String>[],
        genericComponents = <int, String>{},
        totalComponents = 0 {
    final List<String> components = template.split('{');

    for (String component in components) {
      if (component == '') {
        continue;
      }

      final split = component.split('}');

      if (split.length != 1) {
        genericComponents[totalComponents] = split.first;
        totalComponents++;
      }

      if (split.last != '') {
        fixedComponents.add(split.last);
        totalComponents++;
      }
    }
  }

  String format(Map<String, dynamic> params) {
    final result = StringBuffer();

    int fixedComponent = 0;
    for (var i = 0; i < totalComponents; i++) {
      if (genericComponents.containsKey(i)) {
        result.write(params[genericComponents[i]]);
      } else {
        result.write(fixedComponents[fixedComponent++]);
      }
    }

    return result.toString();
  }
}

String truncateString(String s, int x, int l, int r, {String midStr = "..."}) {
  if (kDebugMode) assert(x > l + r);
  return s.length <= x
      ? s
      : "${s.substring(0, l)} $midStr ${s.substring(s.length - r)}";
}

String genHabitUUID() {
  const uuid = Uuid();
  return uuid.v4();
}

String genRecordUUID() {
  const uuid = Uuid();
  return uuid.v4();
}

int standardizeFirstDay(int firstDay) {
  return math.max(1, math.min(7, firstDay));
}

DateTime getProtoDateWithFirstDay(int firstDay) {
  return DateTime(2023, 5, firstDay);
}

Iterable<Tuple2<int, int>> getContinuousRanges(List<int> input) sync* {
  int start = -1;

  for (int i = 0; i < input.length; i++) {
    if (i == 0 || input[i] != input[i - 1] + 1) {
      // Start a new range
      if (start >= 0) {
        yield Tuple2(input[start], input[i - 1]);
      }
      start = i;
    }
  }

  if (start >= 0) {
    yield Tuple2(input[start], input[input.length - 1]);
  }
}

String? encodeUrlQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

Future<bool> launchExternalUrl(Uri url) async {
  return url_launcher.launchUrl(url, mode: LaunchMode.externalApplication);
}

int normalizeAppCalendarBarOccupyPrt(int prt) => math.max(
    math.min(prt, appCalendarBarMaxOccupyPrt), appCalendarBarMinOccupyPrt);

T clamp<T extends Comparable<T>>(T value, {T? min, T? max}) {
  if (min != null && value.compareTo(min) < 0) {
    return min;
  } else if (max != null && value.compareTo(max) > 0) {
    return max;
  } else {
    return value;
  }
}

T clampInt<T extends int>(T value, {T? min, T? max}) {
  if (min != null && value.compareTo(min) < 0) {
    return min;
  } else if (max != null && value.compareTo(max) > 0) {
    return max;
  } else {
    return value;
  }
}

LogLevel getDefaultLogLevel() {
  if (kDebugMode) {
    return LogLevel.debug;
  } else if (kProfileMode) {
    return LogLevel.info;
  } else if (kReleaseMode) {
    return LogLevel.warn;
  } else {
    return LogLevel.debug;
  }
}

T stampDateTime<T extends DateTime>(T t, {required T max, required T min}) {
  t = t > max ? max : t;
  t = t < min ? min : t;
  return t;
}
