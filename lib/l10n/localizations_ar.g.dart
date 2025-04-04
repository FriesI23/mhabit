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
  String get habitEdit_targetDays_dialogTitle => 'اختر الأيام';

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
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'عن';

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
  String get appAbout_appbarTile_titleText => 'عن';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'النسخة: $appVersion';
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
      other: 'status of $count habits',
      one: 'habit\'s status',
    );
    return 'Modified $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'تجاوز السجلات الحالية';

  @override
  String get batchCheckin_save_confirmDialog_body => 'ستتم كتابة السجلات الحالية بعد الحفظ، وستفقد السجلات السابقة.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'حفظ';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'إلغاء';

  @override
  String get batchCheckin_close_confirmDialog_title => 'تأكيد العودة';

  @override
  String get batchCheckin_close_confirmDialog_body => 'لن يتم تطبيق تغييرات حالة التحقق إلا بعد الحفظ.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'خروج';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'إلغاء';

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
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

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
}
