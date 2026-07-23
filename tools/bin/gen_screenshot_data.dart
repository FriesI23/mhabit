// Copyright 2026 Fries_I23
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

/// Generates seed JSON files for mhabit screenshot data.
///
/// Usage:
///   dart run tools/bin/gen_screenshot_data.dart --all-langs --no-repeat
///   dart run tools/bin/gen_screenshot_data.dart --count 100 --no-repeat
///   dart run tools/bin/gen_screenshot_data.dart --seed s05
///
/// Pipeline: YAML -> Config -> Args -> Map -> Reduce -> Result -> JSON
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

const _oneDayMs = 24 * 60 * 60 * 1000;
int _epochDay(DateTime d) => d.millisecondsSinceEpoch ~/ _oneDayMs;

enum RecordStrategy {
  curveUp,
  curveDown,
  consistent85,
  consistent90,
  consistent80,
  improving5080,
  improving4080,
  variable70,
  sporadic30,
  recent95;

  static RecordStrategy parse(String s) => switch (s) {
    'curve_up' => curveUp,
    'curve_down' => curveDown,
    'consistent_85' => consistent85,
    'consistent_90' => consistent90,
    'consistent_80' => consistent80,
    'improving_5080' => improving5080,
    'improving_4080' => improving4080,
    'variable_70' => variable70,
    'sporadic_30' => sporadic30,
    'recent_95' => recent95,
    _ => throw ArgumentError('Unknown strategy: $s'),
  };
}

final class LocaleText {
  final String name;
  final String desc;
  const LocaleText({required this.name, required this.desc});
}

final class GroupSpec {
  final String uuid;
  final int color;
  final int icon;
  final double? weight;
  final Map<String, LocaleText> locales;
  const GroupSpec({
    required this.uuid,
    required this.color,
    required this.icon,
    this.weight,
    required this.locales,
  });
}

final class HabitSpec {
  final int type;
  final int color;
  final num dailyGoal;
  final String dailyGoalUnit;
  final int targetDays;
  final int daysBack;
  final RecordStrategy strategy;
  final String groupUuid;
  final Map<String, LocaleText> locales;
  const HabitSpec({
    required this.type,
    required this.color,
    required this.dailyGoal,
    required this.dailyGoalUnit,
    required this.targetDays,
    required this.daysBack,
    required this.strategy,
    required this.groupUuid,
    required this.locales,
  });
}

final class SelectionSpec {
  final int habits;
  final int groups;
  const SelectionSpec({required this.habits, required this.groups});
}

final class ScreenshotConfig {
  final int defaultSeed;
  final Map<String, int> seedPresets;
  final SelectionSpec selection;
  final List<GroupSpec> groups;
  final List<HabitSpec> habits;
  const ScreenshotConfig({
    required this.defaultSeed,
    required this.seedPresets,
    required this.selection,
    required this.groups,
    required this.habits,
  });
}

final class CliArgs {
  final String configPath;
  final String outDir;
  final List<String> langs;
  final List<int> seeds;
  final bool noRepeat;
  final bool explicitSeed;
  const CliArgs({
    required this.configPath,
    required this.outDir,
    required this.langs,
    required this.seeds,
    required this.noRepeat,
    required this.explicitSeed,
  });
}

final class GeneratedRecord {
  final int recordDate;
  final int recordType;
  final num recordValue;
  final int createT;
  final int modifyT;
  const GeneratedRecord({
    required this.recordDate,
    required this.recordType,
    required this.recordValue,
    required this.createT,
    required this.modifyT,
  });
  Map<String, dynamic> toJson() => {
    'record_date': recordDate,
    'record_type': recordType,
    'record_value': recordValue,
    'create_t': createT,
    'modify_t': modifyT,
  };
}

