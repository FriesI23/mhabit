// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class L10nAr extends L10n {
  L10nAr([String locale = 'ar']) : super(locale);

  @override
  String get localeScriptName => 'العربية';

  @override
  String get appName => 'جدول العادات';

  @override
  String get habitEdit_saveButton_text => 'حفظ';

  @override
  String get habitEdit_habitName_hintText => 'اسم العادة ...';

  @override
  String get habitEdit_colorPicker_title => 'اختر لوناً';

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
  String get habitEdit_habitTypeDialog_title => 'نوع العادة';

  @override
  String get habitEdit_habitType_positiveText => 'إيجابي';

  @override
  String get habitEdit_habitType_negativeText => 'سلبي';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'هدف العادة اليومي، فرضاً $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'حد العادة السيئة، فرضاً $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'الهدف اليومي يجب أن يكون > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'الهدف اليومي يجب أن يكون ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'الهدف اليومي يجب أن يكون ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'الهدف اليومي يجب أن يكون ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'الهدف اليومي';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'الهدف اليومي الأعلى';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'القيمة غير صحيحة، أتركه فارغاً أو ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'الحد اليومي الأعلى';

  @override
  String get habitEdit_frequencySelector_title => 'اختر مدى التكرار';

  @override
  String get habitEdit_habitFreq_daily => 'يومياً';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% مرة في الأسبوع';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% مرة في الشهر';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% مرة خلال %%day%% يومًا';

  @override
  String get habitEdit_habitFreq_show_daily => 'يومياً';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'على الأقل $freq مرات في الأسبوع',
      one: 'Per week',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'على الأقل $freq مرات شهر',
      one: 'شهريًا',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'على الأقل $freq مرات في كل $days أيام',
      one: 'في كل $days days',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays يوماً';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'اختر الأيام';

  @override
  String get habitEdit_targetDays => 'أيام';

  @override
  String get habitEdit_reminder_hintText => 'تذكير';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'أي يوم في الأسبوع';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return 'كل أسبوع $days •في كل أسبوع';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'أي يوم في الشهر';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return 'كل شهر $days •في كل شهر';
  }

  @override
  String get habitEdit_reminderQuest_hintText => 'سؤال، مثلاً: هل تمرنت اليوم؟';

  @override
  String get habitEdit_reminder_dialogTitle => 'اختر نوع التذكير';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'قبل أن أبدأ';

  @override
  String get habitEdit_reminder_dialogType_daily => 'يومياً';

  @override
  String get habitEdit_reminder_dialogType_week => 'أسبوعياً';

  @override
  String get habitEdit_reminder_dialogType_month => 'شهرياً';

  @override
  String get habitEdit_reminder_dialogConfirm => 'تأكيد';

  @override
  String get habitEdit_reminder_dialogCancel => 'إلغاء';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'تأكيد';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'هل تؤكد على حذف هذا التذكير';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'تأكيد';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'إلغاء';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'إثنين';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'ثلاثاء';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'أربعاء';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'خميس';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'جمعة';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'سبت';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'أحد';

  @override
  String get habitEdit_desc_hintText => 'ملاحظات وتفاصيل محفزة';

  @override
  String get habitEdit_create_datetime_prefix => 'تم إنشائها: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'معدلة: ';

  @override
  String get habitDisplay_fab_text => 'عادة جديدة';

  @override
  String get habitDisplay_emptyImage_text_01 => 'رحلة الألف ميل تبدأ بخطوة';

  @override
  String get habitDisplay_notFoundImage_text_01 =>
      'لم يتم العثور على عادات مطابقة';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'لا توجد عادات مطابقة لـ ”$keyword“';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'أرشفة العادات المحددة؟';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'إلغاء';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'المؤرشفة $count العادات';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'عدم أرشفة العادات المحددة؟';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'إلغاء';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'غير المؤرشفة $count العادات';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'حذف العادات المحددة؟';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'إلغاء';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'محذوفة $count العادات';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'تم حذف العادة: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' $count عادة/عادات مصدرة .',
      one: 'عادة مصدرة.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'صٌدرت جميع العادات';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'اختيار الكل';

  @override
  String get habitDisplay_editPopMenu_export => 'تصدير';

  @override
  String get habitDisplay_editPopMenu_delete => 'حذف';

  @override
  String get habitDisplay_editPopMenu_clone => 'استنساخ';

  @override
  String get habitDisplay_editButton_tooltip => 'تعديل';

  @override
  String get habitDisplay_archiveButton_tooltip => 'أرشفة';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'عدم أرشفة';

  @override
  String get habitDisplay_settingButton_tooltip => 'الإعدادات';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'حالية';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'مكتملة';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'تحت التنفيذ';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'مؤرشفة';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'العادات الأبرز: تغييرات آخر 30 يوم';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'عرض خفيف';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'عرض داكن';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'مطابقة نظام الجهاز';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'أظهر المؤرشفة';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'أظهر المكتملة';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'أظهر النشطة';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'الإعدادات';

  @override
  String get habitDisplay_groupType_name => 'بالاسم';

  @override
  String get habitDisplay_groupType_colorType => 'باللون';

  @override
  String get habitDisplay_groupType_createDate => 'By Creation Date';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Group Sort';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'إلغاء';

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
  String get habitDisplay_sort_reverseText => 'عكس';

  @override
  String get habitDisplay_sortDirection_asc => '(تصاعدي)';

  @override
  String get habitDisplay_sortDirection_Desc => '(تنازلي)';

  @override
  String get habitDisplay_sortType_manual => 'ترتيبي';

  @override
  String get habitDisplay_sortType_name => 'بالاسم';

  @override
  String get habitDisplay_sortType_colorType => 'باللون';

  @override
  String get habitDisplay_sortType_progress => 'بالتقييم';

  @override
  String get habitDisplay_sortType_startT => 'بتاريخ البداية';

  @override
  String get habitDisplay_sortType_status => 'بالحالة';

  @override
  String get habitDisplay_sortTypeDialog_title => 'فرز';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'إلغاء';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️فحص';

  @override
  String get habitDisplay_searchBar_hintText => 'البحث عن العادات';

  @override
  String get habitDisplay_searchFilter_ongoing => 'جارية';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'يعرض العادات النشطة والجارية حاليًا (غير المؤرشفة أو المحذوفة).';

  @override
  String get habitDisplay_searchFilter_completed => 'مكتملة';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'نوع العادة';

  @override
  String get habitDisplay_searchFilter_tooltips => 'عرض المرشحات';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'مسح المرشحات';

  @override
  String get habitDisplay_tab_habits_label => 'العادات';

  @override
  String get habitDisplay_tab_today_label => 'اليوم';

  @override
  String get habitToday_appBar_title => 'اليوم';

  @override
  String get habitToday_image_desc => 'تهانينا لقد حققت الهدف';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'استمر في ذلك لمدة $days أيام';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'تم+';

  @override
  String get habitToday_card_skipPlusButton_label => 'تخطي+';

  @override
  String get habitDetail_editButton_tooltip => 'تحرير';

  @override
  String get habitDetail_editPopMenu_unarchive => 'عدم أرشفة';

  @override
  String get habitDetail_editPopMenu_archive => 'أرشفة';

  @override
  String get habitDetail_editPopMenu_export => 'تصدير';

  @override
  String get habitDetail_editPopMenu_delete => 'حذف';

  @override
  String get habitDetail_editPopMenu_clone => 'قالب';

  @override
  String get habitDetail_confirmDialog_confirm => 'تأكيد';

  @override
  String get habitDetail_confirmDialog_cancel => 'إلغاء';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'أرشفة العادات؟';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'عدم أرشفة العادات';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'حذف العادات؟';

  @override
  String get habitDetail_summary_title => 'ملخص';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'درجتك الحالية $score، وقد مضى $days أيام منذ البدء.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Start in $days أيام.',
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
    return 'الوحدة: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'خالي';

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
  String get habitDetail_descTargetDays_unitText => 'ي';

  @override
  String get habitDetail_descRecordsNum_titleText => 'سجلات';

  @override
  String get habitDetail_scoreChart_title => 'درجة';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'يوم';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'أسبوع';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'شهر';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'سنة';

  @override
  String get habitDetail_freqChart_freqTitle => 'تكرار';

  @override
  String get habitDetail_freqChart_historyTitle => 'تاريخ';

  @override
  String get habitDetail_freqChart_combinedTitle => 'التكرار والتاريخ';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'أسبوع';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'شهر';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'سنة';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'الآن';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'أخف جدول التاريخ';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'اعرض جدول التاريخ';

  @override
  String get habitDetail_descSubgroup_title => 'ملاحظة';

  @override
  String get habitDetail_otherSubgroup_title => 'أخرى';

  @override
  String get habitDetail_habitType_title => 'نوع';

  @override
  String get habitDetail_reminderTile_title => 'تذكير';

  @override
  String get habitDetail_freqTile_title => 'تكرار';

  @override
  String get habitDetail_startDateTile_title => 'تاريخ البداية';

  @override
  String get habitDetail_createDateTile_title => 'أنشئت';

  @override
  String get habitDetail_modifyDateTile_title => 'عدلت';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'تاريخ';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'قيمة';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'العودة إلى اليوم';

  @override
  String get common_loadError_text => 'Failed to load';

  @override
  String get common_loadError_retryText => 'حاول مرة أخرى';

  @override
  String get habitDetail_notFoundText => 'فشل تحميل العادات';

  @override
  String get habitDetail_notFoundRetryText => 'حاول مرة أخرى';

  @override
  String get habitDetail_changeGoal_title => 'تغيير الهدف';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'حالياً: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'اكتمل: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'لم يكتمل';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'الهدف اليومي، فرضاً: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'إلغاء';

  @override
  String get habitDetail_changeGoal_saveText => 'حفظ';

  @override
  String get habitDetail_skipReason_title => 'تخطي السبب';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'أكتب شيئاً هنا...';

  @override
  String get habitDetail_skipReason_cancelText => 'إلغاء';

  @override
  String get habitDetail_skipReason_saveText => 'حفظ';

  @override
  String get appSetting_appbar_titleText => 'الإعدادات';

  @override
  String get appSetting_displaySubgroupText => 'عرض';

  @override
  String get appSetting_operationSubgroupText => 'العمليات';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'استعرض التقويم كصفحة';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'إذا تم تفعيل الخاصية، فسيكون استعراض قائمة التقويم بسحبها صفحة صفحة. الوضع الافتراضي أنها غير مفعلة.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'غير حالة السجلات';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'تعديل أسلوب الضغط لتغيير حالة التقرير في الصفحة الرئيسية.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'استعرض السجل التفصيلي';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'تعديل أسلوب الضغط لعرض التقرير اليومي التفصيلي في الصفحة الرئيسية.';

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
  String get appSetting_appThemeColorTile_titleText => 'لون المظهر';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'اختر لون المظهر';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'استخدام اللون الرئيسي للخلفية (Android 12 وما فوق)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'استخدام لون الخلفية المحدد في سمة GTK+';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'استخدام لون سمة النظام';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'استخدام لون النظام أو لون النافذة/الزجاج';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'أول يوم في الأسبوع';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'أظهر أول يوم في الأسبوع';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' •(افتراضي)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'اتباع النظام ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'اتباع النظام';

  @override
  String get appSetting_changeLanguageTile_titleText => 'اللغة';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'اختر اللغة';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'طريقة عرض التاريخ ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'مطابقة إعدادات الجهاز';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'سيتم تطبيق تنسيق التاريخ في صفحة العادة التفصيلية';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'تفعيل العرض المبسط في صفحة العادات';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'السماح بعرض مزيد من المحتوى في جدول التأكيد، ولكن ستظهر بعض النصوص بحجم أصغر.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'تعديل زر تنفيذ العادة';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'عدل النسبة لمساحة أكبر/أصغر في جدول التأكيد';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'افتراضي';

  @override
  String get appSetting_reminderSubgroupText => 'تذكير وإشعار';

  @override
  String get appSetting_dailyReminder_titleText => 'التذكير اليومي';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'الحفظ والاستعادة';

  @override
  String get appSetting_export_titleText => 'تصدير';

  @override
  String get appSetting_export_subtitleText =>
      'تصدير العادات كملف JSON، بالإمكان استيراد هذا الملف مرة أخرى.';

  @override
  String get appSetting_import_titleText => 'استيراد';

  @override
  String get appSetting_import_subtitleText => 'استيراد العادات من ملف JSON';

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
    return 'تأكيد استيراد $count العادات؟';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'ملاحظة: الاستيراد لا يحذف العادات الموجودة.';

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
  String get appSetting_importDialog_confirm_confirmText => 'تأكيد';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'إلغاء';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'تم الاستيراد $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'اكتمل استيراد $count';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Completed import $count groups';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'إغلاق';

  @override
  String get appSetting_resetConfig_titleText => 'استعادة الاعدادات';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'استعادة كافة الإعدادات الافتراضية.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'استعادة الاعدادات؟';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'استعادة كامل الاعدادات الافتراضية، يلزم إعادة تشغيل التطبيق.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'إلغاء';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'تأكيد';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'تمت استعادة إعدادات التطبيق';

  @override
  String get appSetting_otherSubgroupText => 'أخرى';

  @override
  String get appSetting_developMode_titleText => 'وضع التطوير';

  @override
  String get appSetting_clearCache_titleText => 'حذف التخزين المؤقت';

  @override
  String get appSetting_clearCacheDialog_titleText => 'حذف التخزين المؤقت';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'بعد حذف التخزين المؤقت، بعض القيم المعدلة ستعود للقيم الافتراضية.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'إلغاء';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'تأكيد';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'فشل حذف التخزين المؤقت جزئياً';

  @override
  String get appSetting_clearCache_snackBar_succText => 'تم حذف التخزين المؤقت';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'فشل حذف التخزين المؤقت';

  @override
  String get appSetting_debugger_titleText => 'معلومات التصحيح';

  @override
  String get appSetting_about_titleText => 'عن';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'الميزات التجريبية';

  @override
  String get appSetting_synSubgroupText => 'المزامنة';

  @override
  String get appSetting_syncOption_titleText => 'خيارات المزامنة';

  @override
  String get appSetting_notify_titleTile => 'الإشعارات';

  @override
  String get appSetting_notify_subtitleTile => 'إدارة تفضيلات الإشعارات';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'اضغط لفتح إعدادات إشعارات النظام';

  @override
  String get appSync_nowTile_titleText => 'مزامنة الآن';

  @override
  String get appSync_nowTile_titleText_syncing => 'جاري المزامنة';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'آخر مزامنة: غير متوفر';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'آخر مزامنة: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate => 'آخر مزامنة (خطأ): غير متوفر';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'آخر مزامنة (خطأ): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'جاري المزامنة...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'جاري المزامنة: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'جاري الإلغاء...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'آخر مزامنة (ملغاة): غير متوفر';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'آخر مزامنة (ملغاة): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'تحقق من سجلات الفشل';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[خطأ]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'مكتمل',
      'cancelled': 'ملغى',
      'failed': 'فشل',
      'multi': 'حالات متعددة',
      'other': 'حالة غير معروفة',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'مكتمل بسبب $reason',
      'cancelled': 'ملغى بسبب $reason',
      'failed': 'فشل بسبب $reason',
      'multi': 'حالات متعددة بسبب $reason',
      'other': 'حالة غير معروفة',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'خطأ',
      'userAction': 'يتطلب إجراء من المستخدم',
      'missingHabitUuid': 'معرف العادة مفقود',
      'empty': 'بيانات فارغة',
      'other': 'سبب غير معروف',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'موقع جديد';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'ستقوم المزامنة بإنشاء الدلائل الضرورية وتحميل العادات المحلية إلى الخادم. هل تريد المتابعة؟';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'مزامنة الآن!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'تأكيد المزامنة';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'الدليل ليس فارغًا. ستدمج المزامنة العادات الموجودة على الخادم والعادات المحلية. هل تريد المتابعة؟';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText => 'تأكيد الدمج';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'تصدير سجلات المزامنة الفاشلة';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'لم يتم العثور على سجلات',
      'false': 'انقر للتصدير',
      'other': 'جاري التحميل...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'الحالي: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'وهمي (للتصحيح فقط)',
      'other': 'غير معروف ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'شبكة الجوال',
      'wifi': 'واي فاي',
      'other': 'غير معروف',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'يدوي',
      'minute5': '5 دقائق',
      'minute15': '15 دقيقة',
      'minute30': '30 دقيقة',
      'hour1': '1 ساعة',
      'other': 'غير معروف',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'فاصل الجلب';

  @override
  String get appSync_summaryTile_title => 'خادم المزامنة';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured => 'غير مُعد';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'جميع سجلات المزامنة الفاشلة الأخيرة';

  @override
  String get appSync_serverEditor_saveDialog_titleText => 'تأكيد حفظ التغييرات';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'سيؤدي الحفظ إلى الكتابة فوق تكوين الخادم السابق.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'تغييرات غير محفوظة';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'سيؤدي الخروج إلى تجاهل جميع التغييرات غير المحفوظة.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'تأكيد الحذف';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'سيؤدي الحذف إلى إزالة تكوين الخادم الحالي.';

  @override
  String get appSync_serverEditor_titleText_add => 'خادم مزامنة جديد';

  @override
  String get appSync_serverEditor_titleText_modify => 'تعديل خادم المزامنة';

  @override
  String get appSync_serverEditor_advance_titleText => 'إعدادات متقدمة';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'المسار';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'أدخل مسار WebDAV صالح هنا.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'المسار لا يجب أن يكون فارغًا!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'اسم المستخدم';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'أدخل اسم المستخدم هنا، اتركه فارغًا إذا لم يكن مطلوبًا.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'كلمة المرور';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText => 'تجاهل شهادة SSL';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'مهلة المزامنة بالثواني';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'غير محدود',
    );
    return 'الافتراضي: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 'ثانية';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'مهلة اتصال الشبكة بالثواني';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'غير محدود',
    );
    return 'الافتراضي: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 'ثانية';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'عدد مرات إعادة محاولة اتصال الشبكة';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'إعادة المحاولة معطلة',
    );
    return 'الافتراضي: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText => 'وضع مزامنة الشبكة';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'مزامنة عبر شبكة الجوال',
      'wifi': 'مزامنة عبر واي فاي',
      'other': 'غير معروف',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'بيانات منخفضة';

  @override
  String get appSync_noti_readyToSync_body => 'التحضير للمزامنة...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'مزامنة ($type)',
      'failed': 'فشلت المزامنة ($type)',
      'other': 'مزامنة ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'المزامنة في وضع البيانات المنخفضة';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'تم تفعيل ميزة تجريبية واحدة أو أكثر، استخدم بحذر.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'مزامنة العادات السحابية';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'بمجرد التفعيل، سيظهر خيار المزامنة في إعدادات التطبيق';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'الميزة التجريبية ($syncName) معطلة، لكن الوظيفة لا تزال تعمل.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'للتعطيل الكامل، اضغط مطولًا للوصول إلى \'$menuName\' وإيقاف تشغيلها.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'البحث عن عادة';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'بمجرد التفعيل، سيظهر شريط بحث في أعلى شاشة العادات ويسمح بالبحث عن العادات.';

  @override
  String get appAbout_appbarTile_titleText => 'عن';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'الإصدار: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'الكود المصدري';

  @override
  String get appAbout_issueTrackerTile_titleText => 'تتبع الخلل';

  @override
  String get appAbout_contactEmailTile_titleText => 'تواصل معي';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'أهلاً، أنا سعيد بتواصلك.\nإذا كنت تود الإبلاغ عن مشكلة، أرجو منك تحديد النسخة وخطوات إظهار المشكلة.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'الترخيص';

  @override
  String get appAbout_licenseTile_subtitleText => 'تصريح أباتشي، النسخة 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'نص التصريح لطرف ثالث';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'فلتر';

  @override
  String get appAbout_privacyTile_titleText => 'الخصوصية';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'الوصول إلى سياسة الخصوصية في هذا التطبيق';

  @override
  String get appAbout_donateTile_titleText => 'تبرع';

  @override
  String get appAbout_donateTile_subTitleText =>
      '☕ أنا مبرمج شخصي، إذا أعجبك التطبيق، أرجوك أن تشتري لي قهوة';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'باي بال';

  @override
  String get donateWay_buyMeACoffee => 'باي مي كوفي';

  @override
  String get donateWay_alipay => 'علي بي';

  @override
  String get donateWay_wechatPay => 'ويشات بي';

  @override
  String get donateWay_cryptoCurrency => 'العملات الرقمية';

  @override
  String get donateWay_cryptoCurrency_BTC => 'بيتكوين';

  @override
  String get donateWay_cryptoCurrency_ETH => 'إيثريوم';

  @override
  String get donateWay_cryptoCurrency_BNB => 'بي إن بي';

  @override
  String get donateWay_cryptoCurrency_AVAX => 'أفاكس';

  @override
  String get donateWay_cryptoCurrency_FTM => 'إف تي إم';

  @override
  String get donateWay_firstQRGroup => 'مدفوعات ويشات وعلي بي';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'نسخ $name\'s عنوان';
  }

  @override
  String get batchCheckin_appbar_title => 'التحقق بالدُفعة';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'اليوم السابق';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'اليوم التالي';

  @override
  String get batchCheckin_status_skip_text => 'تخطى';

  @override
  String get batchCheckin_status_ok_text => 'اكتمل';

  @override
  String get batchCheckin_status_double_text => 'اكتمال مضاعف';

  @override
  String get batchCheckin_status_zero_text => 'غير مكتمل';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    return 'تم اختيار $count عادات';
  }

  @override
  String get batchCheckin_save_button_text => 'حفظ';

  @override
  String get batchCheckin_reset_button_text => 'إعادة تعيين';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حالة $count عادات',
      one: 'حالة العادة',
    );
    return 'تم تعديل $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'تجاوز السجلات الحالية';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'ستتم كتابة السجلات الحالية بعد الحفظ، وستفقد السجلات السابقة.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'حفظ';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'إلغاء';

  @override
  String get batchCheckin_close_confirmDialog_title => 'تأكيد العودة';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'لن يتم تطبيق تغييرات حالة التحقق إلا بعد الحفظ.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'خروج';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'إلغاء';

  @override
  String get appReminder_dailyReminder_title => '🏝 هل التزمت بعاداتك اليوم؟';

  @override
  String get appReminder_dailyReminder_body =>
      'اضغط للدخول إلى التطبيق والبدء.';

  @override
  String get common_habitColorType_cc1 => 'ليلكي';

  @override
  String get common_habitColorType_cc2 => 'أحمر';

  @override
  String get common_habitColorType_cc3 => 'بنفسجي';

  @override
  String get common_habitColorType_cc4 => 'أزرق ملكي';

  @override
  String get common_habitColorType_cc5 => 'لازوردي داكن';

  @override
  String get common_habitColorType_cc6 => 'أخضر';

  @override
  String get common_habitColorType_cc7 => 'عنبري';

  @override
  String get common_habitColorType_cc8 => 'برتقالي';

  @override
  String get common_habitColorType_cc9 => 'أخضر ليموني';

  @override
  String get common_habitColorType_cc10 => 'أوركيد داكن';

  @override
  String get common_habitColorType_custom => 'Custom';

  @override
  String common_habitColorType_default(int index) {
    return 'لون $index';
  }

  @override
  String get common_appThemeColor_system => 'النظام';

  @override
  String get common_appThemeColor_primary => 'الأساسي';

  @override
  String get common_appThemeColor_dynamic => 'حيوي';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'استخدم تنسيق الجهاز';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'تنسيق التاريخ';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'سنة شهر يوم';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'شهر يوم سنة';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'يوم شهر سنة';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'فاصل';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'خط';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'خط مائل';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'مسافة';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'نقطة';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'بدون فاصل';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'تنسيق 12 ساعة';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'استخدم الاسم الكامل';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'تطبيق على جدول التكرار';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'تطبيق على التقويم';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'إلغاء';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'تأكيد';

  @override
  String get common_errorPage_title => 'عذرًا، حدث خطأ!';

  @override
  String get common_errorPage_copied => 'تم نسخ معلومات الخطأ';

  @override
  String get common_enable_text => 'مُفعل';

  @override
  String get common_dontShowAgain => 'Don\'t show again';

  @override
  String get calendarPicker_clip_today => 'اليوم';

  @override
  String get calendarPicker_clip_tomorrow => 'غداً';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'التالي $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'تصدير كل العادات';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number عادات',
      one: '1 habit',
      zero: 'current habit',
    );
    return 'تصدير $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'تضمين السجلات';

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
  String get exportConfirmDialog_cancel_buttonText => 'إلغاء';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'تصدير';

  @override
  String get debug_logLevelTile_title => 'مستوى التسجيل';

  @override
  String get debug_logLevelDialog_title => 'تغيير مستوى التسجيل';

  @override
  String get debug_logLevel_debug => 'تصحيح';

  @override
  String get debug_logLevel_info => 'معلومات';

  @override
  String get debug_logLevel_warn => 'تحذير';

  @override
  String get debug_logLevel_error => 'خطأ';

  @override
  String get debug_logLevel_fatal => 'فادح';

  @override
  String get debug_collectLogTile_title => 'جمع السجلات';

  @override
  String get debug_collectLogTile_enable_subtitle => 'انقر لإيقاف جمع السجلات.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'انقر لبدء جمع السجلات.';

  @override
  String get debug_downladDebugLogs_subject => 'جاري تنزيل سجلات التصحيح';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'تم مسح سجلات التصحيح.';

  @override
  String get debug_downladDebugInfo_subject => 'جاري تنزيل معلومات التصحيح';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'جاري تنزيل $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'ملف سجل التصحيح غير موجود.';

  @override
  String get debug_debuggerLogCard_title => 'معلومات التسجيل';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'يتضمن معلومات سجل التصحيح المحلي، يحتاج إلى تفعيل مفتاح جمع السجلات.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'تنزيل';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'مسح';

  @override
  String get debug_debuggerInfoCard_title => 'معلومات التصحيح';

  @override
  String get debug_debuggerInfoCard_subtitle => 'يتضمن معلومات تصحيح التطبيق.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'فتح';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'حفظ';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'جاري جمع معلومات التطبيق...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'حفظ',
      'exit': 'خروج',
      'delete': 'حذف',
      'other': 'تأكيد',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'إلغاء';

  @override
  String get snackbar_undoText => 'تراجع';

  @override
  String get snackbar_dismissText => 'إلغاء';

  @override
  String get contributors_tile_title => 'المساهمون';

  @override
  String get userAction_tap => 'ضغطة';

  @override
  String get userAction_doubleTap => 'ضغطتين متتابعة';

  @override
  String get userAction_longTap => 'ضغطة طويلة';

  @override
  String get channelName_habitReminder => 'تذكير العادة';

  @override
  String get channelName_appReminder => 'تلميح';

  @override
  String get channelName_appDebugger => 'مصحح الأخطاء';

  @override
  String get channelName_appSyncing => 'عملية المزامنة';

  @override
  String get channelDesc_appSyncing =>
      'يستخدم لإظهار تقدم المزامنة والنتائج غير الفاشلة';

  @override
  String get channelName_appSyncFailed => 'فشلة المزامنة';

  @override
  String get channelDesc_appSyncFailed => 'يُستخدم للتنبيه عند فشل المزامنة';

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
  String get groupManage_deleteDialog_cancel => 'إلغاء';

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
  String get groupManage_name_label => 'بالاسم';

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
  String get groupManage_createDateTile_title => 'أنشئت';

  @override
  String get groupManage_modifyDateTile_title => 'عدلت';

  @override
  String get groupManage_icon_label => 'Icon';

  @override
  String get groupManage_icon_none => 'خالي';

  @override
  String get groupManage_color_label => 'باللون';

  @override
  String get groupManage_color_none => 'خالي';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Create, edit, and delete habit groups';
}
