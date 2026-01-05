// ignore: unused_import
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
  String get habitEdit_habitDailyGoalUnit_hintText =>
      'Одиниці вимірювання щоденної мети';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Бажана максимальна щоденна мета';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'введене значення має бути порожнім або ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Максимальне щоденне обмеження';

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
  String get habitEdit_reminderQuest_hintText =>
      'Питання, напр. Ви займалися спортом сьогодні?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Виберіть тип нагадування';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Коли потрібно зареєструватися';

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
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Ви підтверджуєте видалення цього нагадування';

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
  String get habitDisplay_emptyImage_text_01 =>
      'Подорож у тисячу миль починається з одного кроку';

  @override
  String get habitDisplay_notFoundImage_text_01 =>
      'Відповідних звичок не знайдено';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'Немає відповідних звичок для \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Архівувати вибрані звички?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'скасувати';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Заархівовано $count звичок';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Розархівувати вибрані звички?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'скасувати';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Розархівовано $count звичок';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Видалити вибрані звички?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'підтвердити';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'скасувати';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Видалено $count звичок';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Вилучена звичка: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Експортовано звичок: $count.',
      one: 'Експортована звичка.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Експортовано всі звички';

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
  String get habitDisplay_statsMenu_statSubgroupText => 'Поточний';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Виконано';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'В роботі';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Архівовано';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Головні звички: зміни за останні 30 днів';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Світла тема';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Темна тема';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Слідкуйте за системою';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Показати в архіві';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'Показати завершено';

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
  String get habitDisplay_sortType_manual => 'Свій порядок';

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
  String get habitDisplay_searchBar_hintText => 'Пошук звичок';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Поточний';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Показує звички, які є активними та тривають (не архівовані чи видалені).';

  @override
  String get habitDisplay_searchFilter_completed => 'Виконано';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Тип звички';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Показати фільтри';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Очистити фільтри';

  @override
  String get habitDisplay_tab_habits_label => 'Звички';

  @override
  String get habitDisplay_tab_today_label => 'Сьогодні';

  @override
  String get habitToday_appBar_title => 'Сьогодні';

  @override
  String get habitToday_image_desc => 'ТИ ЦЕ ЗРОБИВ';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Тримав так $days днів';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Готово+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Пропустити+';

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
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Розархівувати звичку?';

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
      one: 'ПЕРЕВИКОНАНО',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Ціль',
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
      other: 'Днів',
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
  String get habitDetail_scoreChartCombine_weeklyText => 'Тиждень';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Місяць';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Рік';

  @override
  String get habitDetail_freqChart_freqTitle => 'Частота';

  @override
  String get habitDetail_freqChart_historyTitle => 'Історія';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Частота та історія';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Тиждень';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Місяць';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Рік';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Зараз';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Приховати діаграму історії';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Показати діаграму історії';

  @override
  String get habitDetail_descSubgroup_title => 'Пам\'ятка';

  @override
  String get habitDetail_otherSubgroup_title => 'Інше';

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
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'повернутися до сьогоднішнього дня';

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
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Перетягніть календар за сторінкою';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Якщо перемикач увімкнено, календар на панелі додатків на домашній сторінці перетягуватиметься сторінка за сторінкою. За замовчуванням перемикач вимкнено.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Змінити статус запису';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Змініть поведінку кліків, щоб змінити статус щоденних записів на головній сторінці.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Відкрийте докладний запис';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Змініть поведінку клацання, щоб відкрити докладне спливаюче вікно щоденних записів на головній сторінці.';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Колір теми';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'Виберіть колір теми';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Використовувати основний колір шпалер (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'Використати вибраний колір фону теми GTK+';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Використати колір системної теми';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Використовуйте системний акцент або колір вікна/скла';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Перший день тижня';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Показати перший день тижня';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText =>
      ' (За замовчуванням)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Слідкуйте за системою ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Слідкуйте за системою';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Мова';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Виберіть мову';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Формат відображення дати ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'дотримуйтеся налаштувань системи';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Налаштований формат дати буде застосовано до відображення дати на сторінці з деталями про звичку.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Увімкніть компактний інтерфейс на сторінці звичок';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Дозволити таблицю перевірки звичок, щоб відображати більше вмісту, але деякі інтерфейси користувача та текст можуть виглядати меншими.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Звички перевіряють зону налаштування радіо';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Відрегулюйте відсоток для збільшення/меншення місця в області таблиці перевірки звичок.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText =>
      'За замовчуванням';

  @override
  String get appSetting_reminderSubgroupText => 'Нагадування та сповіщення';

  @override
  String get appSetting_dailyReminder_titleText => 'Щоденне нагадування';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Резервне копіювання та відновлення';

  @override
  String get appSetting_export_titleText => 'Експорт';

  @override
  String get appSetting_export_subtitleText =>
      'Експортовані звички у форматі JSON. Цей файл можна імпортувати назад.';

  @override
  String get appSetting_import_titleText => 'Імпорт';

  @override
  String get appSetting_import_subtitleText =>
      'Імпортуйте звички з файлу json.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Підтвердити імпорт $count звичок?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Примітка. Імпорт не видаляє наявні звички.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'підтвердити';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'скасувати';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
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
  String get appSetting_resetConfig_subtitleText =>
      'Скинути всі конфігурації до стандартних.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Скинути конфігурації?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Скинути всі конфігурації до стандартних, потрібно перезапустити програму, щоб застосувати.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'скасувати';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'підтвердити';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'скидання конфігурації програми успішне';

  @override
  String get appSetting_otherSubgroupText => 'Інші';

  @override
  String get appSetting_developMode_titleText => 'Режим розробки';

  @override
  String get appSetting_clearCache_titleText => 'Очистити кеш';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Очистити кеш';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Після очищення кешу деякі настроювані значення буде відновлено до значень за замовчуванням.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'скасувати';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'підтвердити';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Не вдалося частково очистити кеш';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Кеш успішно очищено';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Не вдалося очистити кеш';

  @override
  String get appSetting_debugger_titleText => 'Інформація про налагодження';

  @override
  String get appSetting_about_titleText => 'Про';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Експериментальні функції';

  @override
  String get appSetting_synSubgroupText => 'Синхронізувати';

  @override
  String get appSetting_syncOption_titleText => 'Параметри синхронізації';

  @override
  String get appSetting_notify_titleTile => 'Сповіщення';

  @override
  String get appSetting_notify_subtitleTile =>
      'Керування налаштуваннями сповіщень';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Натисніть, щоб відкрити налаштування системних сповіщень';

  @override
  String get appSync_nowTile_titleText => 'Синхронізувати зараз';

  @override
  String get appSync_nowTile_titleText_syncing => 'Синхронізація';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'Остання синхронізація: Н/Д';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Остання синхронізація: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Остання синхронізація (помилка): Н/Д';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Остання синхронізація (помилка): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Синхронізація...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Синхронізація: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Скасування...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Остання синхронізація (скасована): Н/Д';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Остання синхронізація (скасована): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Перевірте журнали помилок';

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
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Completed',
      'cancelled': 'Canceled',
      'failed': 'Failed',
      'multi': 'Multiple statuses',
      'other': 'Unknown status',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Completed due to $reason',
      'cancelled': 'Canceled due to $reason',
      'failed': 'Failed due to $reason',
      'multi': 'Multiple statuses due to $reason',
      'other': 'Unknown status',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Error',
      'userAction': 'User action required',
      'missingHabitUuid': 'Missing habit UUID',
      'empty': 'Empty data',
      'other': 'Unknown reason',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'Нова локація';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Синхронізація створить необхідні каталоги та завантажить локальні звички на сервер. Продовжити?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Синхронізувати зараз!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Підтвердити синхронізацію';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Каталог не порожній. Синхронізація об’єднає серверні та локальні звички. Продовжити?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Підтвердити об’єднання';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Експорт журналів невдалої синхронізації';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'No log founded',
      'false': 'Tap to export',
      'other': 'loading...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Current: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Fake (Only For Debugger)',
      'other': 'Unknown ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Mobile',
      'wifi': 'Wifi',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Вручну',
      'minute5': '5 Хвилин',
      'minute15': '15 Хвилин',
      'minute30': '30 Хвилин',
      'hour1': '1 Час',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Інтервал отримання';

  @override
  String get appSync_summaryTile_title => 'Сервер синхронізації';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Не налаштовано';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Усі останні журнали невдалої синхронізації';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Підтвердьте збереження змін';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Збереження перезапише попередню конфігурацію сервера.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'Незбережені зміни';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Вихід призведе до скасування всіх незбережених змін.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText =>
      'Підтвердьте видалення';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Видалення призведе до видалення поточної конфігурації сервера.';

  @override
  String get appSync_serverEditor_titleText_add => 'Новий сервер синхронізації';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Змінити сервер синхронізації';

  @override
  String get appSync_serverEditor_advance_titleText => 'Розширені конфігурації';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Шлях';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Введіть тут дійсний шлях WebDAV.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Шлях не повинен бути порожнім!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Ім\'я користувача';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Введіть тут ім’я користувача, залиште порожнім, якщо не потрібно.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Пароль';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Ігнорувати сертифікат SSL';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Секунди тайм-ауту синхронізації';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Infinite',
    );
    return 'За замовчуванням: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 'с';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Тайм-аут підключення до мережі, секунди';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Infinite',
    );
    return 'За замовчуванням: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 'с';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Кількість спроб підключення до мережі';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Retry disabled',
    );
    return 'За замовчуванням: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Режим мережевої синхронізації';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Sync on Cellular Network',
      'wifi': 'Sync on Wifi',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'LowData';

  @override
  String get appSync_noti_readyToSync_body => 'Підготовка до синхронізації...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Синхронізовано ($type)',
      'failed': 'Помилка синхронізації ($type)',
      'other': 'Синхронізація ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Синхронізація в режимі низького рівня даних';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Увімкнено одну або кілька експериментальних функцій. Використовуйте з обережністю.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Синхронізація з хмарою звичок';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Після ввімкнення опція синхронізації програми з’явиться в налаштуваннях';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Експериментальна функція ($syncName) вимкнена, але функція все ще працює.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Щоб повністю вимкнути, утримуйте, щоб отримати доступ до \'$menuName\' і вимкніть його.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'Пошук звички';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Після ввімкнення у верхній частині екрана «Звички» з’явиться рядок пошуку, який дозволить шукати звички.';

  @override
  String get appAbout_appbarTile_titleText => 'Про';

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
  String get appAbout_contactEmailTile_emailBody =>
      'Привіт, я радий, що ти звернувся до мене.\nЯкщо ви повідомляєте про помилку, будь ласка, вкажіть версію програми та опишіть кроки для її відтворення.\n-------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Ліцензія';

  @override
  String get appAbout_licenseTile_subtitleText => 'Ліцензія Apache, версія 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Заява про ліцензування третьої сторони';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'Flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Конфіденційність';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Ознайомтеся з політикою конфіденційності в цьому додатку';

  @override
  String get appAbout_donateTile_titleText => 'Пожертвуйте';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Я персональний розробник. Якщо вам подобається цей додаток, купіть мені ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

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
  String get batchCheckin_save_button_text => 'Зберегти';

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
  String get batchCheckin_save_confirmDialog_title =>
      'Перезаписати існуючі записи';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Існуючі записи буде перезаписано. Після збереження попередні записи буде втрачено.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'зберегти';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'скасувати';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Підтвердити повернення';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Зміни статусу реєстрації не будуть застосовані до збереження';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'вихід';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'скасувати';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Чи дотрималися ви сьогодні своїх звичок?';

  @override
  String get appReminder_dailyReminder_body =>
      'натисніть, щоб увійти в програму та зайти вчасно.';

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
  String get common_appThemeColor_system => 'Система';

  @override
  String get common_appThemeColor_primary => 'Первинний';

  @override
  String get common_appThemeColor_dynamic => 'Динамічний';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Використовуйте системний формат';

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
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Космос';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Крапка';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Без роздільника';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Використовуйте 12-годинний формат';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Використовуйте повне ім\'я';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Подайте заявку на Freq Chart';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Подати заявку на Календар';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'скасувати';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text =>
      'підтвердити';

  @override
  String get common_errorPage_title => 'Ой, збій!';

  @override
  String get common_errorPage_copied => 'Скопійовано інформацію про збій';

  @override
  String get common_enable_text => 'Увімкнено';

  @override
  String get calendarPicker_clip_today => 'Сьогодні';

  @override
  String get calendarPicker_clip_tomorrow => 'Завтра';

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
  String get debug_logLevel_warn => 'Увага';

  @override
  String get debug_logLevel_error => 'Помилка';

  @override
  String get debug_logLevel_fatal => 'Фатальний';

  @override
  String get debug_collectLogTile_title => 'Збір журналів';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Торкніться, щоб припинити збір журналів.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Торкніться, щоб почати збір журналів.';

  @override
  String get debug_downladDebugLogs_subject =>
      'Завантаження журналів налагодження';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Журнали налагодження очищено.';

  @override
  String get debug_downladDebugInfo_subject =>
      'Завантаження інформації про налагодження';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Завантаження $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Журнал налагодження не існує.';

  @override
  String get debug_debuggerLogCard_title => 'Інформація про журнал';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Включає локальну інформацію журналу налагодження, потрібно ввімкнути перемикач збору журналів.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Завантажити';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Очистити';

  @override
  String get debug_debuggerInfoCard_title => 'Інформація про налагодження';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Включає інформацію про налагодження програми.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Відкрити';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Зберегти';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Збір інформації про програму...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Save',
      'exit': 'Exit',
      'delete': 'Delete',
      'other': 'Confirm',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'Скасувати';

  @override
  String get snackbar_undoText => 'ВІДМІНИТИ';

  @override
  String get snackbar_dismissText => 'ВІДХИЛИТИ';

  @override
  String get contributors_tile_title => 'Дописувачі';

  @override
  String get userAction_tap => 'Тапніть';

  @override
  String get userAction_doubleTap => 'Двічі';

  @override
  String get userAction_longTap => 'Довгий';

  @override
  String get channelName_habitReminder => 'Нагадування про звички';

  @override
  String get channelName_appReminder => 'Підказка';

  @override
  String get channelName_appDebugger => 'Налагоджувач';

  @override
  String get channelName_appSyncing => 'Процес синхронізації';

  @override
  String get channelDesc_appSyncing =>
      'Використовується для відображення прогресу синхронізації та результатів без помилок';

  @override
  String get channelName_appSyncFailed => 'Помилка синхронізації';

  @override
  String get channelDesc_appSyncFailed =>
      'Використовується для сповіщення про невдачу синхронізації';
}
