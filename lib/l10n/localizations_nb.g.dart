import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Norwegian Bokmål (`nb`).
class L10nNb extends L10n {
  L10nNb([String locale = 'nb']) : super(locale);

  @override
  String get localeScriptName => 'Norsk Bokmål';

  @override
  String get appName => '🚧(nb_NO) - Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Save';

  @override
  String get habitEdit_habitName_hintText => 'Habit Name ...';

  @override
  String get habitEdit_colorPicker_title => 'Pick color';

  @override
  String get habitEdit_habitTypeDialog_title => 'Habit type';

  @override
  String get habitEdit_habitType_positiveText => 'Positive';

  @override
  String get habitEdit_habitType_negativeText => 'Negative';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Daily goal, default $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Minimum daily threshold, default $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'daily goal must > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'daily goal must ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'daily goal must ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'daily goal must ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Daily goal unit';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Desired maximum daily goal';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'invalid value, must be empty or ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Maximum daily limit';

  @override
  String get habitEdit_frequencySelector_title => 'Select frequency';

  @override
  String get habitEdit_habitFreq_daily => 'Daily';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'times per week';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'times per month';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'times in';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'days';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Daily';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'At least $freq times per week',
      one: 'Per week',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'At least $freq times per month',
      one: 'Per month',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'At least $freq times in every $days days',
      one: 'In every $days days',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays days';
  }

  @override
  String get habitEidt_targetDays_dialogTitle => 'Select Target Days';

  @override
  String get habitEdit_targetDays => 'days';

  @override
  String get habitEdit_reminder_hintText => 'Reminder';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Any day of week';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' in every week';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Any day of month';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' in every month';

  @override
  String get habitEdit_reminderQuest_hintText => 'Question, e.g. Did you exercise today?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Choose reminder type';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'When need to check in';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Daily';

  @override
  String get habitEdit_reminder_dialogType_week => 'Per week';

  @override
  String get habitEdit_reminder_dialogType_month => 'Per month';

  @override
  String get habitEdit_reminder_dialogConfirm => 'confirm';

  @override
  String get habitEdit_reminder_dialogCancel => 'cancel';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Confirm';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Do you confirm to remove this reminder';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'confirm';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'cancel';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Mon';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Tue';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Wed';

  @override
  String get habitEdit_reminder_weekdayText_tursday => 'Tur';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Fri';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sat';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Sun';

  @override
  String get habitEdit_desc_hintText => 'Memo, support Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Created: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Modified: ';

  @override
  String get habitDisplay_fab_text => 'New Habit';

  @override
  String get habitDisplay_emptyImage_text_01 => 'A journey of a thousand miles begins with a single step';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Archive Selected Habits?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'confirm';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'cancel';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Archived $count habits';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Unarchive Selected Habits?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'confirm';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'cancel';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Unarchived $count habits';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Delete Selected Habits?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'confirm';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'cancel';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Deleted $count habits';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Select All';

  @override
  String get habitDisplay_editPopMenu_export => 'Export';

  @override
  String get habitDisplay_editPopMenu_delete => 'Delete';

  @override
  String get habitDisplay_editPopMenu_clone => 'Template';

  @override
  String get habitDisplay_editButton_tooltip => 'Edit';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archive';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Unarchive';

  @override
  String get habitDisplay_settingButton_tooltip => 'Setting';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Current';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Completed';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'In Progress';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archived';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Top Habits: Last 30 Days Changes';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Light Theme';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Dark Theme';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Follow System';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Show Archived';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Show Completed';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Show Actived';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Settings';

  @override
  String get habitDisplay_sort_reverseText => 'Reverse';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Desc)';

  @override
  String get habitDisplay_sortType_manual => 'My order';

  @override
  String get habitDisplay_sortType_name => 'By Name';

  @override
  String get habitDisplay_sortType_colorType => 'By Color';

  @override
  String get habitDisplay_sortType_progress => 'By Rate';

  @override
  String get habitDisplay_sortType_startT => 'By Start Date';

  @override
  String get habitDisplay_sortType_status => 'By Status';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sort';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'confirm';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'cancel';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Debug';

  @override
  String get habitDetail_editButton_tooltip => 'Edit';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Unarchive';

  @override
  String get habitDetail_editPopMenu_archive => 'Archive';

  @override
  String get habitDetail_editPopMenu_export => 'Export';

  @override
  String get habitDetail_editPopMenu_delete => 'Delete';

  @override
  String get habitDetail_editPopMenu_clone => 'Template';

  @override
  String get habitDetail_confirmDialog_confirm => 'confirm';

  @override
  String get habitDetail_confirmDialog_cancel => 'cancel';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Archive Habit?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Unarchive Habit?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Delete Habit?';

  @override
  String get habitDetail_summary_title => 'Summary';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Current grade is $score, and it has been $days days since the start.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Start in $days days.',
      one: 'Starting tomorrow.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'SUBSTANDARD',
      one: 'INCOMPLETE',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'IMPECCABLE',
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
    return 'Unit: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Days',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'd';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Records';

  @override
  String get habitDetail_scoreChart_title => 'Score';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Day';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Week';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Month';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Year';

  @override
  String get habitDetail_freqChart_freqTitle => 'Frequency';

  @override
  String get habitDetail_freqChart_historyTitle => 'History';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Frequency & History';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Week';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Month';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Year';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Now';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Hide History Chart';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Show History Chart';

  @override
  String get habitDetail_descSubgroup_title => 'Memo';

  @override
  String get habitDetail_otherSubgroup_title => 'Other';

  @override
  String get habitDetail_habitType_title => 'Type';

  @override
  String get habitDetail_reminderTile_title => 'Reminder';

  @override
  String get habitDetail_freqTile_title => 'Repeat';

  @override
  String get habitDetail_startDateTile_title => 'Start Date';

  @override
  String get habitDetail_createDateTile_title => 'Created';

  @override
  String get habitDetail_modifyDateTile_title => 'Modified';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'date';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'value';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'back to today';

  @override
  String get habitDetail_notFoundText => 'Load habit failed';

  @override
  String get habitDetail_notFoundRetryText => 'Try again';

  @override
  String get habitDetail_changeGoal_title => 'Change goal';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'current: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'done: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'undone';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Daily goal, default: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'cancel';

  @override
  String get habitDetail_changeGoal_saveText => 'save';

  @override
  String get habitDetail_skipReason_title => 'Skip reason';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Write something here...';

  @override
  String get habitDetail_skipReason_cancelText => 'cancel';

  @override
  String get habitDetail_skipReason_saveText => 'save';

  @override
  String get appSetting_appbar_titleText => 'Settings';

  @override
  String get appSetting_displaySubgroupText => 'Display';

  @override
  String get appSetting_operationSubgroupText => 'Operation';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Drag calendar by page';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'If the switch is enabled, the app bar calendar on the home page will be dragged page by page. By default, the switch is disabled.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Change Record Status';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Modify the click behavior to change the status of daily records on main page.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Open Detailed Record';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Modify the click behavior to open the detailed popup for daily records on main page.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'First day of week';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Show first day of week';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Default)';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Date display format ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'follow system setting';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Configed date format will be applied to the date display on habit detail page.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Enable Compact UI on habits page';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Allow habits check table to display more content, but some UI and text may appear smaller.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Habits check area radio adjustment';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Adjust percentage for more/less space in habits check table area.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Default';

  @override
  String get appSetting_reminderSubgroupText => 'Reminder';

  @override
  String get appSetting_dailyReminder_titleText => 'Daily reminder';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Backup & restore';

  @override
  String get appSetting_export_titleText => 'Export';

  @override
  String get appSetting_export_subtitleText => 'Exported habits as JSON format, This file can be import back.';

  @override
  String get appSetting_import_titleText => 'Import';

  @override
  String get appSetting_import_subtitleText => 'Import habits from json file.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Confirm import $count habits?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Note: Import doesn\'t delete existing habits.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'confirm';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'cancel';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Imported $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Complete import $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'close';

  @override
  String get appSetting_resetConfig_titleText => 'Reset configs';

  @override
  String get appSetting_resetConfig_subtitleText => 'Reset all configs to default.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Reset configs?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Reset all configs to default, must restart application to apply.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'cancel';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'comfirm';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'reset app configs succeed';

  @override
  String get appSetting_otherSubgroupText => 'Others';

  @override
  String get appSetting_developMode_titleText => 'Develop Mode';

  @override
  String get appSetting_clearCache_titleText => 'Clear Cache';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Clear Cache';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'After clearing cache, some custom values will be restored to defaults.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'cancel';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'confirm';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Partial Cache cleared failed';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Cache cleared successfully';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Cache cleared failed';

  @override
  String get appSetting_about_titleText => 'About';

  @override
  String get appAbout_appbarTile_titleText => 'About';

  @override
  String appAbout_verionTile_titleText(String appVersion) {
    return 'Version: $appVersion';
  }

  @override
  String get appAbout_verionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Source code';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Issue tracker';

  @override
  String get appAbout_contactEmailTile_titleText => 'Contact me';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'License';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Third Party Licensing Statement';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Donate';

  @override
  String get appAbout_donateTile_subTitleText => 'I\'m a personal developer. If you like this app, please buy me a ☕.';

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
  String get donateWay_cryptoCurrency => 'Cryto Currencies';

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
    return 'Copied $name\'s Address';
  }

  @override
  String get batchCheckin_appbar_title => 'Batch Check-in';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Previous day';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Next day';

  @override
  String get batchCheckin_status_skip_text => 'Skip';

  @override
  String get batchCheckin_status_ok_text => 'Complete';

  @override
  String get batchCheckin_status_double_text => 'x2 Hit!';

  @override
  String get batchCheckin_status_zero_text => 'Incomplete';

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
  String get batchCheckin_save_button_text => 'Save';

  @override
  String get batchCheckin_reset_button_text => 'Reset';

  @override
  String get batchCheckin_save_confirmDialog_title => 'Overwrite Existing Records';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Existing records will be overwritten After saving, previous records will be lost.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'save';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'cancel';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirm Return';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Check-in Status Changes won\'t be applied before saved';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'exit';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'cancel';

  @override
  String get appReminder_dailyReminder_title => '🏝 Did you stick to your habits today?';

  @override
  String get appReminder_dailyReminder_body => 'click to enter app and punch in on time.';

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
    return 'Color $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Use system format';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Date format';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Year Month Day';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Month Day Year';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Day Month Year';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separator';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Dash';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Slash';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Space';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Dot';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'No Separator';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Use 12-hour format';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Use full name';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Apply for Freq Chart';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Apply for Calendar';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'cancel';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'confirm';

  @override
  String get calendarPicker_clip_today => 'Today';

  @override
  String get calendarPicker_clip_tomorrow => 'Tomorrow';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Next $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Export all habits?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number habits',
      one: '1 habit',
      zero: 'current habit',
    );
    return 'Export $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'include records';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'cancel';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'export';

  @override
  String get snackbar_undoText => 'UNDO';

  @override
  String get snackbar_dissmessText => 'DISMISS';

  @override
  String get contributors_tile_title => 'Contributors';

  @override
  String get userAction_tap => 'Tap';

  @override
  String get userAction_doubleTap => 'Double';

  @override
  String get userAction_longTap => 'Long';
}
