import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get localeScriptName => 'Русский';

  @override
  String get appName => 'Таблица Привычек';

  @override
  String get habitEdit_saveButton_text => 'Сохранить';

  @override
  String get habitEdit_habitName_hintText => 'Название привычки ...';

  @override
  String get habitEdit_colorPicker_title => 'Выберете цвет';

  @override
  String get habitEdit_habitTypeDialog_title => 'Тип привычки';

  @override
  String get habitEdit_habitType_positiveText => 'Хорошая';

  @override
  String get habitEdit_habitType_negativeText => 'Вредная';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Дневная цель, по умолчанию $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Минимальный дневной порог, по умолчанию $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'дневная цель должна быть > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'дневная цель должна быть ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'дневная цель должна быть ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'дневная цель должна быть ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Единицы дневной цель';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Желаемый максимум дневная цель';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'invalid value, must be empty or ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Максимальный дневной предел';

  @override
  String get habitEdit_frequencySelector_title => 'Выберете частоту';

  @override
  String get habitEdit_habitFreq_daily => 'Ежедневно';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'раз в неделю';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'раз в месяц';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'раз в';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'дней';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Ежедневно';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Хотя бы $freq раз в неделю',
      one: 'В неделю',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Хотя бы $freq раз в месяц',
      one: 'В месяц',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Хотя бы $freq раз в каждые $days дней',
      one: 'В каждые $days дней',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays дней';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Выберете целевых дней';

  @override
  String get habitEdit_targetDays => 'дней';

  @override
  String get habitEdit_reminder_hintText => 'Напоминание';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Любой день недели';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' в любую неделю';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Любой день месяца';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' в любой месяц';

  @override
  String get habitEdit_reminderQuest_hintText => 'Вопрос, н.п. Вы занимались сегодня?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Выберете тип напоминания';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Когда нужно чекиниться';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Ежедневно';

  @override
  String get habitEdit_reminder_dialogType_week => 'Еженедельно';

  @override
  String get habitEdit_reminder_dialogType_month => 'Ежемесячно';

  @override
  String get habitEdit_reminder_dialogConfirm => 'подтвердить';

  @override
  String get habitEdit_reminder_dialogCancel => 'отмена';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Подтвердить';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Вы уверены, что хотите удалить это напоминание';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'подтвердить';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'отмена';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Пн';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Вт';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Ср';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Чт';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Пт';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Сб';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Вс';

  @override
  String get habitEdit_desc_hintText => 'Редактор, поддерживает Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Создано: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Изменено: ';

  @override
  String get habitDisplay_fab_text => 'Новая Привычка';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Путешествие в тысячу миль начинается с первого шага';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Архивировать выбранные привычки?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'подтвердить';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'отмена';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Архивировать $count привычек';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Разархивировать выбранные привычки?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'подтвердить';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'отмена';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Разархивировано $count привычек';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Удалить выбранные привычки?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'подтвердить';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'отмена';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Удалено $count привычек';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Выбрать всё';

  @override
  String get habitDisplay_editPopMenu_export => 'Экспорт';

  @override
  String get habitDisplay_editPopMenu_delete => 'Удалить';

  @override
  String get habitDisplay_editPopMenu_clone => 'Шаблон';

  @override
  String get habitDisplay_editButton_tooltip => 'Редактировать';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Архивировать';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Разархивировать';

  @override
  String get habitDisplay_settingButton_tooltip => 'Настройки';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Текущие';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Завершённые';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'В прогрессе';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Архивировано';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Топ привычек: изменения за последние 30 дней';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Светлая тема';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Тёмная тема';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Как в системе';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Показать Архивированные';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Показать Завершённые';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Показать Активные';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Настройки';

  @override
  String get habitDisplay_sort_reverseText => 'Обратная';

  @override
  String get habitDisplay_sortDirection_asc => '(Восходящая)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Нисходящая)';

  @override
  String get habitDisplay_sortType_manual => 'Свой порядок';

  @override
  String get habitDisplay_sortType_name => 'По Названию';

  @override
  String get habitDisplay_sortType_colorType => 'По цвету';

  @override
  String get habitDisplay_sortType_progress => 'По Рейту';

  @override
  String get habitDisplay_sortType_startT => 'По Дате Начала';

  @override
  String get habitDisplay_sortType_status => 'По Статусу';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Сортировка';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'подтвердить';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'отменить';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠 Отладка';

  @override
  String get habitDetail_editButton_tooltip => 'Редактировать';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Разархивировать';

  @override
  String get habitDetail_editPopMenu_archive => 'Архивировать';

  @override
  String get habitDetail_editPopMenu_export => 'Экспорт';

  @override
  String get habitDetail_editPopMenu_delete => 'Удалить';

  @override
  String get habitDetail_editPopMenu_clone => 'Шаблон';

  @override
  String get habitDetail_confirmDialog_confirm => 'подтвердить';

  @override
  String get habitDetail_confirmDialog_cancel => 'отмена';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Архивировать Привычку?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Разархивировать Привычку?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Удалить Привычку?';

  @override
  String get habitDetail_summary_title => 'Итоги';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Текущее достижение $score, и уже прошло $days дней со времени начала.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Начиная через $days дней.',
      one: 'Начиная с завтра.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'НЕИСКОРЕНО',
      one: 'НЕЗАКОНЧЕНО',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'БЕЗУПРЕЧНО',
      one: 'ПЕРЕВЫПОЛНЕНО',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Цель',
      two: 'Порог',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Единицы: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Дней',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'д';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Записей';

  @override
  String get habitDetail_scoreChart_title => 'Достижения';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'День';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Неделя';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Месяц';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Год';

  @override
  String get habitDetail_freqChart_freqTitle => 'Частота';

  @override
  String get habitDetail_freqChart_historyTitle => 'История';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Частота и История';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Неделя';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Месяц';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Год';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Сейчас';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Спрятать историческую диаграмму';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Показать историческую диаграмму';

  @override
  String get habitDetail_descSubgroup_title => 'Редактор';

  @override
  String get habitDetail_otherSubgroup_title => 'Другое';

  @override
  String get habitDetail_habitType_title => 'Тип';

  @override
  String get habitDetail_reminderTile_title => 'Напоминание';

  @override
  String get habitDetail_freqTile_title => 'Повторять';

  @override
  String get habitDetail_startDateTile_title => 'Дата начала';

  @override
  String get habitDetail_createDateTile_title => 'Создано';

  @override
  String get habitDetail_modifyDateTile_title => 'Изменено';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'date';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'value';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'назад к сегодня';

  @override
  String get habitDetail_notFoundText => 'Загрузка привычки не удалась';

  @override
  String get habitDetail_notFoundRetryText => 'Попробовать снова';

  @override
  String get habitDetail_changeGoal_title => 'Изменить цель';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'текущая: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'сделано: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'не сделано';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Дневная цель, по умолчанию: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'отмена';

  @override
  String get habitDetail_changeGoal_saveText => 'сохранить';

  @override
  String get habitDetail_skipReason_title => 'Причина пропуска';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Напишите что нибудь здесь...';

  @override
  String get habitDetail_skipReason_cancelText => 'отмена';

  @override
  String get habitDetail_skipReason_saveText => 'сохранить';

  @override
  String get appSetting_appbar_titleText => 'Настройки';

  @override
  String get appSetting_displaySubgroupText => 'Отобразить';

  @override
  String get appSetting_operationSubgroupText => 'Операция';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Перетаскивать календарь по странице';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Если переключатель включен, календарь панели приложений на домашней странице будет перетаскиваться по странице. По умолчанию переключатель отключен.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Изменить статус записи';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Измените поведение клика, чтобы изменить статус ежедневных записей на главной странице.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Открыть подробную запись';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Измените поведение клика, чтобы открыть подробное всплывающее окно для ежедневных записей на главной странице.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Первый день недели';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Показывать первый день недели';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (По умолчанию)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Follow System ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'Follow System';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Language';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Select Language';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Формат отображения даты ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'как в системе';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Настроенный формат даты будет применен к отображению даты на странице «Подробности привычки».';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Включить компактный интерфейс на странице привычек';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Разрешить привычки проверить таблицу для отображения большего количества контента, но некоторые пользовательские и текст могут показаться меньше.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Habits check area radio adjustment';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Adjust percentage for more/less space in habits check table area.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'По умолчанию';

  @override
  String get appSetting_reminderSubgroupText => 'Напоминание';

  @override
  String get appSetting_dailyReminder_titleText => 'Ежедневное напоминание';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Резервное копирование и восстановление';

  @override
  String get appSetting_export_titleText => 'Экспорт';

  @override
  String get appSetting_export_subtitleText => 'Привычки экспортируются в формате JSON. Этот файл можно импортировать назад.';

  @override
  String get appSetting_import_titleText => 'Импорт';

  @override
  String get appSetting_import_subtitleText => 'Импорт привычек из json файла.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Подтвердите импорт $count привычек?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Примечание: импорт не удаляет существующие привычки.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'подтвердить';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'отмена';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Импортировано $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Завершён импорт $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'закрыть';

  @override
  String get appSetting_resetConfig_titleText => 'Сбросить настройки';

  @override
  String get appSetting_resetConfig_subtitleText => 'Сбросить все настройки к значениям по умолчанию.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Сбросить настройки?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'После сброса нужно будет перезапустить приложение.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'отмена';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'подтвердить';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'настройки приложения сброшены';

  @override
  String get appSetting_otherSubgroupText => 'Другие';

  @override
  String get appSetting_developMode_titleText => 'Режим Разработчика';

  @override
  String get appSetting_clearCache_titleText => 'Очистить кэш';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Очистить кеш';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'После очистки кэша некоторые пользовательские значения будут восстановлены по умолчанию.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'отмена';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'подтвердить';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Не удалось частично очистить кэш';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Кэш очищен';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Не удалось очистить кэш';

  @override
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'О приложении';

  @override
  String get appSetting_experimentalFeatureTile_titleText => 'Experimental Features';

  @override
  String get appSetting_synSubgroupText => 'Sync';

  @override
  String get appSetting_syncOption_titleText => 'Sync Options';

  @override
  String get appSync_nowTile_titleText => 'Sync Now';

  @override
  String get appSync_nowTile_titleText_syncing => 'Syncing';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'Last Sync: N/A';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Last Sync: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate => 'Last Sync (Error): N/A';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Last Sync (Error): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Syncing...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat = intl.NumberFormat.decimalPercentPattern(
      locale: localeName,
      decimalDigits: 2
    );
    final String prtString = prtNumberFormat.format(prt);

    return 'Syncing: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Canceling...';

  @override
  String get appSync_nowTile_cancelText_noDate => 'Last Sync (Cancelled): N/A';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Last Sync (Cancelled): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Check Failure Logs';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Error]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'success': 'Completed',
        'cancelled': 'Canceled',
        'failed': 'Failed',
        'multi': 'Multiple statuses',
        'other': 'Unknown status',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'success': 'Completed due to $reason',
        'cancelled': 'Canceled due to $reason',
        'failed': 'Failed due to $reason',
        'multi': 'Multiple statuses due to $reason',
        'other': 'Unknown status',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(
      reason,
      {
        'error': 'Error',
        'userAction': 'User action required',
        'missingHabitUuid': 'Missing habit UUID',
        'empty': 'Empty data',
        'other': 'Unknown reason',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'New Location';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText => 'Syncing will create necessary directories and upload local habits to the server. Continue?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText => 'Sync Now!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText => 'Confirm Sync';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText => 'Directory isn\'t empty. Syncing will merge server and local habits. Continue?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText => 'Confirm Merge';

  @override
  String get appSync_exportAllLogsTile_titleText => 'Export Failed Sync Logs';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': 'No log founded',
        'false': 'Tap to export',
        'other': 'loading...',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(
      isCurrent,
      {
        'true': 'Current: ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      name,
      {
        'webdav': 'WebDAV',
        'fake': 'Fake (Only For Debugger)',
        'other': 'Unknown ($name)',
      },
    );
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'mobile': 'Mobile',
        'wifi': 'Wifi',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_summaryTile_title => 'Sync Server';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured => 'Not Configured';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText => 'All recent failed sync logs';

  @override
  String get appSync_serverEditor_saveDialog_titleText => 'Confirm Save Changes';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText => 'Saving will overwrite previous server configuration.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'Unsaved Changes';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText => 'Exiting will discard all unsaved changes.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Confirm Delete';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText => 'Deleting will remove current server config.';

  @override
  String get appSync_serverEditor_titleText_add => 'New Sync Server';

  @override
  String get appSync_serverEditor_titleText_modify => 'Modify Sync Server';

  @override
  String get appSync_serverEditor_advance_titleText => 'Advanced Configs';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Path';

  @override
  String get appSync_serverEditor_pathTile_hintText => 'Enter a valid WebDAV path here.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath => 'Path shouldn\'t be empty!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Username';

  @override
  String get appSync_serverEditor_usernameTile_hintText => 'Enter username here, leave empty if not required.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Password';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText => 'Ignore SSL Certificate';

  @override
  String get appSync_serverEditor_timeoutTile_titleText => 'Sync Timeout Seconds';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Infinite',
    );
    return 'Default: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText => 'Network Connection Timeout Seconds';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Infinite',
    );
    return 'Default: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText => 'Network Connection Retry Count';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Retry disabled',
    );
    return 'Default: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText => 'Network Sync Mode';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'mobile': 'Sync on Cellular Network',
        'wifi': 'Sync on Wifi',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'LowData';

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip => 'Sync in Low Data Mode';

  @override
  String get experimentalFeatures_warnginBanner_title => 'One or more experimental features are enabled, Use with caution.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText => 'Habit Cloud Sync';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText => 'Once enabled, the app\'s sync option will appear in settings';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Experimental feature ($syncName) is disabled, but the function is still running.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'To completely disable, long press to access \'$menuName\' and turn it off.';
  }

  @override
  String get appAbout_appbarTile_titleText => 'О приложении';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Версия: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Исходный код';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Баг трекер';

  @override
  String get appAbout_contactEmailTile_titleText => 'Написать мне';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Лицензия';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Third Party Licensing Statement';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Пожертвовать';

  @override
  String get appAbout_donateTile_subTitleText => 'Я индивидуальный разработчик. Если вам нравится это приложение, купите мне ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Buy me a coffee';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Crypto Currencies';

  @override
  String get donateWay_cryptoCurrency_BTC => 'BTC';

  @override
  String get donateWay_cryptoCurrency_ETH => 'ETH';

  @override
  String get donateWay_cryptoCurrency_BNB => 'BNB';

  @override
  String get donateWay_cryptoCurrency_AVAX => 'AVAX';

  @override
  String get donateWay_cryptoCurrency_FTM => 'FTM';

  @override
  String get donateWay_firstQRGroup => 'Alipay & Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'Скопирован адрес $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Групповой чекин';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Предыдущий день';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Следующий день';

  @override
  String get batchCheckin_status_skip_text => 'Пропустить';

  @override
  String get batchCheckin_status_ok_text => 'Завершено';

  @override
  String get batchCheckin_status_double_text => 'x2 Hit!';

  @override
  String get batchCheckin_status_zero_text => 'Незавершенно';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habits',
      one: 'Habit',
    );
    return '$count $_temp0 selected';
  }

  @override
  String get batchCheckin_save_button_text => 'Сохранить';

  @override
  String get batchCheckin_reset_button_text => 'Сбросить';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'status of $count habits',
      one: 'habit\'s status',
    );
    return 'Modified $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'Overwrite Existing Records';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Existing records will be overwritten After saving, previous records will be lost.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'сохранить';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'отмена';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirm Return';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Check-in Status Changes won\'t be applied before saved';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'выход';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'отмена';

  @override
  String get appReminder_dailyReminder_title => '🏝 Вы сегодня придерживались своих привычек?';

  @override
  String get appReminder_dailyReminder_body => 'Нажмите чтобы войти в приложение и вписаться вовремя.';

  @override
  String get common_habitColorType_cc1 => 'Deep lilac';

  @override
  String get common_habitColorType_cc2 => 'Red';

  @override
  String get common_habitColorType_cc3 => 'Purple';

  @override
  String get common_habitColorType_cc4 => 'Royal blue';

  @override
  String get common_habitColorType_cc5 => 'Dark cyan';

  @override
  String get common_habitColorType_cc6 => 'Green';

  @override
  String get common_habitColorType_cc7 => 'Amber';

  @override
  String get common_habitColorType_cc8 => 'Orange';

  @override
  String get common_habitColorType_cc9 => 'Lime green';

  @override
  String get common_habitColorType_cc10 => 'Dark orchid';

  @override
  String common_habitColorType_default(int index) {
    return 'Цвет $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Использовать системный формат';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Формат даты';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Год Месяц День';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Месяц День Год';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'День Month Год';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Разделитель';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Минус';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Слэш';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Пробел';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Точка';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Без разделителя';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Использовать 12ти часовой формат';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Использовать полное название';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Применить для Диаграммы Частоты';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Применить для Календаря';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'отмена';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'подтвердить';

  @override
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

  @override
  String get calendarPicker_clip_today => 'Сегодня';

  @override
  String get calendarPicker_clip_tomorrow => 'Завтра';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Следующий $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Экспортировать все привычки?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number habits',
      one: '1 habit',
      zero: 'current habit',
    );
    return 'Экспорт $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'включая записи';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'отмена';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'export';

  @override
  String get debug_logLevelTile_title => 'Logging Level';

  @override
  String get debug_logLevelDialog_title => 'Change Logging Level';

  @override
  String get debug_logLevel_debug => 'Debug';

  @override
  String get debug_logLevel_info => 'Info';

  @override
  String get debug_logLevel_warn => 'Warning';

  @override
  String get debug_logLevel_error => 'Error';

  @override
  String get debug_logLevel_fatal => 'Fatal';

  @override
  String get debug_collectLogTile_title => 'Collecting Logs';

  @override
  String get debug_collectLogTile_enable_subtitle => 'Tap to stop logging collection.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Tap to start logging collection.';

  @override
  String get debug_downladDebugLogs_subject => 'Downloading debugging logs';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Debugging logs Cleared.';

  @override
  String get debug_downladDebugInfo_subject => 'Downloading debugging information';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Downloading $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Debug log doesn\'t exist.';

  @override
  String get debug_debuggerLogCard_title => 'Logging Information';

  @override
  String get debug_debuggerLogCard_subtitle => 'Includes local debugging log information, need to turn on the log collection switcher.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Download';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Clear';

  @override
  String get debug_debuggerInfoCard_title => 'Debugging Information';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Includes app\'s debugging information.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Open';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Save';

  @override
  String get debug_debuggerInfo_notificationTitle => 'Collecting App\'s Info...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'save': 'Save',
        'exit': 'Exit',
        'delete': 'Delete',
        'other': 'Confirm',
      },
    );
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'Cancel';

  @override
  String get snackbar_undoText => 'UNDO';

  @override
  String get snackbar_dismissText => 'DISMISS';

  @override
  String get contributors_tile_title => 'Авторы';

  @override
  String get userAction_tap => 'Tap';

  @override
  String get userAction_doubleTap => 'Double';

  @override
  String get userAction_longTap => 'Long';
}
