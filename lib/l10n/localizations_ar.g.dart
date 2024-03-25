import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

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
  String get habitEdit_habitTypeDialog_title => 'نوع العادة';

  @override
  String get habitEdit_habitType_positiveText => 'إيجابي';

  @override
  String get habitEdit_habitType_negativeText => 'سلبي';

  @override
  String habitEdit_habitDailyGoal_hintText(Object number) {
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
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'الحد اليومي الأعلى';

  @override
  String get habitEdit_frequencySelector_title => 'اختر مدى التكرار';

  @override
  String get habitEdit_habitFreq_daily => 'يومياً';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'مرة في الأسبوع';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'مرة في الشهر';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'مرات في';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'أيام';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

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
      other: 'على الأقل $freq مرات في الشهر',
      one: 'Per month',
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
  String get habitEidt_targetDays_dialogTitle => 'اختر الأيام';

  @override
  String get habitEdit_targetDays => 'أيام';

  @override
  String get habitEdit_reminder_hintText => 'تذكير';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'أي يوم في الأسبوع';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' في كل أسبوع';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'أي يوم في الشهر';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' في كل شهر';

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
  String get habitEdit_reminder_cancelDialogSubtitle => 'هل تؤكد على حذف هذا التذكير';

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
  String get habitEdit_reminder_weekdayText_tursday => 'خميس';

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
  String get habitDisplay_emptyImage_text_01 => 'رحلة الأف ميل تبدأ بخطوة';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'أرشفة العادات المحددة؟';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'إلغاء';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'المؤرشفة $count العادات';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'عدم أرشفة العادات المحددة؟';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'إلغاء';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'غير المؤرشفة $count العادات';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'حذف العادات المحددة؟';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'تأكيد';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'إلغاء';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'محذوفة $count العادات';
  }

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
  String get habitDisplay_statsMenu_popularitySubgroupText => 'العادات الأبرز: تغييرات آخر 30 يوم';

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
  String get habitDetail_unarchiveConfirmDialog_titleText => 'عدم أرشفة العادات';

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
  String get habitDetail_descTargetDays_unitText => '';

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
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'العودة إلى اليوم';

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
  String get appSetting_dragCalendarByPageTile_titleText => 'استعرض التقويم كصفحة';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'إذا تم تفعيل الخاصية، فسيكون استعراض قائمة التقويم بسحبها صفحة صفحة. الوضع الافتراضي أنها غير مفعلة.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'غير حالة السجلات';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'تعديل أسلوب الضغط لتغيير حالة التقرير في الصفحة الرئيسية.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'استعرض السجل التفصيلي';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'تعديل أسلوب الضغط لعرض التقرير اليومي التفصيلي في الصفحة الرئيسية.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'أول يوم في الأسبوع';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'أظهر أول يوم في الأسبوع';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (افتراضي)';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'طريقة عرض التاريخ ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'مطابقة إعدادات الجهاز';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'سيتم تطبيق تنسيق التاريخ في صفحة العادة التفصيلية';

  @override
  String get appSetting_compactUISwitcher_titleText => 'تفعيل العرض المبسط في صفحة العادات';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'السماح بعرض مزيد من المحتوى في جدول التأكيد، ولكن ستظهر بعض النصوص بحجم أصغر.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'تعديل زر تنفيذ العادة';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'عدل النسبة لمساحة أكبر/أصغر في جدول التأكيد';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'افتراضي';

  @override
  String get appSetting_reminderSubgroupText => 'تذكير';

  @override
  String get appSetting_dailyReminder_titleText => 'التذكير اليومي';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'الحفظ والاستعادة';

  @override
  String get appSetting_export_titleText => 'تصدير';

  @override
  String get appSetting_export_subtitleText => 'تصدير العادات كملف JSON، بالإمكان استيراد هذا الملف مرة أخرى.';

  @override
  String get appSetting_import_titleText => 'استيراد';

  @override
  String get appSetting_import_subtitleText => 'استيراد العادات من ملف JSON';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'تأكيد استيراد $count العادات؟';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'ملاحظة: الاستيراد لا يحذف العادات الموجودة.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'تأكيد';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'إلغاء';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'تم الاستيراد $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'اكتمل استيراد $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'إغلاق';

  @override
  String get appSetting_resetConfig_titleText => 'استعادة الاعدادات';

  @override
  String get appSetting_resetConfig_subtitleText => 'استعادة كافة الإعدادات الافتراضية.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'استعادة الاعدادات؟';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'استعادة كامل الاعدادات الافتراضية، يلزم إعادة تشغيل التطبيق.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'إلغاء';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'تأكيد';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'تمت استعادة إعدادات التطبيق';

  @override
  String get appSetting_otherSubgroupText => 'أخرى';

  @override
  String get appSetting_developMode_titleText => 'وضع التطوير';

  @override
  String get appSetting_clearCache_titleText => 'حذف التخزين المؤقت';

  @override
  String get appSetting_clearCacheDialog_titleText => 'حذف التخزين المؤقت';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'بعد حذف التخزين المؤقت، بعض القيم المعدلة ستعود للقيم الافتراضية.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'إلغاء';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'تأكيد';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'فشل حذف التخزين المؤقت جزئياً';

  @override
  String get appSetting_clearCache_snackBar_succText => 'تم حذف التخزين المؤقت';

  @override
  String get appSetting_clearCache_snackBar_failText => 'فشل حذف التخزين المؤقت';

  @override
  String get appSetting_about_titleText => 'عن';

  @override
  String get appAbout_appbarTile_titleText => 'عن';

  @override
  String appAbout_verionTile_titleText(String appVersion) {
    return 'النسخة: $appVersion';
  }

  @override
  String get appAbout_verionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'الكود المصدري';

  @override
  String get appAbout_issueTrackerTile_titleText => 'تتبع الخلل';

  @override
  String get appAbout_contactEmailTile_titleText => 'تواصل معي';

  @override
  String get appAbout_contactEmailTile_emailBody => 'أهلاً، أنا سعيد بتواصلك.\nإذا كنت تود الإبلاغ عن مشكلة، أرجو منك تحديد النسخة وخطوات إظهار المشكلة.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'الترخيص';

  @override
  String get appAbout_licenseTile_subtitleText => 'تصريح أباتشي، النسخة 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'نص التصريح لطرف ثالث';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'فلتر';

  @override
  String get appAbout_donateTile_titleText => 'تبرع';

  @override
  String get appAbout_donateTile_subTitleText => '☕ أنا مبرمج شخصي، إذا أعجبك التطبيق، أرجوك أن تشتري لي قهوة';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

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
  String get appReminder_dailyReminder_title => '🏝 هل التزمت بعاداتك اليوم؟';

  @override
  String get appReminder_dailyReminder_body => 'اضغط للدخول إلى التطبيق والبدء.';

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
  String common_habitColorType_default(int index) {
    return 'لون $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'استخدم تنسيق الجهاز';

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
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'تنسيق 12 ساعة';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'استخدم الاسم الكامل';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'تطبيق على جدول التكرار';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'تطبيق على التقويم';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'إلغاء';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'تأكيد';

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
  String get exportConfirmDialog_cancel_buttonText => 'إلغاء';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'تصدير';

  @override
  String get snackbar_undoText => 'تراجع';

  @override
  String get snackbar_dissmessText => 'إلغاء';

  @override
  String get contributors_tile_title => 'Contributors';

  @override
  String get userAction_tap => 'ضغطة';

  @override
  String get userAction_doubleTap => 'ضغطتين متتابعة';

  @override
  String get userAction_longTap => 'ضغطة طويلة';
}
