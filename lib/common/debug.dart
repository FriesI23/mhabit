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

import 'dart:math';

class DebugHabitMeta {
  final String name;
  final num goal;
  final String desc;
  final String goalUnit;

  const DebugHabitMeta({
    required this.name,
    required this.goal,
    this.desc = '',
    this.goalUnit = '',
  });
}

const _debugHabitMetaList = [
  DebugHabitMeta(
    name: "Drink a glass of water",
    goal: 1,
    desc: "Drink a full glass of water to hydrate your body.",
    goalUnit: "glass",
  ),
  DebugHabitMeta(
    name: "Take a deep breath",
    goal: 1,
    desc: "Take a slow and deep breath to calm your mind and body.",
  ),
  DebugHabitMeta(
    name: "Stretch for 5 seconds",
    goal: 5,
    desc: "Stretch your body for 5 seconds to relieve muscle tension.",
    goalUnit: "seconds",
  ),
  DebugHabitMeta(
    name: "Do 1 push-up",
    goal: 1,
    desc: "Do 1 push-up to strengthen your upper body.",
  ),
  DebugHabitMeta(
    name: "Read a page of a book",
    goal: 1,
    desc: "Read a page of a book to stimulate your mind.",
    goalUnit: "page",
  ),
  DebugHabitMeta(
    name: "Write a sentence in a journal",
    goal: 1,
    desc: "Write down a sentence in a journal to reflect on your day.",
    goalUnit: "sentence",
  ),
  DebugHabitMeta(
    name: "Meditate for 1 minute",
    goal: 1,
    desc: "Meditate for 1 minute to calm your mind and reduce stress.",
    goalUnit: "minute",
  ),
  DebugHabitMeta(
    name: "Do 1 minute of plank",
    goal: 1,
    desc: "Hold a plank position for 1 minute to strengthen your core.",
    goalUnit: "minute",
  ),
  DebugHabitMeta(
    name: "Stand up and stretch",
    goal: 1,
    desc:
        "Stand up and stretch your body "
        "to improve circulation and flexibility.",
  ),
  DebugHabitMeta(
    name: "Floss one tooth",
    goal: 1,
    desc: "Floss one tooth to maintain oral hygiene.",
    goalUnit: "tooth",
  ),
  DebugHabitMeta(
    name: "Do 10 jumping jacks",
    goal: 10,
    desc: "Do 10 jumping jacks to improve cardiovascular fitness.",
    goalUnit: "jumping jack",
  ),
  DebugHabitMeta(
    name: "Eat a piece of fruit",
    goal: 1,
    desc:
        "Eat a piece of fruit to provide your body "
        "with essential vitamins and nutrients.",
    goalUnit: "piece",
  ),
  DebugHabitMeta(
    name: "Compliment someone",
    goal: 1,
    desc: "Compliment someone to spread positivity and kindness.",
  ),
  DebugHabitMeta(
    name: "Listen to 1 song",
    goal: 1,
    desc: "Listen to 1 song to improve your mood and reduce stress.",
    goalUnit: "song",
  ),
  DebugHabitMeta(
    name: "Clean up one small area",
    goal: 1,
    desc:
        "Clean up one small area "
        "to create a more organized and stress-free environment.",
    goalUnit: "area",
  ),
  DebugHabitMeta(
    name: "Take a 5-minute walk",
    goal: 5,
    desc: "Take a brisk walk around your neighborhood for 5 minutes",
    goalUnit: "minutes",
  ),
  DebugHabitMeta(
    name: "Do 1 minute of squats",
    goal: 1,
    desc: "Perform squats for 1 minute, focusing on proper form",
    goalUnit: "minutes",
  ),
  DebugHabitMeta(
    name: "Say a positive affirmation",
    goal: 1,
    desc: "Speak out loud a positive statement or mantra that inspires you",
    goalUnit: "times",
  ),
  DebugHabitMeta(
    name: "Do 1 minute of lunges",
    goal: 1,
    desc: "Perform lunges for 1 minute, alternating legs",
    goalUnit: "minutes",
  ),
  DebugHabitMeta(
    name: "Write down 1 thing you're grateful for",
    goal: 1,
    desc:
        "Take a moment to reflect on something in your life "
        "that you're thankful for, and write it down",
    goalUnit: "things",
  ),
];

DebugHabitMeta debugGetRandomHabitMeta(Random? rnd) {
  return _debugHabitMetaList[(rnd ?? Random()).nextInt(
    _debugHabitMetaList.length,
  )];
}