final class GeneratedHabit {
  final int type;
  final String name;
  final String desc;
  final int color;
  final num dailyGoal;
  final String dailyGoalUnit;
  final int startDate;
  final int targetDays;
  final String groupId;
  final List<GeneratedRecord> records;
  const GeneratedHabit({
    required this.type,
    required this.name,
    required this.desc,
    required this.color,
    required this.dailyGoal,
    required this.dailyGoalUnit,
    required this.startDate,
    required this.targetDays,
    required this.groupId,
    required this.records,
  });
  Map<String, dynamic> toJson() => {
    'type': type,
    'status': 1,
    'name': name,
    'desc': desc,
    'color': color,
    'custom_color': null,
    'custom_color_tinted': null,
    'daily_goal': dailyGoal,
    'daily_goal_unit': dailyGoalUnit,
    'daily_goal_extra': null,
    'freq_type': 3,
    'freq_custom': '[1,1]',
    'reminder': null,
    'reminder_quest': null,
    'start_date': startDate,
    'target_days': targetDays,
    'group_id': groupId,
    'records': records.map((r) => r.toJson()).toList(),
  };
}

final class GeneratedGroup {
  final String uuid;
  final String name;
  final String desc;
  final int icon;
  final int color;
  const GeneratedGroup({
    required this.uuid,
    required this.name,
    required this.desc,
    required this.icon,
    required this.color,
  });
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'desc': desc,
    'icon': icon,
    'color': color,
    'custom_color': null,
    'custom_color_tinted': null,
  };
}

final class GenerationOutput {
  final String lang;
  final int seed;
  final List<GeneratedGroup> groups;
  final List<GeneratedHabit> habits;
  const GenerationOutput({
    required this.lang,
    required this.seed,
    required this.groups,
    required this.habits,
  });
  Map<String, Object?> toJson() => {
    'habits': habits.map((h) => h.toJson()).toList(),
    'groups': groups.map((g) => g.toJson()).toList(),
  };
  int get totalRecords => habits.fold(0, (s, h) => s + h.records.length);
}

dynamic _deepConvert(dynamic node) {
  if (node is Map) {
    return node.map((k, v) => MapEntry(k.toString(), _deepConvert(v)));
  }
  if (node is List) return node.map(_deepConvert).toList();
  return node;
}

LocaleText _parseLocaleText(dynamic node) {
  final m = node as Map<String, dynamic>;
  return LocaleText(name: m['name'] as String, desc: m['desc'] as String);
}

Map<String, LocaleText> _parseLocales(dynamic node) {
  final m = node as Map<String, dynamic>;
  return {
    for (final e in m.entries.where((e) => e.value is Map))
      e.key: _parseLocaleText(e.value),
  };
}

GroupSpec _parseGroup(dynamic node) {
  final m = node as Map<String, dynamic>;
  return GroupSpec(
    uuid: m['uuid'] as String,
    color: m['color'] as int,
    icon: m['icon'] as int,
    weight: (m['weight'] as num?)?.toDouble(),
    locales: _parseLocales(m),
  );
}

HabitSpec _parseHabit(dynamic node) {
  final m = node as Map<String, dynamic>;
  return HabitSpec(
    type: m['type'] as int,
    color: m['color'] as int,
    dailyGoal: m['daily_goal'] as num,
    dailyGoalUnit: m['daily_goal_unit'] as String,
    targetDays: m['target_days'] as int,
    daysBack: m['days_back'] as int,
    strategy: RecordStrategy.parse(m['strategy'] as String),
    groupUuid: m['group_uuid'] as String,
    locales: _parseLocales(m),
  );
}

ScreenshotConfig _loadConfig(String configPath) {
  final file = File(configPath);
  if (!file.existsSync()) {
    stderr.writeln('Config not found: $configPath');
    exit(1);
  }
  final yaml = loadYaml(file.readAsStringSync());
  if (yaml is! Map) {
    stderr.writeln('Config must be a YAML mapping.');
    exit(1);
  }
  final raw = _deepConvert(yaml) as Map<String, dynamic>;

  final seedMap = <String, int>{};
  final seeds = raw['seeds'];
  if (seeds is Map) {
    for (final e in seeds.entries) {
      if (e.value is int) seedMap[e.key.toString()] = e.value as int;
    }
  }
  final sel = raw['selection'] as Map<String, dynamic>?;
  final groupsRaw = raw['groups'];
  final groups = groupsRaw is List
      ? groupsRaw.map(_parseGroup).toList()
      : <GroupSpec>[];
  final habitsRaw = raw['habits'];
  final habits = habitsRaw is List
      ? habitsRaw.map(_parseHabit).toList()
      : <HabitSpec>[];
  return ScreenshotConfig(
    defaultSeed: (raw['seed'] as int?) ?? 42,
    seedPresets: seedMap,
    selection: SelectionSpec(
      habits: (sel?['habits'] as int?) ?? 0,
      groups: (sel?['groups'] as int?) ?? 0,
    ),
    groups: groups,
    habits: habits,
  );
}

