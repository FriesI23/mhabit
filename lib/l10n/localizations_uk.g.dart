import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class L10nUk extends L10n {
  L10nUk([String locale = 'uk']) : super(locale);

  @override
  String get localeScriptName => 'Українська';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Зберегти';

  @override
  String get habitEdit_habitName_hintText => 'Назва звички...';

  @override
  String get habitEdit_colorPicker_title => 'Оберіть колір';

  @override
  String get habitEdit_habitTypeDialog_title => 'Тип звички';

  @override
  String get habitEdit_habitType_positiveText => 'Позитивна';

  @override
  String get habitEdit_habitType_negativeText => 'Негативна';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Щоденна мета, за замовчуванням $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Мінімальний щоденний поріг, за умовчанням $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'щоденна мета повинна > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'щоденна мета повинна бути ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'щоденна ціль має бути ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'щоденна мета повинна бути ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Одиниці вимірювання щоденної мети';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Бажана максимальна щоденна мета';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'введене значення має бути порожнім або ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Максимальне щоденне обмеження';

  @override
  String get habitEdit_frequencySelector_title => 'Оберіть частоту';

  @override
  String get habitEdit_habitFreq_daily => 'Щоденно';

  @override
  String get habitEdit_habitFreq_perweek => 'I';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'разів за тиждень';

  @override
  String get habitEdit_habitFreq_permonth => 'i';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'разів за місяць';

  @override
  String get habitEdit_habitFreq_predayfreq => 'І';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'разів за';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'днів';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Щоденно';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Щонайменше $freq разів за тиждень',
      one: 'За тиждень',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Щонайменше $freq разів за місяць',
      one: 'За місяць',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Принаймні $freq разів за кожні $days днів',
      one: 'Через кожні $days днів',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays днів';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Виберіть цільові дні';

  @override
  String get habitEdit_targetDays => 'днів';

  @override
  String get habitEdit_reminder_hintText => 'Нагадування';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Будь-який день тижня';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => 'і';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' кожного тижня';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Будь-який день місяця';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => 'I';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' в кожному місяці';

  @override
  String get habitEdit_reminderQuest_hintText => 'Питання, напр. Ви займалися спортом сьогодні?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Виберіть тип нагадування';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Коли потрібно зареєструватися';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Щодня';

  @override
  String get habitEdit_reminder_dialogType_week => 'на тиждень';

  @override
  String get habitEdit_reminder_dialogType_month => 'на місяць';

  @override
  String get habitEdit_reminder_dialogConfirm => 'підтвердити';

  @override
  String get habitEdit_reminder_dialogCancel => 'скасувати';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Підтвердити';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Ви підтверджуєте видалення цього нагадування';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'підтвердити';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'скасувати';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Пн';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Вт';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'ср';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Чт';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Пт';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Сб';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Нд';

  @override
  String get habitEdit_desc_hintText => 'Memo, підтримка Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Створено: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Змінено: ';

  @override
  String get habitDisplay_fab_text => 'Нова звичка';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Подорож у тисячу миль починається з одного кроку';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Архівувати вибрані звички?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'скасувати';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Заархівовано $count звичок';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Розархівувати вибрані звички?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'скасувати';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Розархівовано $count звичок';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Видалити вибрані звички?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'скасувати';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Видалено $count звичок';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Виберіть усі';

  @override
  String get habitDisplay_editPopMenu_export => 'Експорт';

  @override
  String get habitDisplay_editPopMenu_delete => 'Видалити';

  @override
  String get habitDisplay_editPopMenu_clone => 'Шаблон';

  @override
  String get habitDisplay_editButton_tooltip => 'Редагувати';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Архів';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Розархівувати';

  @override
  String get habitDisplay_settingButton_tooltip => 'Налаштування';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'поточний';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Виконано';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'В роботі';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Архівовано';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Головні звички: зміни за останні 30 днів';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Світла тема';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Темна тема';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Слідкуйте за системою';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Показати в архіві';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Показати завершено';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Показати активовано';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Налаштування';

  @override
  String get habitDisplay_sort_reverseText => 'Зворотний';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(опис)';

  @override
  String get habitDisplay_sortType_manual => 'Моє замовлення';

  @override
  String get habitDisplay_sortType_name => 'По імені';

  @override
  String get habitDisplay_sortType_colorType => 'За кольором';

  @override
  String get habitDisplay_sortType_progress => 'За курсом';

  @override
  String get habitDisplay_sortType_startT => 'За датою початку';

  @override
  String get habitDisplay_sortType_status => 'За статусом';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Сортувати';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'скасувати';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Налагодження';

  @override
  String get habitDetail_editButton_tooltip => 'Редагувати';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Розархівувати';

  @override
  String get habitDetail_editPopMenu_archive => 'Архів';

  @override
  String get habitDetail_editPopMenu_export => 'Експорт';

  @override
  String get habitDetail_editPopMenu_delete => 'Видалити';

  @override
  String get habitDetail_editPopMenu_clone => 'Шаблон';

  @override
  String get habitDetail_confirmDialog_confirm => 'підтвердити';

  @override
  String get habitDetail_confirmDialog_cancel => 'скасувати';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Звичка архівувати?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Розархівувати звичку?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Видалити звичку?';

  @override
  String get habitDetail_summary_title => 'Резюме';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Поточна оцінка – $score, а з початку минуло $days дн.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Початок через $days днів.',
      one: 'Починаючи завтра.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'НЕСТАНДАРТ',
      one: 'НЕПОВНА',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'BECCABLE',
      one: 'OVERFULFIL',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Goal',
      two: 'Threshold',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'одиниця: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'нульовий';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'днів',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'д';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Записи';

  @override
  String get habitDetail_scoreChart_title => 'Оцінка';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'День';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'тиждень';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'місяць';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'рік';

  @override
  String get habitDetail_freqChart_freqTitle => 'Частота';

  @override
  String get habitDetail_freqChart_historyTitle => 'історія';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Частота та історія';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'тиждень';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'місяць';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'рік';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Зараз';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Приховати діаграму історії';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Показати діаграму історії';

  @override
  String get habitDetail_descSubgroup_title => 'Пам\'ятка';

  @override
  String get habitDetail_otherSubgroup_title => 'інше';

  @override
  String get habitDetail_habitType_title => 'Тип';

  @override
  String get habitDetail_reminderTile_title => 'Нагадування';

  @override
  String get habitDetail_freqTile_title => 'Повторіть';

  @override
  String get habitDetail_startDateTile_title => 'Дата початку';

  @override
  String get habitDetail_createDateTile_title => 'Створено';

  @override
  String get habitDetail_modifyDateTile_title => 'Змінено';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'дата';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'значення';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'повернутися до сьогоднішнього дня';

  @override
  String get habitDetail_notFoundText => 'Завантажити звичку не вдалося';

  @override
  String get habitDetail_notFoundRetryText => 'Спробуйте знову';

  @override
  String get habitDetail_changeGoal_title => 'Змінити ціль';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'поточний: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'зроблено: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'скасовано';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Щоденна мета, за замовчуванням: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'скасувати';

  @override
  String get habitDetail_changeGoal_saveText => 'зберегти';

  @override
  String get habitDetail_skipReason_title => 'Пропустити причину';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Напиши тут щось...';

  @override
  String get habitDetail_skipReason_cancelText => 'скасувати';

  @override
  String get habitDetail_skipReason_saveText => 'зберегти';

  @override
  String get appSetting_appbar_titleText => 'Налаштування';

  @override
  String get appSetting_displaySubgroupText => 'Дисплей';

  @override
  String get appSetting_operationSubgroupText => 'Операція';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Перетягніть календар за сторінкою';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Якщо перемикач увімкнено, календар на панелі додатків на домашній сторінці перетягуватиметься сторінка за сторінкою. За замовчуванням перемикач вимкнено.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Змінити статус запису';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Змініть поведінку кліків, щоб змінити статус щоденних записів на головній сторінці.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Відкрийте докладний запис';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Змініть поведінку клацання, щоб відкрити докладне спливаюче вікно щоденних записів на головній сторінці.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Перший день тижня';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Показати перший день тижня';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (За замовчуванням)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Слідкуйте за системою ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'Слідкуйте за системою';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Мова';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Виберіть мову';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Формат відображення дати ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'дотримуйтеся налаштувань системи';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Налаштований формат дати буде застосовано до відображення дати на сторінці з деталями про звичку.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Увімкніть Compact UI на сторінці звичок';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Дозволити таблицю перевірки звичок, щоб відображати більше вмісту, але деякі інтерфейси користувача та текст можуть виглядати меншими.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Звички перевіряють зону налаштування радіо';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Відрегулюйте відсоток для збільшення/меншення місця в області таблиці перевірки звичок.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'За замовчуванням';

  @override
  String get appSetting_reminderSubgroupText => 'Нагадування';

  @override
  String get appSetting_dailyReminder_titleText => 'Щоденне нагадування';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Резервне копіювання та відновлення';

  @override
  String get appSetting_export_titleText => 'Експорт';

  @override
  String get appSetting_export_subtitleText => 'Експортовані звички у форматі JSON. Цей файл можна імпортувати назад.';

  @override
  String get appSetting_import_titleText => 'Імпорт';

  @override
  String get appSetting_import_subtitleText => 'Імпортуйте звички з файлу json.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Підтвердити імпорт $count звичок?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Примітка. Імпорт не видаляє наявні звички.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'підтвердити';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'скасувати';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Імпортні $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Повний імпорт $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'закрити';

  @override
  String get appSetting_resetConfig_titleText => 'Скинути конфігурації';

  @override
  String get appSetting_resetConfig_subtitleText => 'Скинути всі конфігурації до стандартних.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Скинути конфігурації?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Скинути всі конфігурації до стандартних, потрібно перезапустити програму, щоб застосувати.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'скасувати';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'підтвердити';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'скидання конфігурації програми успішне';

  @override
  String get appSetting_otherSubgroupText => 'інші';

  @override
  String get appSetting_developMode_titleText => 'Режим розробки';

  @override
  String get appSetting_clearCache_titleText => 'Очистити кеш';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Очистити кеш';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Після очищення кешу деякі настроювані значення буде відновлено до значень за замовчуванням.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'скасувати';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'підтвердити';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Не вдалося частково очистити кеш';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Кеш успішно очищено';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Не вдалося очистити кеш';

  @override
  String get appSetting_debugger_titleText => 'Інформація про налагодження';

  @override
  String get appSetting_about_titleText => 'про';

  @override
  String get appSetting_experimentalFeatureTile_titleText => 'Experimental Features';

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
  String get appAbout_appbarTile_titleText => 'про';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Версія: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Вихідний код';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Відстеження проблем';

  @override
  String get appAbout_contactEmailTile_titleText => 'Зв\'яжіться зі мною';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Привіт, я радий, що ти звернувся до мене.\nЯкщо ви повідомляєте про помилку, будь ласка, вкажіть версію програми та опишіть кроки для її відтворення.\n-------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Ліцензія';

  @override
  String get appAbout_licenseTile_subtitleText => 'Ліцензія Apache, версія 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Заява про ліцензування третьої сторони';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'тріпотіння';

  @override
  String get appAbout_donateTile_titleText => 'Пожертвуйте';

  @override
  String get appAbout_donateTile_subTitleText => 'Я персональний розробник. Якщо вам подобається цей додаток, купіть мені ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Купи мені кави';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Криптовалюти';

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
  String get donateWay_firstQRGroup => 'Alipay і Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'Скопійовано адресу $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Пакетна реєстрація';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Попередній день';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Наступного дня';

  @override
  String get batchCheckin_status_skip_text => 'Пропустити';

  @override
  String get batchCheckin_status_ok_text => 'Повний';

  @override
  String get batchCheckin_status_double_text => 'x2 удар!';

  @override
  String get batchCheckin_status_zero_text => 'Неповний';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habits',
      one: 'Habit',
    );
    return '$count $_temp0 вибрано';
  }

  @override
  String get batchCheckin_save_button_text => 'зберегти';

  @override
  String get batchCheckin_reset_button_text => 'Скинути';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'статус $count звичок',
      one: 'статус звички',
    );
    return 'Змінено $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'Перезаписати існуючі записи';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Існуючі записи буде перезаписано. Після збереження попередні записи буде втрачено.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'зберегти';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'скасувати';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Підтвердити повернення';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Зміни статусу реєстрації не будуть застосовані до збереження';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'вихід';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'скасувати';

  @override
  String get appReminder_dailyReminder_title => '🏝 Чи дотрималися ви сьогодні своїх звичок?';

  @override
  String get appReminder_dailyReminder_body => 'натисніть, щоб увійти в програму та зайти вчасно.';

  @override
  String get common_habitColorType_cc1 => 'Глибокий бузок';

  @override
  String get common_habitColorType_cc2 => 'Червоний';

  @override
  String get common_habitColorType_cc3 => 'Фіолетовий';

  @override
  String get common_habitColorType_cc4 => 'Королівський синій';

  @override
  String get common_habitColorType_cc5 => 'Темно-блакитний';

  @override
  String get common_habitColorType_cc6 => 'Зелений';

  @override
  String get common_habitColorType_cc7 => 'Бурштин';

  @override
  String get common_habitColorType_cc8 => 'Помаранчевий';

  @override
  String get common_habitColorType_cc9 => 'Зелений лайм';

  @override
  String get common_habitColorType_cc10 => 'Темна орхідея';

  @override
  String common_habitColorType_default(int index) {
    return 'колір $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Використовуйте системний формат';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Формат дати';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Рік Місяць День';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Місяць День Рік';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'День Місяць Рік';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Роздільник';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Тире';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Слеш';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'космос';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Крапка';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Без роздільника';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Використовуйте 12-годинний формат';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Використовуйте повне ім\'я';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Подайте заявку на Freq Chart';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Подати заявку на Календар';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'скасувати';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'підтвердити';

  @override
  String get common_errorPage_title => 'Ой, збій!';

  @override
  String get common_errorPage_copied => 'Скопійовано інформацію про збій';

  @override
  String get calendarPicker_clip_today => 'Сьогодні';

  @override
  String get calendarPicker_clip_tomorrow => 'завтра';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Далі $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Експортувати всі звички?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number звичок',
      one: '1 звичка',
      zero: 'поточна звичка',
    );
    return 'Експортувати $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'включити записи';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'скасувати';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'експорт';

  @override
  String get debug_logLevelTile_title => 'Рівень реєстрації';

  @override
  String get debug_logLevelDialog_title => 'Змінити рівень реєстрації';

  @override
  String get debug_logLevel_debug => 'Налагодження';

  @override
  String get debug_logLevel_info => 'Інформація';

  @override
  String get debug_logLevel_warn => 'УВАГА';

  @override
  String get debug_logLevel_error => 'Помилка';

  @override
  String get debug_logLevel_fatal => 'Фатальний';

  @override
  String get debug_collectLogTile_title => 'Збір журналів';

  @override
  String get debug_collectLogTile_enable_subtitle => 'Торкніться, щоб припинити збір журналів.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Торкніться, щоб почати збір журналів.';

  @override
  String get debug_downladDebugLogs_subject => 'Завантаження журналів налагодження';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Журнали налагодження очищено.';

  @override
  String get debug_downladDebugInfo_subject => 'Завантаження інформації про налагодження';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Завантаження $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Журнал налагодження не існує.';

  @override
  String get debug_debuggerLogCard_title => 'Інформація про журнал';

  @override
  String get debug_debuggerLogCard_subtitle => 'Включає локальну інформацію журналу налагодження, потрібно ввімкнути перемикач збору журналів.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Завантажити';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'ясно';

  @override
  String get debug_debuggerInfoCard_title => 'Інформація про налагодження';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Включає інформацію про налагодження програми.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'ВІДЧИНЕНО';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'зберегти';

  @override
  String get debug_debuggerInfo_notificationTitle => 'Збір інформації про програму...';

  @override
  String get snackbar_undoText => 'UNDO';

  @override
  String get snackbar_dismissText => 'DISMISS';

  @override
  String get contributors_tile_title => 'Дописувачі';

  @override
  String get userAction_tap => 'Торкніться';

  @override
  String get userAction_doubleTap => 'Двомісний';

  @override
  String get userAction_longTap => 'довгий';
}
