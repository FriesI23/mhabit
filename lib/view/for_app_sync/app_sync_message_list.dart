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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/counter.dart';
import '../../model/app_sync_task.dart';
import '../../provider/app_sync.dart';

class AppSyncMessageSliverList extends StatelessWidget {
  const AppSyncMessageSliverList({super.key});

  @override
  Widget build(BuildContext context) =>
      Selector<AppSyncViewModel, AppSyncContainer?>(
        selector: (context, vm) => vm.appSyncTask.task,
        shouldRebuild: (previous, next) => previous?.id != next?.id,
        builder: (context, container, child) {
          return switch (container?.task) {
            WebDavAppSyncTask() => AppSyncWebdavMessageSliverList(
                task: container?.task as WebDavAppSyncTask,
                startTime: container?.startTime),
            _ => const SliverToBoxAdapter(child: SizedBox()),
          };
        },
      );
}

class AppSyncMessageListCell {
  WebDavProgressStatusMessage message;

  AppSyncMessageListCell(this.message);

  int get level => message.level;

  WebDavProgressStatusMessageType get type => message.type;

  WebDavProgressStatusMessageStatus get status => message.status;
}

class AppSyncWebdavMessageSliverList extends StatefulWidget {
  final WebDavAppSyncTask task;
  final DateTime? startTime;

  const AppSyncWebdavMessageSliverList(
      {super.key, required this.task, this.startTime});

  @override
  State<AppSyncWebdavMessageSliverList> createState() =>
      _AppSyncWebdavMessageSliverList();
}

class _AppSyncWebdavMessageSliverList
    extends State<AppSyncWebdavMessageSliverList> {
  final GlobalKey _listKey = GlobalKey();
  final LinkedHashMap<String, AppSyncMessageListCell> _dataMap =
      LinkedHashMap();
  final Counter<WebDavAppSyncTaskResultStatus?> _habitCounter = Counter();

  late final DateTime startTime;

  @override
  void initState() {
    startTime = (widget.startTime ?? DateTime.now()).toLocal();
    super.initState();
  }

  _AppSyncWebdavMessageSliverList();

  Widget buildList(BuildContext contex, {bool isDone = false}) {
    final count = 1 + _dataMap.length + (isDone ? 1 : 0);
    final cellList = _dataMap.values.toList();
    final lastIndex = count - 1;
    return SliverList.builder(
      key: _listKey,
      itemCount: count,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Text("Waiting for task starting..."),
            subtitle: Text("Start at: ${startTime.toIso8601String()}."),
            dense: true,
          );
        } else if (isDone && index == lastIndex) {
          return ListTile(
            title: Text("Task complete"),
            subtitle: Text("End at: ${DateTime.now().toIso8601String()}"),
            dense: true,
          );
        } else {
          // TODO: indev
          final cell = cellList[index - 1];
          return ListTile(
            title: Text("index: $index"),
            subtitle: Text(
                "${cell.level} - ${cell.status} - ${cell.type} - $_habitCounter"),
            dense: true,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final progressController = task.progressController;
    return StreamBuilder(
      initialData: AppSyncMessageListCell(task.progressMessageBuilder.init()),
      stream: progressController?.replayMessageStream.map((message) {
        switch (message.type) {
          case WebDavProgressStatusMessageType.habitCount:
            if (message.status == WebDavProgressStatusMessageStatus.init) {
              _habitCounter.increase(
                  null, message.data is int ? message.data : 1);
            }
            final data = message.data;
            switch (data) {
              case WebDavAppSyncTaskResult():
                _habitCounter.increase(data.status);
            }
          default:
            if (_dataMap.containsKey(message.id)) {
              _dataMap[message.id]!.message = message;
            } else {
              _dataMap[message.id] = AppSyncMessageListCell(message);
            }
        }
      }),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const SliverToBoxAdapter(child: SizedBox());
          case ConnectionState.waiting:
          case ConnectionState.active:
            return buildList(context);
          case ConnectionState.done:
            return buildList(context, isDone: true);
        }
      },
    );
  }
}