CliArgs _parseArgs(List<String> args, ScreenshotConfig config) {
  final parser = ArgParser()
    ..addOption('langs', defaultsTo: 'en')
    ..addFlag('all-langs')
    ..addFlag('no-repeat')
    ..addOption('config', defaultsTo: 'tools/config/screenshot_seed.yaml')
    ..addOption('out-dir', defaultsTo: 'temp/gen_screenshot')
    ..addOption('seed')
    ..addOption('count', help: 'Generate for seeds 0..N-1 (overrides --seed).');
  final opts = parser.parse(args);

  (int, bool) resolveSeed(String? arg) {
    if (arg == null || arg.isEmpty) return (Random().nextInt(999999), false);
    final parsed = int.tryParse(arg);
    if (parsed != null) return (parsed, true);
    final named = config.seedPresets[arg];
    if (named != null) return (named, true);
    stderr.writeln('Unknown seed "$arg", using random.');
    return (Random().nextInt(999999), false);
  }

  var explicitSeed = false;

  List<int> resolveSeeds() {
    final countArg = opts['count'] as String?;
    if (countArg != null) {
      final n = int.tryParse(countArg);
      if (n != null && n > 0) return List.generate(n, (i) => i);
    }
    final (seed, explicit) = resolveSeed(opts['seed'] as String?);
    explicitSeed = explicit;
    return [seed];
  }

  Set<String> detectLangs() {
    final langs = <String>{};
    for (final g in config.groups) {
      langs.addAll(g.locales.keys);
    }
    return langs;
  }

  List<String> resolveLangs() {
    if (opts['all-langs'] as bool) return detectLangs().toList()..sort();
    return (opts['langs'] as String)
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  final langs = resolveLangs();
  if (langs.isEmpty) {
    stderr.writeln('No languages. Use --langs or --all-langs.');
    exit(1);
  }

  return CliArgs(
    configPath: opts['config'] as String,
    outDir: opts['out-dir'] as String,
    langs: langs,
    seeds: resolveSeeds(),
    noRepeat: opts['no-repeat'] as bool,
    explicitSeed: explicitSeed,
  );
}

final class GenerationRequest {
  final ScreenshotConfig config;
  final CliArgs args;
  final int todayEpoch;
  final int seed;
  final String lang;
  final List<GroupSpec> groups;
  final List<HabitSpec> habits;
  const GenerationRequest({
    required this.config,
    required this.args,
    required this.todayEpoch,
    required this.seed,
    required this.lang,
    required this.groups,
    required this.habits,
  });
}

/// Reproducibly selects [count] indices from [0, total) using a seed.
/// Same seed always produces the same subset — different seeds diverge.
List<int> _deterministicPick(int seed, int total, int count) {
  if (count >= total) return List.generate(total, (i) => i);
  final rng = Random(seed);
  final indices = List.generate(total, (i) => i);
  indices.shuffle(rng);
  return indices.take(count).toList()..sort();
}

/// Generates weights from a standard normal distribution centred on the
/// middle index, so that central groups are favoured over edge groups.
List<double> _normalWeights(int count) {
  final mid = (count - 1) / 2.0;
  final sigma = count / 3.0;
  return List.generate(count, (i) {
    final x = (i - mid) / sigma;
    return exp(-x * x / 2);
  });
}

/// Like [_deterministicPick] but each index is weighted by [weights].
/// Higher weight → higher chance of being selected. Still deterministic
/// for a given seed.
List<int> _weightedPick(int seed, int total, int count, List<double> weights) {
  if (count >= total) return List.generate(total, (i) => i);
  final rng = Random(seed);
  final scores = List.generate(total, (i) => rng.nextDouble() * weights[i]);
  final sorted = List.generate(total, (i) => i)
    ..sort((a, b) => scores[b].compareTo(scores[a]));
  return sorted.take(count).toList()..sort();
}

Iterable<GenerationRequest> _buildRequests(
  ScreenshotConfig config,
  CliArgs args,
  int todayEpoch,
  int seed,
) sync* {
  for (final lang in args.langs) {
    List<GroupSpec> groupList = config.groups;
    List<HabitSpec> habitList = config.habits;

    if (args.noRepeat) {
      final normal = _normalWeights(config.groups.length);
      final weights = List.generate(config.groups.length, (i) {
        final w = config.groups[i].weight ?? 1.0;
        return w * normal[i];
      });
      final gp = _weightedPick(
        seed,
        config.groups.length,
        config.selection.groups,
        weights,
      );
      groupList = gp.map((i) => config.groups[i]).toList();
      final selectedUuids = groupList.map((g) => g.uuid).toSet();

      final eligible = <int>[];
      for (var i = 0; i < config.habits.length; i++) {
        if (selectedUuids.contains(config.habits[i].groupUuid)) eligible.add(i);
      }
      final count = config.selection.habits < eligible.length
          ? config.selection.habits
          : eligible.length;
      final hp = _deterministicPick(seed + 1, eligible.length, count);
      habitList = hp.map((i) => config.habits[eligible[i]]).toList();
    }

    yield GenerationRequest(
      config: config,
      args: args,
      todayEpoch: todayEpoch,
      seed: seed,
      lang: lang,
      groups: groupList,
      habits: habitList,
    );
  }
}

/// Logistic (sigmoid) curve: S-shaped probability from 0 -> 1.
/// [k] controls steepness — larger values produce sharper transitions.
/// [midFrac] sets the inflection point as a fraction of [totalDays].
double _logisticP(
  int dayIndex,
  int totalDays, {
  required double k,
  required double midFrac,
}) {
  final x = k * (dayIndex - totalDays * midFrac);
  return 1.0 / (1.0 + exp(-x));
}

/// Base probability (before noise) that a habit is completed on a given day.
/// Each strategy maps to either a constant probability or a logistic curve
/// tuned for a specific behavioural pattern.
double _strategyProbability(int dayIndex, int totalDays, RecordStrategy s) =>
    switch (s) {
      RecordStrategy.curveUp => _logisticP(
        dayIndex,
        totalDays,
        k: 0.06,
        midFrac: 0.35,
      ),
      RecordStrategy.curveDown => _logisticP(
        dayIndex,
        totalDays,
        k: 0.06,
        midFrac: 0.35,
      ),
      RecordStrategy.consistent85 => 0.85,
      RecordStrategy.consistent90 => 0.90,
      RecordStrategy.consistent80 => 0.80,
      RecordStrategy.improving5080 => _logisticP(
        dayIndex,
        totalDays,
        k: 0.08,
        midFrac: 0.50,
      ),
      RecordStrategy.improving4080 => _logisticP(
        dayIndex,
        totalDays,
        k: 0.10,
        midFrac: 0.50,
      ),
      RecordStrategy.variable70 => 0.70,
      RecordStrategy.sporadic30 => 0.30,
      RecordStrategy.recent95 => 0.95,
    };

List<GeneratedRecord> _genRecords({
  required int startEpochDay,
  required int todayEpoch,
  required RecordStrategy strategy,
  required num recordValue,
  required Random rng,
}) {
  final records = <GeneratedRecord>[];
  final totalDays = todayEpoch - startEpochDay + 1;
  for (var i = 0; i < totalDays; i++) {
    final dateEpoch = startEpochDay + i;
    var p = _strategyProbability(i, totalDays, strategy);
    // Add uniform noise +/- 0.08 so "consistent" strategies get occasional
    // gaps and "sporadic" ones get occasional hits. Clamp away from [0, 1]
    // so every day has at least a tiny chance of flipping.
    p += (rng.nextDouble() - 0.5) * 0.16;
    p = p.clamp(0.02, 0.98);
    if (rng.nextDouble() < p) {
      final ts = dateEpoch * _oneDayMs + 43200000;
      records.add(
        GeneratedRecord(
          recordDate: dateEpoch,
          recordType: 1,
          recordValue: recordValue,
          createT: ts,
          modifyT: ts,
        ),
      );
    }
  }
  return records;
}

String _localeStr(
  Map<String, LocaleText> locales,
  String lang, {
  String fallback = 'en',
}) {
  return (locales[lang] ?? locales[fallback])?.name ?? '';
}

String _localeDesc(
  Map<String, LocaleText> locales,
  String lang, {
  String fallback = 'en',
}) {
  return (locales[lang] ?? locales[fallback])?.desc ?? '';
}

GenerationOutput _generate(GenerationRequest req) {
  final rng = Random(req.seed);
  final groups = <GeneratedGroup>[];
  for (final g in req.groups) {
    groups.add(
      GeneratedGroup(
        uuid: g.uuid,
        name: _localeStr(g.locales, req.lang),
        desc: _localeDesc(g.locales, req.lang),
        icon: g.icon,
        color: g.color,
      ),
    );
  }

  final activeUuids = groups.map((g) => g.uuid).toSet();
  final habits = <GeneratedHabit>[];
  for (final h in req.habits) {
    if (!activeUuids.contains(h.groupUuid)) continue;
    final startEpochDay = req.todayEpoch - h.daysBack;
    final records = _genRecords(
      startEpochDay: startEpochDay,
      todayEpoch: req.todayEpoch,
      strategy: h.strategy,
      recordValue: h.dailyGoal,
      rng: rng,
    );
    habits.add(
      GeneratedHabit(
        type: h.type,
        name: _localeStr(h.locales, req.lang),
        desc: _localeDesc(h.locales, req.lang),
        color: h.color,
        dailyGoal: h.dailyGoal,
        dailyGoalUnit: h.dailyGoalUnit,
        startDate: startEpochDay,
        targetDays: h.targetDays,
        groupId: h.groupUuid,
        records: records,
      ),
    );
  }

  return GenerationOutput(
    lang: req.lang,
    seed: req.seed,
    groups: groups,
    habits: habits,
  );
}

void _writeOutput(GenerationOutput output, CliArgs args, int seed) {
  final dir = Directory(args.outDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final multiSeed = args.seeds.length > 1;
  final suffix = (multiSeed || args.explicitSeed) ? '_seed$seed' : '';
  final path = '${dir.path}/screenshot_seed_${output.lang}$suffix.json';
  File(path).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(output.toJson()),
  );

  final stats = output.habits
      .map((h) => '${h.name}: ${h.records.length}')
      .join(', ');
  stdout.writeln(
    '[${output.lang}] seed=$seed -> $path  (${output.habits.length} habits, ${output.groups.length} groups, ${output.totalRecords} recs: $stats)',
  );
}

void main(List<String> args) {
  final config = _loadConfig('tools/config/screenshot_seed.yaml');
  final cli = _parseArgs(args, config);
  final todayEpoch = _epochDay(DateTime.now());

  var generated = 0;
  for (final seed in cli.seeds) {
    final requests = _buildRequests(config, cli, todayEpoch, seed).toList();
    for (final req in requests) {
      final output = _generate(req);
      _writeOutput(output, cli, seed);
      generated++;
    }
  }
  if (generated == 0) return;

  stdout.writeln('');
  stdout.writeln('Config     : ${cli.configPath}');
  stdout.writeln(
    'Seeds      : ${cli.seeds.length > 1 ? '0..${cli.seeds.length - 1}' : '${cli.seeds.first}'}',
  );
  stdout.writeln('Langs      : ${cli.langs.join(', ')}');
  stdout.writeln('No-repeat  : ${cli.noRepeat}');
  stdout.writeln('Files      : $generated');
  stdout.writeln('Today      : ${DateTime.now()} (epoch $todayEpoch)');
  stdout.writeln('Output dir : ${cli.outDir}');
}
