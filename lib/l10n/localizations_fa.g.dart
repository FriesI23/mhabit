// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class L10nFa extends L10n {
  L10nFa([String locale = 'fa']) : super(locale);

  @override
  String get localeScriptName => 'پارسی';

  @override
  String get appName => 'زیگ عادت‌ها';

  @override
  String get habitEdit_saveButton_text => 'ذخیره';

  @override
  String get habitEdit_habitName_hintText => 'نام عادت...';

  @override
  String get habitEdit_colorPicker_title => 'گزینش رنگ';

  @override
  String get habitEdit_colorPicker_historySectionLabel => 'Recently used';

  @override
  String habitEdit_colorPicker_customSectionLabel(String tinted) {
    String _temp0 = intl.Intl.selectLogic(tinted, {
      'true': 'Custom (Tinted)',
      'false': 'Custom',
      'other': 'Custom',
    });
    return '$_temp0';
  }

  @override
  String get habitEdit_colorPicker_cancel => 'Cancel';

  @override
  String get habitEdit_colorPicker_tintToggleLabel => 'Tint to theme';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Tinted';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Not tinted';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'Tinting may shift the final color away from the one you picked.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Some colors may reduce text readability in light or dark theme.';

  @override
  String get habitEdit_habitTypeDialog_title => 'نوع عادت';

  @override
  String get habitEdit_habitType_positiveText => 'مثبت';

  @override
  String get habitEdit_habitType_negativeText => 'منفی';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'هدف روزانه ، پیش‌فرض $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'حداقل مقدار روزانه، پیش‌فرض $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'هدف روزانه باید بیشتر از $number باشد';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'هدف روزانه باید حداکثر $number باشد';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'هدف روزانه باید بیشتر یا مساوی $number باشد';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'هدف روزانه باید حداکثر $number باشد';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'واحد هدف روزانه';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'حداکثر هدف روزانه مطلوب';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'مقدار نامعتبر، باید خالی یا بیشتر یا مساوی $dailyGoal باشد';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'حداکثر محدوده روزانه';

  @override
  String get habitEdit_frequencySelector_title => 'انتخاب تناوب';

  @override
  String get habitEdit_habitFreq_daily => 'روزانه';

  @override
  String get habitEdit_habitFreq_perweek_text => 'هفتگی %%time%% بار در هفته';

  @override
  String get habitEdit_habitFreq_permonth_text => 'ماهیانه %%time%% بار در ماه';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      'تناوب‌روزها %%time%% بار در %%day%% روز';

  @override
  String get habitEdit_habitFreq_show_daily => 'روزانه';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'حداقل $freq بار در هفته',
      one: 'هفته‌ای یک بار',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'حداقل $freq بار در ماه',
      one: 'ماهانه یک بار',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'حداقل $freq بار در هر $days روز',
      one: 'در هر $days روز',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays روز';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'انتخاب روزهای هدف';

  @override
  String get habitEdit_targetDays => 'روز';

  @override
  String get habitEdit_reminder_hintText => 'یادآور';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'هر روز هفته';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days هفته‌ای';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'هر روز ماه';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days ماهانه';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'سوال، مثلاً آیا امروز ورزش کرده‌اید؟';

  @override
  String get habitEdit_reminder_dialogTitle => 'انتخاب نوع یادآور';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'هنگام نیاز به بررسی';

  @override
  String get habitEdit_reminder_dialogType_daily => 'روزانه';

  @override
  String get habitEdit_reminder_dialogType_week => 'هفتگی';

  @override
  String get habitEdit_reminder_dialogType_month => 'ماهانه';

  @override
  String get habitEdit_reminder_dialogConfirm => 'تایید';

  @override
  String get habitEdit_reminder_dialogCancel => 'لغو';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'تایید';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'این یادآور حذف خواهد شد، آیا ادامه می‌دهید؟';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'تایید';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'لغو';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'دوشنبه';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'سه‌شنبه';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'چهارشنبه';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'پنج‌شنبه';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'جمعه';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'شنبه';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'یک‌شنبه';

  @override
  String get habitEdit_desc_hintText => 'یادداشت، با پشتیبانی از Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'ایجاد شده: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'ویرایش شده: ';

  @override
  String get habitDisplay_fab_text => 'عادت جدید';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'سفر هزار کیلومتری با اولین قدم آغاز می‌شود';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'No matching habits found';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'No matching habits for \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'آرشیو کردن عادت‌های انتخاب شده؟';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'تایید';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'لغو';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count عادت آرشیو شدند';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'عادت‌های انتخاب شده از آرشیو خارج شوند؟';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'تایید';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'لغو';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count عادت از آرشیو خارج شدند';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'عادت‌های انتخاب شده حذف شوند؟';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'تایید';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'لغو';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count عادت حذف شدند';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Deleted habit: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count habits.',
      one: 'Exported habit.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Exported All Habits';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'انتخاب همه';

  @override
  String get habitDisplay_editPopMenu_export => 'خروجی';

  @override
  String get habitDisplay_editPopMenu_delete => 'حذف';

  @override
  String get habitDisplay_editPopMenu_clone => 'الگو';

  @override
  String get habitDisplay_editButton_tooltip => 'ویرایش';

  @override
  String get habitDisplay_archiveButton_tooltip => 'آرشیو';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'خروج از آرشیو';

  @override
  String get habitDisplay_settingButton_tooltip => 'تنظیمات';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'فعلی';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'به اتمام رسیده';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'در حال انجام';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'آرشیو شده';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'محبوبیت :در ۳۰ روز گذشته';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'تم روشن';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'تم تاریک';

  @override
  String get habitDisplay_mainMenu_followSystemTheme =>
      'پیروی از تنظیمات سیستم';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'نمایش آرشیو شده‌ها';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'نمایش به اتمام رسیده‌ها';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'نمایش موارد فعال';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'تنظیمات';

  @override
  String get habitDisplay_groupType_name => 'بر اساس نام';

  @override
  String get habitDisplay_groupType_colorType => 'بر اساس رنگ';

  @override
  String get habitDisplay_groupType_createDate => 'By Creation Date';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Group Sort';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'تایید';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'لغو';

  @override
  String get habitDisplay_groupTypeDialog_none => 'Flat';

  @override
  String get habitDisplay_editPopMenu_groupModify => 'Modify Group';

  @override
  String get habitDisplay_groupModifyDialog_title => 'Modify Group';

  @override
  String get habitDisplay_groupModifyDialog_removeGroup => 'Remove Group';

  @override
  String get habitDisplay_groupModifyDialog_emptyGroups =>
      'No groups available';

  @override
  String get habitDisplay_groupModifyDialog_alreadyInGroup =>
      'Selected habits are already in this group';

  @override
  String get habitDisplay_groupModifyDialog_createGroup => 'Create Group';

  @override
  String get habitDisplay_groupModifyDialog_saveAndApply => 'Save & Apply';

  @override
  String get habitDisplay_groupModifyConfirm_titleNew => 'Move to Group';

  @override
  String get habitDisplay_groupModifyConfirm_titleMixed =>
      'Confirm Group Change';

  @override
  String habitDisplay_groupModifyConfirm_bodyNewGroup(String groupName) {
    return '$groupName habits will be moved to this group';
  }

  @override
  String get habitDisplay_groupModifyConfirm_bodyRemoveGroup =>
      'Habits will have their group removed';

  @override
  String habitDisplay_groupModifyConfirm_bodyChangeStat(
    int count,
    String fromGroup,
    String toGroup,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits will change from \"$fromGroup\" to \"$toGroup\"',
      one: '$count habit will change from \"$fromGroup\" to \"$toGroup\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyAddStat(
    int count,
    String toGroup,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uncategorized habits will be added to \"$toGroup\"',
      one: '$count uncategorized habit will be added to \"$toGroup\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyRemoveStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits will have their groups removed',
      one: '$count habit will have its group removed',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_groupModifyConfirm_nameSeparator => ', ';

  @override
  String habitDisplay_groupModify_snackbarText(int count, String groupName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count habits to \"$groupName\"',
      one: 'Moved habit to \"$groupName\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModify_snackbarTextRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed groups from $count habits',
      one: 'Removed group from habit',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_groupModify_undoFailed =>
      'Group has been modified elsewhere, cannot undo';

  @override
  String get habitDisplay_sort_reverseText => 'معکوس';

  @override
  String get habitDisplay_sortDirection_asc => '(صعودی)';

  @override
  String get habitDisplay_sortDirection_Desc => '(نزولی)';

  @override
  String get habitDisplay_sortType_manual => 'ترتیب من';

  @override
  String get habitDisplay_sortType_name => 'بر اساس نام';

  @override
  String get habitDisplay_sortType_colorType => 'بر اساس رنگ';

  @override
  String get habitDisplay_sortType_progress => 'بر اساس امتیاز';

  @override
  String get habitDisplay_sortType_startT => 'بر اساس تاریخ شروع';

  @override
  String get habitDisplay_sortType_status => 'بر اساس وضعیت';

  @override
  String get habitDisplay_sortTypeDialog_title => 'مرتب سازی';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'تایید';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'لغو';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️اشکال‌زدایی';

  @override
  String get habitDisplay_searchBar_hintText => 'Search habits';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Ongoing';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'به اتمام رسیده';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'نوع عادت';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Show Filters';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clear Filters';

  @override
  String get habitDisplay_tab_habits_label => 'Habits';

  @override
  String get habitDisplay_tab_today_label => 'امروز';

  @override
  String get habitToday_appBar_title => 'امروز';

  @override
  String get habitToday_image_desc => 'YOU MADE IT';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Kept it up for $days days';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Done+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Skip+';

  @override
  String get habitDetail_editButton_tooltip => 'ویرایش';

  @override
  String get habitDetail_editPopMenu_unarchive => 'خارج کردن از حالت آرشیو';

  @override
  String get habitDetail_editPopMenu_archive => 'آرشیو';

  @override
  String get habitDetail_editPopMenu_export => 'خروجی';

  @override
  String get habitDetail_editPopMenu_delete => 'حذف';

  @override
  String get habitDetail_editPopMenu_clone => 'الگو';

  @override
  String get habitDetail_confirmDialog_confirm => 'تایید';

  @override
  String get habitDetail_confirmDialog_cancel => 'لغو';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'عادت آرشیو شود؟';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'عادت از آرشیو خارج شود؟';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'عادت حذف شود؟';

  @override
  String get habitDetail_summary_title => 'خلاصه';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'امتیاز فعلی $score است و از شروع عادت $days روز گذشته است.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'شروع در $days روز.',
      one: 'از فردا شروع می‌شود.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'ناکافی',
      one: 'تکمیل نشده',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'بی‌نقص',
      one: 'بیش از انتظار',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'هدف',
      two: 'آستانه',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'واحد: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'ندارد';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'روز',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'روز';

  @override
  String get habitDetail_descRecordsNum_titleText => 'رکوردها';

  @override
  String get habitDetail_scoreChart_title => 'امتیاز';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'روز';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'هفته';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'ماه';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'سال';

  @override
  String get habitDetail_freqChart_freqTitle => 'تناوب';

  @override
  String get habitDetail_freqChart_historyTitle => 'تاریخچه';

  @override
  String get habitDetail_freqChart_combinedTitle => 'تناوب و تاریخچه';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'هفته';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'ماه';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'سال';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'اکنون';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'پنهان سازی جدول تاریخچه';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'نمایش جدول تاریخچه';

  @override
  String get habitDetail_descSubgroup_title => 'یادداشت';

  @override
  String get habitDetail_otherSubgroup_title => 'متفرقه';

  @override
  String get habitDetail_habitType_title => 'نوع';

  @override
  String get habitDetail_reminderTile_title => 'یادآور';

  @override
  String get habitDetail_freqTile_title => 'تکرار';

  @override
  String get habitDetail_startDateTile_title => 'تاریخ شروع';

  @override
  String get habitDetail_createDateTile_title => 'ایجاد شده';

  @override
  String get habitDetail_modifyDateTile_title => 'ویرایش شده';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'تاریخ';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'مقدار';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'بازگشت به امروز';

  @override
  String get common_loadError_text => 'Failed to load';

  @override
  String get common_loadError_retryText => 'تلاش مجدد';

  @override
  String get habitDetail_notFoundText => 'بارگذاری عادت ناموفق بود';

  @override
  String get habitDetail_notFoundRetryText => 'تلاش مجدد';

  @override
  String get habitDetail_changeGoal_title => 'تغییر هدف';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'فعلی: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'انجام شد: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'انجام نشده';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'هدف روزانه، پیش‌فرض: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'لغو';

  @override
  String get habitDetail_changeGoal_saveText => 'ذخیره';

  @override
  String get habitDetail_skipReason_title => 'علت رد کردن';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'در اینجا چیزی بنویسید...';

  @override
  String get habitDetail_skipReason_cancelText => 'لغو';

  @override
  String get habitDetail_skipReason_saveText => 'ذخیره';

  @override
  String get appSetting_appbar_titleText => 'تنظیمات';

  @override
  String get appSetting_displaySubgroupText => 'نمایش';

  @override
  String get appSetting_operationSubgroupText => 'عملیات';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'جابجایی تقویم صفحه‌ای';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'در صورت فعال بودن این گزینه، تقویم نوار برنامه در صفحه اصلی صفحه به صفحه جابجا می‌شود. پیش‌فرض این گزینه غیرفعال است.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'تغییر وضعیت رکورد';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'اصلاح رفتار کلیک برای تغییر وضعیت سوابق روزانه در صفحه اصلی.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'باز کردن رکورد تفصیلی';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'اصلاح رفتار کلیک برای باز کردن پاپ آپ دقیق برای سوابق روزانه در صفحه اصلی.';

  @override
  String get appSetting_expandTimerDelayTile_titleText => 'Group expand delay';

  @override
  String get appSetting_expandTimerDelayTile_subtitleText =>
      'Set how long to hover over a collapsed group header before it auto-expands during drag-and-drop.';

  @override
  String get appSetting_expandTimerDelay_default => 'Default';

  @override
  String get appSetting_expandTimerDelay_fast => 'Fast';

  @override
  String get appSetting_expandTimerDelay_slow => 'Slow';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Theme Color';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'Choose Theme Color';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Use wallpaper\'s main color (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'Use GTK+ theme\'s selected background color';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Use system theme color';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Use system accent or window/glass color';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'اولین روز هفته';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'نمایش اولین روز هفته';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (پیش‌فرض)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Follow System ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'پیروی از سامانه';

  @override
  String get appSetting_changeLanguageTile_titleText => 'زبان';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'گزیدن زبان';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'فرمت نمایش تاریخ ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'پیروی از تنظیمات سیستم';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'فرمت‌بندی تاریخ پیکربندی شده بر روی نمایش تاریخ در صفحه جزئیات عادت اعمال خواهد شد.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'فعال‌سازی رابط کاربری کم‌حجم در صفحه عادت‌ها';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'اجازه دهید جدول بررسی عادت‌ها بیشترین محتوا را نشان دهد، اما برخی از رابط کاربری و متن‌ها به صورت کوچکتر نمایش داده می‌شود.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'تنظیمات نسبت محیط بررسی عادت‌ها';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'تنظیم درصد بیشتر / کمتر بودن فضای موجود در جدول بررسی عادت‌ها.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'پیش‌فرض';

  @override
  String get appSetting_reminderSubgroupText => 'یادآور';

  @override
  String get appSetting_dailyReminder_titleText => 'یادآور روزانه';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'پشتیبان‌گیری و بازیابی';

  @override
  String get appSetting_export_titleText => 'خروجی';

  @override
  String get appSetting_export_subtitleText =>
      'عادت‌ها به عنوان فرمت JSON خروجی داده می‌شود. این پرونده می‌تواند بعداً وارد شود.';

  @override
  String get appSetting_import_titleText => 'ورود';

  @override
  String get appSetting_import_subtitleText =>
      'عادت‌ها را از پرونده JSON وارد کنید.';

  @override
  String get appSetting_thirdPartyImport_titleText => 'Import from third-party';

  @override
  String get appSetting_thirdPartyImport_subtitleText =>
      'Import habits from other habit tracker apps';

  @override
  String get appSetting_thirdPartyImport_provider_loopName =>
      'Loop Habit Tracker';

  @override
  String get appSetting_thirdPartyImport_provider_versionHint =>
      'Supports CSV (tested up to <ver/>)';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'تأیید وارد کردن $count عادت؟';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'توجه: وارد کردن ، عادت‌های موجود را حذف نمی‌کند.';

  @override
  String get appSetting_importDialog_option_includeHabits => 'Include habits';

  @override
  String get appSetting_importDialog_option_includeGroups => 'Include groups';

  @override
  String appSetting_importDialog_tile_includeHabits(int count) {
    return 'Include $count habits';
  }

  @override
  String appSetting_importDialog_tile_includeGroups(int count) {
    return 'Include $count groups';
  }

  @override
  String appSetting_importConfirmDialog_sourceLabel(String provider) {
    return 'Source: $provider';
  }

  @override
  String get appSetting_thirdPartyImport_error_fileReadError =>
      'Failed to read the selected file.';

  @override
  String get appSetting_thirdPartyImport_error_noHabitsFound =>
      'No habits found in the import file.';

  @override
  String get appSetting_thirdPartyImport_error_parseError =>
      'Failed to parse import file';

  @override
  String get appSetting_thirdPartyImport_error_unknown =>
      'An unexpected error occurred during import.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'تأیید';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'لغو';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'ورود شده $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'ورودی کامل $count';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Completed import $count groups';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'بستن';

  @override
  String get appSetting_resetConfig_titleText => 'بازنشانی تنظیمات';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'بازنشانی تمام تنظیمات به حالت پیش‌فرض.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'تنظیمات بازنشانی شود؟';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'تمام تنظیمات به حالت پیش‌فرض بازنشانی شوند؟ برای اعمال این تغییرات، باید برنامه را مجدداً راه‌اندازی کنید.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'لغو';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'تأیید';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'بازنشانی تنظیمات برنامه با موفقیت انجام شد';

  @override
  String get appSetting_otherSubgroupText => 'سایر';

  @override
  String get appSetting_developMode_titleText => 'حالت توسعه';

  @override
  String get appSetting_clearCache_titleText => 'پنهان کردن';

  @override
  String get appSetting_clearCacheDialog_titleText => 'پنهان کردن';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'پس از پاک کردن حافظه، برخی از ارزش های سفارشی به طور پیش فرض بازسازی می شوند.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'لغو';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'تایید';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'پنهان کردن جزئی که شکست خورد';

  @override
  String get appSetting_clearCache_snackBar_succText => 'پنهان کردن با موفقیت';

  @override
  String get appSetting_clearCache_snackBar_failText => 'پنهان کردن شکست خورده';

  @override
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'درباره';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Experimental Features';

  @override
  String get appSetting_synSubgroupText => 'Sync';

  @override
  String get appSetting_syncOption_titleText => 'Sync Options';

  @override
  String get appSetting_notify_titleTile => 'Notifications';

  @override
  String get appSetting_notify_subtitleTile =>
      'Manage notification preferences';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Tap to open system notification settings';

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
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
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
  String get appSync_webdav_newServerConfirmDialog_titleText => 'New Location';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Syncing will create necessary directories and upload local habits to the server. Continue?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText => 'Sync Now!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText => 'Confirm Sync';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Directory isn\'t empty. Syncing will merge server and local habits. Continue?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Confirm Merge';

  @override
  String get appSync_exportAllLogsTile_titleText => 'Export Failed Sync Logs';

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
      'manual': 'Manual',
      'minute5': '5 Minutes',
      'minute15': '15 Minutes',
      'minute30': '30 Minutes',
      'hour1': '1 Hour',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Fetch Interval';

  @override
  String get appSync_summaryTile_title => 'Sync Server';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Not Configured';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'All recent failed sync logs';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Confirm Save Changes';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Saving will overwrite previous server configuration.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'Unsaved Changes';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Exiting will discard all unsaved changes.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Confirm Delete';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Deleting will remove current server config.';

  @override
  String get appSync_serverEditor_titleText_add => 'New Sync Server';

  @override
  String get appSync_serverEditor_titleText_modify => 'Modify Sync Server';

  @override
  String get appSync_serverEditor_advance_titleText => 'Advanced Configs';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Path';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Enter a valid WebDAV path here.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Path shouldn\'t be empty!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Username';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Enter username here, leave empty if not required.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Password';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Ignore SSL Certificate';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Sync Timeout Seconds';

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
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Network Connection Timeout Seconds';

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
    return 'Default: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Network Connection Retry Count';

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
  String get appSync_noti_readyToSync_body => 'Preparing to sync...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Synced ($type)',
      'failed': 'Sync Failed ($type)',
      'other': 'Syncing ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Sync in Low Data Mode';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'One or more experimental features are enabled, Use with caution.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText => 'Habit Cloud Sync';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Once enabled, the app\'s sync option will appear in settings';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Experimental feature ($syncName) is disabled, but the function is still running.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'To completely disable, long press to access \'$menuName\' and turn it off.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'Habit Search';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Once enabled, a search bar will appear at the top of the Habits screen and allowing to search habits.';

  @override
  String get appAbout_appbarTile_titleText => 'درباره';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'نسخه: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'کد منبع';

  @override
  String get appAbout_issueTrackerTile_titleText => 'پیگیری مشکلات';

  @override
  String get appAbout_contactEmailTile_titleText => 'تماس با من';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'سلام، خوشحالم که با من تماس گرفتید.\nاگر یک باگ گزارش می‌دهید، لطفاً نسخه برنامه را مشخص کنید و مراحل تکرار آن را توصیف کنید.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'لایسنس';

  @override
  String get appAbout_licenseTile_subtitleText => 'لایسنس آپاچی، نسخه 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'بیانیه لایسنس‌های شخص ثالث';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'فلاتر';

  @override
  String get appAbout_privacyTile_titleText => 'Privacy';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Access the privacy policy in this app';

  @override
  String get appAbout_donateTile_titleText => 'حمایت مالی';

  @override
  String get appAbout_donateTile_subTitleText =>
      'من یک توسعه‌دهنده شخصی هستم. اگر از این برنامه خوشتان آمده، لطفاً یک فنجان قهوه برایم بخرید ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'پی‌پال';

  @override
  String get donateWay_buyMeACoffee => 'یک فنجان قهوه برایم بخرید';

  @override
  String get donateWay_alipay => 'آلی‌پِی';

  @override
  String get donateWay_wechatPay => 'پرداخت ویچت';

  @override
  String get donateWay_cryptoCurrency => 'رمزارز';

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
    return 'کپی شد $name آدرس';
  }

  @override
  String get batchCheckin_appbar_title => 'بررسی دسته‌ای';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'روز قبلی';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'روز بعدی';

  @override
  String get batchCheckin_status_skip_text => 'رد';

  @override
  String get batchCheckin_status_ok_text => 'تکمیل شده';

  @override
  String get batchCheckin_status_double_text => 'دو برابر!';

  @override
  String get batchCheckin_status_zero_text => 'ناتکمیل';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    return 'انتخاب شده $count عادت';
  }

  @override
  String get batchCheckin_save_button_text => 'ذخیره';

  @override
  String get batchCheckin_reset_button_text => 'بازنشانی';

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
  String get batchCheckin_save_confirmDialog_title => 'بازنویسی رکوردهای موجود';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'رکوردهای موجود پس از ذخیره بازنویسی می‌شوند. رکوردهای قبلی از دست خواهند رفت.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'ذخیره';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'لغو';

  @override
  String get batchCheckin_close_confirmDialog_title => 'تأیید بازگشت';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'تغییرات وضعیت چکین‌کردن قبل از ذخیره اعمال نخواهد شد.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'خروج';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'لغو';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 آیا امروز به عادت‌های خود پایبند بوده‌اید؟';

  @override
  String get appReminder_dailyReminder_body =>
      'برای ورود به برنامه و انجام به موقع عادت‌ها کلیک کنید.';

  @override
  String get common_habitColorType_cc1 => 'بنفش عمیق';

  @override
  String get common_habitColorType_cc2 => 'قرمز';

  @override
  String get common_habitColorType_cc3 => 'بنفش';

  @override
  String get common_habitColorType_cc4 => 'آبی سلطنتی';

  @override
  String get common_habitColorType_cc5 => 'پیروزه‌ای تیره';

  @override
  String get common_habitColorType_cc6 => 'سبز';

  @override
  String get common_habitColorType_cc7 => 'کهربایی';

  @override
  String get common_habitColorType_cc8 => 'نارنجی';

  @override
  String get common_habitColorType_cc9 => 'سبز لیمویی';

  @override
  String get common_habitColorType_cc10 => 'بنفش تیره';

  @override
  String get common_habitColorType_custom => 'Custom';

  @override
  String common_habitColorType_default(int index) {
    return 'رنگ $index';
  }

  @override
  String get common_appThemeColor_system => 'System';

  @override
  String get common_appThemeColor_primary => 'Primary';

  @override
  String get common_appThemeColor_dynamic => 'Dynamic';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'استفاده از فرمت سیستم';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'فرمت تاریخ';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'سال ماه روز';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'ماه روز سال';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'روز ماه سال';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'جداکننده';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'خط تیره';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'خط کمانی';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'فاصله';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'نقطه';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'بدون جداکننده';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'استفاده از فرمت 12 ساعتی';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'استفاده از نام کامل';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'اعمال برای نمودار فراوانی';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'اعمال برای تقویم';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'لغو';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'تأیید';

  @override
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

  @override
  String get common_dontShowAgain => 'Don\'t show again';

  @override
  String get calendarPicker_clip_today => 'امروز';

  @override
  String get calendarPicker_clip_tomorrow => 'فردا';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'بعد از $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'آیا می‌خواهید از تمام عادت‌ها خروجی گرفته شود؟';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number عادت',
      one: 'یک عادت',
      zero: 'عادت فعلی',
    );
    return 'آیا می‌خواهید $_temp0 را خروجی گرفته شود؟';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'شامل رکوردها';

  @override
  String get exportConfirmDialog_option_includeGroups => 'include groups';

  @override
  String exportConfirmDialog_tile_includeRecords(int count) {
    return 'Include $count records';
  }

  @override
  String exportConfirmDialog_tile_includeGroups(int count) {
    return 'Include $count groups';
  }

  @override
  String get exportConfirmDialog_cancel_buttonText => 'لغو';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'خروجی گرفتن';

  @override
  String get debug_logLevelTile_title => 'Logging Level';

  @override
  String get debug_logLevelDialog_title => 'Change Logging Level';

  @override
  String get debug_logLevel_debug => 'Debug';

  @override
  String get debug_logLevel_info => 'گزارش';

  @override
  String get debug_logLevel_warn => 'هشدار';

  @override
  String get debug_logLevel_error => 'ایرنگ';

  @override
  String get debug_logLevel_fatal => 'Fatal';

  @override
  String get debug_collectLogTile_title => 'Collecting Logs';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Tap to stop logging collection.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Tap to start logging collection.';

  @override
  String get debug_downladDebugLogs_subject => 'Downloading debugging logs';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Debugging logs Cleared.';

  @override
  String get debug_downladDebugInfo_subject =>
      'Downloading debugging information';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Downloading $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Debug log doesn\'t exist.';

  @override
  String get debug_debuggerLogCard_title => 'Logging Information';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Includes local debugging log information, need to turn on the log collection switcher.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Download';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Clear';

  @override
  String get debug_debuggerInfoCard_title => 'Debugging Information';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Includes app\'s debugging information.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Open';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Save';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Collecting App\'s Info...';

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
  String get confirmDialog_cancel_text => 'Cancel';

  @override
  String get snackbar_undoText => 'بازگشت';

  @override
  String get snackbar_dismissText => 'رد کردن';

  @override
  String get contributors_tile_title => 'مشارکت کنندگان';

  @override
  String get userAction_tap => 'ضربه';

  @override
  String get userAction_doubleTap => 'دوتایی';

  @override
  String get userAction_longTap => 'طولانی';

  @override
  String get channelName_habitReminder => 'Habit Reminder';

  @override
  String get channelName_appReminder => 'Prompt';

  @override
  String get channelName_appDebugger => 'Debugger';

  @override
  String get channelName_appSyncing => 'Sync Process';

  @override
  String get channelDesc_appSyncing =>
      'Used to show sync progress and non-failure results';

  @override
  String get channelName_appSyncFailed => 'Sync Failed';

  @override
  String get channelDesc_appSyncFailed => 'Used to alert when sync fails';

  @override
  String changelog_banner_title(String version) {
    return 'What\'s New in v$version';
  }

  @override
  String get changelog_banner_action => 'CLOSE';

  @override
  String get changelog_banner_view => 'VIEW';

  @override
  String get changelog_dialog_title => 'Changelog';

  @override
  String get changelog_view_full => 'View Full Changelog';

  @override
  String get habitGroup_uncategorized => 'No Group';

  @override
  String get habitDetail_groupTile_title => 'Group';

  @override
  String get habitEdit_groupTile_title => 'Group';

  @override
  String get habitEdit_groupPicker_hintText => 'Search or create group';

  @override
  String get habitEdit_groupPicker_noGroup => 'No Group';

  @override
  String habitEdit_groupPicker_createGroup(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get habitEdit_groupPicker_loading => 'Loading groups…';

  @override
  String get groupManage_appbar_title => 'Manage Groups';

  @override
  String groupManage_selectionAppbar_title(int count) {
    return '$count selected';
  }

  @override
  String get groupManage_emptyState_text =>
      'No groups yet\nTap + to create your first group';

  @override
  String get groupManage_deleteDialog_title => 'Delete Group';

  @override
  String groupManage_deleteDialog_content(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habits in these $count groups will become uncategorized.',
      one: 'Habits in this group will become uncategorized.',
    );
    return '$_temp0';
  }

  @override
  String get groupManage_deleteDialog_confirm => 'حذف';

  @override
  String get groupManage_deleteDialog_cancel => 'Cancel';

  @override
  String get groupManage_deleted_snackbarText => 'Group deleted';

  @override
  String get groupManage_undo_snackbarAction => 'Undo';

  @override
  String get groupManage_editDialog_title => 'Edit Group';

  @override
  String get groupManage_createDialog_title => 'Create Group';

  @override
  String get groupManage_nameRequired => 'Name is required';

  @override
  String groupManage_nameTooLong(int max) {
    return 'Name must be ≤ $max characters';
  }

  @override
  String get groupManage_name_label => 'بر اساس نام';

  @override
  String get groupManage_desc_label => 'Description';

  @override
  String groupManage_descTooLong(int max) {
    return 'Description should be ≤ $max characters';
  }

  @override
  String get groupManage_sortTile_text => 'Sort Groups';

  @override
  String get groupManage_sectionTitle_text => 'Groups';

  @override
  String get groupManage_createDateTile_title => 'ایجاد شده';

  @override
  String get groupManage_modifyDateTile_title => 'ویرایش شده';

  @override
  String get groupManage_icon_label => 'Icon';

  @override
  String get groupManage_icon_none => 'ندارد';

  @override
  String get groupManage_color_label => 'بر اساس رنگ';

  @override
  String get groupManage_color_none => 'ندارد';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Create, edit, and delete habit groups';
}
