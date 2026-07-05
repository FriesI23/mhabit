// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class L10nHe extends L10n {
  L10nHe([String locale = 'he']) : super(locale);

  @override
  String get localeScriptName => 'עברית';

  @override
  String get appName => 'רשימת הרגלים';

  @override
  String get habitEdit_saveButton_text => 'שמירה';

  @override
  String get habitEdit_habitName_hintText => 'שם ההרגל';

  @override
  String get habitEdit_colorPicker_title => 'נא לבחור צבע';

  @override
  String get habitEdit_colorPicker_historySectionLabel => 'בשימוש לאחרונה';

  @override
  String habitEdit_colorPicker_customSectionLabel(String tinted) {
    String _temp0 = intl.Intl.selectLogic(tinted, {
      'true': 'מותאם אישית (משתנה לפי גון ערכת הנושא)',
      'false': 'מותאם אישית',
      'other': 'מותאם אישית',
    });
    return '$_temp0';
  }

  @override
  String get habitEdit_colorPicker_cancel => 'ביטול';

  @override
  String get habitEdit_colorPicker_tintToggleLabel =>
      'התאמה אישית לגון ערכת הנושא';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'משתנה לפי גון ערכת הנושא';

  @override
  String get habitEdit_colorPicker_untintedLabel =>
      'לא משתנה לפי גון ערכת הנושא';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'התאמת הגוון עלולה לגרום לצבע הסופי להיות שונה מזה שבחרת.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'קריאות צבעים מסוימים עשויים להפחית את קריאוּת הטקסט בסגנון הבהיר או הכהה.';

  @override
  String get habitEdit_habitTypeDialog_title => 'סוג הרגל';

  @override
  String get habitEdit_habitType_positiveText => 'חיובי';

  @override
  String get habitEdit_habitType_negativeText => 'שלילי';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'מטרה יומית, ברירת המחדל היא $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'סף יומי מינימלי, ברירת המחדל היא $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'על המטרה היומית להיות גדולה מ־$number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'על המטרה היומית להיות קטנה או שווה ל־$number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'על המטרה היומית להיות גדולה או שווה ל־$number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'על המטרה היומית להיות קטנה או שווה ל־$number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'שם יחידה למטרה היומית';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'כמות מרבית רצויה למטרה היומית';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'ערך לא תקני, חייב להיות ריק, שווה או גדול מ־$dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'כמות מרבית למטרה היומית';

  @override
  String get habitEdit_frequencySelector_title => 'נא לבחור תדירות';

  @override
  String get habitEdit_habitFreq_daily => 'מטרה יומית';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% פעמים בשבוע';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% פעמים בחודש';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% פעמים ב־%%day%% ימים';

  @override
  String get habitEdit_habitFreq_show_daily => 'מטרה יומית';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'לפחות $freq פעמים בשבוע',
      one: 'פעם בשבוע',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'לפחות $freq פעמים בחודש',
      one: 'פעם בחודש',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'לפחות $freq פעמים בכל $days ימים',
      one: 'פעם בכל $days ימים',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays ימים';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'בחירת ימים למטרה';

  @override
  String get habitEdit_targetDays => 'ימים';

  @override
  String get habitEdit_reminder_hintText => 'תזכורת';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'כל יום בשבוע';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days בכל שבוע';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'כל יום בחודש';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days בכל חודש';
  }

  @override
  String get habitEdit_reminderQuest_hintText => 'שאלה, למשל: עשית היום כושר?';

  @override
  String get habitEdit_reminder_dialogTitle => 'בחירת סוג תזכורת';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'מתי יש לסמן';

  @override
  String get habitEdit_reminder_dialogType_daily => 'מטרה יומית';

  @override
  String get habitEdit_reminder_dialogType_week => 'לפי שבוע';

  @override
  String get habitEdit_reminder_dialogType_month => 'לפי חודש';

  @override
  String get habitEdit_reminder_dialogConfirm => 'אישור';

  @override
  String get habitEdit_reminder_dialogCancel => 'ביטול';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'אישור';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'להסיר תזכורת זו?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'אישור';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'ביטול';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'שני';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'שלישי';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'רביעי';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'חמישי';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'שישי';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'יום ש׳';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'ראשון';

  @override
  String get habitEdit_desc_hintText => 'הערה, יש תמיכה ב־Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'נוצר בתאריך: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'שונה בתאריך: ';

  @override
  String get habitDisplay_fab_text => 'יצירת הרגל';

  @override
  String get habitDisplay_emptyImage_text_01 => 'מסע של אלף מיל מתחיל בצעד אחד';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'לא נמצאו הרגלים תואמים';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'לא נמצאו הרגלים שתואמים לחיפוש „$keyword”';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'להעביר את הארכיונים שנבחרו לארכיון?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'אישור';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'ביטול';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '‏$count הרגלים הועברו לארכיון';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'להוציא את ההרגלים שנבחרו מהארכיון?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'אישור';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'ביטול';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '‏$count הרגלים הוצאו מהארכיון';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'למחוק את ההרגלים שנבחרו?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'אישור';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'ביטול';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'נמחקו $count הרגלים';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'נמחק ההרגל: „$name”';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'יוצאו $count הרגלים.',
      one: 'ההרגל יוּצא.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText => 'כל ההרגלים יוצאו';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'לבחור הכול';

  @override
  String get habitDisplay_editPopMenu_export => 'ייצוא';

  @override
  String get habitDisplay_editPopMenu_delete => 'מחיקה';

  @override
  String get habitDisplay_editPopMenu_clone => 'תבנית';

  @override
  String get habitDisplay_editButton_tooltip => 'עריכה';

  @override
  String get habitDisplay_archiveButton_tooltip => 'העברה לארכיון';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'הוצאה מהארכיון';

  @override
  String get habitDisplay_settingButton_tooltip => 'הגדרות';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'כרגע';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'הושלם';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'בתהליך';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'בארכיון';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'ההרגלים המובילים: שינויים ב־30 הימים האחרונים';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'סגנון בהיר';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'סגנון כהה';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'לפי המערכת';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'הצגת הרגלים בארכיון';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'הצגת הרגלים שהושלמו';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'הצגת פעילים';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'הגדרות';

  @override
  String get habitDisplay_sort_reverseText => 'היפוך';

  @override
  String get habitDisplay_sortDirection_asc => '(עולה)';

  @override
  String get habitDisplay_sortDirection_Desc => '(יורד)';

  @override
  String get habitDisplay_sortType_manual => 'סדר מותאם אישית';

  @override
  String get habitDisplay_sortType_name => 'לפי שם';

  @override
  String get habitDisplay_sortType_colorType => 'לפי צבע';

  @override
  String get habitDisplay_sortType_progress => 'לפי דירוג';

  @override
  String get habitDisplay_sortType_startT => 'לפי תאריך התחלה';

  @override
  String get habitDisplay_sortType_status => 'לפי מצב';

  @override
  String get habitDisplay_sortTypeDialog_title => 'מיון';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'אישור';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'ביטול';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️ ניפוי שגיאות';

  @override
  String get habitDisplay_searchBar_hintText => 'חיפוש הרגלים';

  @override
  String get habitDisplay_searchFilter_ongoing => 'בתהליך';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'הצגת הרגלים שכרגע הם פעילים ובתהליך (ולא כאלה שבארכיון או שנמחקו).';

  @override
  String get habitDisplay_searchFilter_completed => 'הושלם';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'סוג הרגל';

  @override
  String get habitDisplay_searchFilter_tooltips => 'הצגת מסננים';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'ניקוי מסננים';

  @override
  String get habitDisplay_tab_habits_label => 'הרגלים';

  @override
  String get habitDisplay_tab_today_label => 'היום';

  @override
  String get habitToday_appBar_title => 'היום';

  @override
  String get habitToday_image_desc => 'עשית את זה';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'הצלחת למשך $days ימים';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'הושלם+';

  @override
  String get habitToday_card_skipPlusButton_label => 'דילוג+';

  @override
  String get habitDetail_editButton_tooltip => 'עריכה';

  @override
  String get habitDetail_editPopMenu_unarchive => 'הוצאה מהארכיון';

  @override
  String get habitDetail_editPopMenu_archive => 'העברה לארכיון';

  @override
  String get habitDetail_editPopMenu_export => 'ייצוא';

  @override
  String get habitDetail_editPopMenu_delete => 'מחיקה';

  @override
  String get habitDetail_editPopMenu_clone => 'תבנית';

  @override
  String get habitDetail_confirmDialog_confirm => 'אישור';

  @override
  String get habitDetail_confirmDialog_cancel => 'ביטול';

  @override
  String get habitDetail_archiveConfirmDialog_titleText =>
      'להעביר את ההרגל לארכיון?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'להוציא את ההרגל מהארכיון?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'למחוק את ההרגל?';

  @override
  String get habitDetail_summary_title => 'סיכום';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'הציון הנוכחי הוא $score, ועברו $days ימים מאז ההתחלה.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'יתחיל בעוד $days ימים.',
      one: 'מתחיל מחר.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'פחות מהרגיל',
      one: 'לא הושלם',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'יוצא מן הכלל',
      one: 'יותר מהנדרש',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'מטרה',
      two: 'סף',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'יחידה: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'אין נתונים';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'ימים',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'ימים';

  @override
  String get habitDetail_descRecordsNum_titleText => 'רשומות';

  @override
  String get habitDetail_scoreChart_title => 'ציון';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'יום';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'שבוע';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'חודש';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'שנה';

  @override
  String get habitDetail_freqChart_freqTitle => 'תדירות';

  @override
  String get habitDetail_freqChart_historyTitle => 'היסטוריה';

  @override
  String get habitDetail_freqChart_combinedTitle => 'תדירות והיסטוריה';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'שבוע';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'חודש';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'שנה';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'כעת';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'הסתרת תרשים ההיסטוריה';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'הצגת תרשים ההיסטוריה';

  @override
  String get habitDetail_descSubgroup_title => 'הערה';

  @override
  String get habitDetail_otherSubgroup_title => 'שונות';

  @override
  String get habitDetail_habitType_title => 'סוג';

  @override
  String get habitDetail_reminderTile_title => 'תזכורת';

  @override
  String get habitDetail_freqTile_title => 'חזרה';

  @override
  String get habitDetail_startDateTile_title => 'תאריך התחלה';

  @override
  String get habitDetail_createDateTile_title => 'תאריך יצירה';

  @override
  String get habitDetail_modifyDateTile_title => 'תאריך שינוי';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'תאריך';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'ערך';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'חזרה להיום';

  @override
  String get common_loadError_text => 'הטעינה נכשלה';

  @override
  String get common_loadError_retryText => 'ניסיון חוזר';

  @override
  String get habitDetail_notFoundText => 'טעינת ההרגל נכשלה';

  @override
  String get habitDetail_notFoundRetryText => 'ניסיון חוזר';

  @override
  String get habitDetail_changeGoal_title => 'שינוי מטרה';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'כרגע: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'הושלם: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'לא הושלם';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '‏$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'מטרה יומית, ברירת מחדל: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'ביטול';

  @override
  String get habitDetail_changeGoal_saveText => 'שמירה';

  @override
  String get habitDetail_skipReason_title => 'סיבה לדילוג';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'אפשר לכתוב כאן...';

  @override
  String get habitDetail_skipReason_cancelText => 'ביטול';

  @override
  String get habitDetail_skipReason_saveText => 'שמירה';

  @override
  String get appSetting_appbar_titleText => 'הגדרות';

  @override
  String get appSetting_displaySubgroupText => 'תצוגה';

  @override
  String get appSetting_operationSubgroupText => 'פעולה';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'גרירת לוח השנה לפי עמוד';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'אם האפשרות מופעלת, לוח השנה שבשורת הכותרת של עמוד הבית של היישום תוכל להיגרר מעמוד לעמוד. האפשרות מושבתת כברירת מחדל.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'שינוי מצב רשומה';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'שינוי אופן הלחיצה לשינוי המצב של הרשומות היומיות בעמוד הראשי.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'פתיחת רשומה מפורטת';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'שינוי אופן הפתיחה של חלוניות נפתחות עם פירוט על הרשומות היומיות בעמוד הראשי.';

  @override
  String get appSetting_appThemeColorTile_titleText => 'צבע נושא';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText => 'בחירת צבע נושא';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'שימוש בצבע הראשי של הרקע (אנדרואיד 12‏+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'שימוש בצבע הנבחר של ערכת הנושא ל־GTK‏+';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'שימוש בצבע הנושא של המערכת';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'שימוש בצבע הנושא או בצבע החלון/זכוכית';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'היום הראשון בשבוע';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'הצגת היום הראשון בשבוע';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (ברירת מחדל)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'לפי המערכת ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'לפי המערכת';

  @override
  String get appSetting_changeLanguageTile_titleText => 'שפה';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'נא לבחור שפה';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'תבנית להצגת תאריכים ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'לפי הגדרות המערכת';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'תבנית התאריך שהוגדרה תחול על תצוגת התאריך בעמוד פרטי ההרגל.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'הפעלת ממשק משתמש חסכוני בעמוד ההרגלים';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'מאפשרת לרשימת ההרגלים לסימון להציג יותר תוכן, כאשר ממשק המשתמש והטקסט עשויים להופיע בקטן יותר.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'כוונון גודל השטח לסימון הרגלים';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'יש לכוונן את מספר האחוזים בשביל להקצות יותר או פחות מקום לסימון ההרגלים ברשימה.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'ברירת מחדל';

  @override
  String get appSetting_reminderSubgroupText => 'תזכורות והתראות';

  @override
  String get appSetting_dailyReminder_titleText => 'תזכורת יומית';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'גיבוי ושחזור';

  @override
  String get appSetting_export_titleText => 'ייצוא';

  @override
  String get appSetting_export_subtitleText =>
      'ההרגלים מיוצאים בתבנית הקובץ JSON, ניתן לייבא קובץ זה בחזרה.';

  @override
  String get appSetting_import_titleText => 'ייבוא';

  @override
  String get appSetting_import_subtitleText => 'ייבוא הרגלים מקובץ json.';

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
    return 'לאשר את הייבוא של $count הרגלים?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'הערה: הייבוא אינו מוחק הרגלים קיימים.';

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
  String get appSetting_importDialog_confirm_confirmText => 'אישור';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'ביטול';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'יובאו $completeCount‏/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'השלמת הייבוא של $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'סגירה';

  @override
  String get appSetting_resetConfig_titleText => 'איפוס ההגדרות';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'איפוס כל ההגדרות לברירת המחדל';

  @override
  String get appSetting_resetConfigDialog_titleText => 'לאפס את ההגדרות?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'איפוס כל ההגדרות לברירת המחדל, על היישום להיפתח מחדש להחלת השינויים.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'ביטול';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'אישור';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'הגדרות היישום אופסו בהצלחה';

  @override
  String get appSetting_otherSubgroupText => 'שונות';

  @override
  String get appSetting_developMode_titleText => 'מצב מפתחים';

  @override
  String get appSetting_clearCache_titleText => 'ניקוי המטמון';

  @override
  String get appSetting_clearCacheDialog_titleText => 'ניקוי המטמון';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'לאחר ניקוי המטמון, חלק מהערכים המותאמים אישית ישוחזרו לברירות המחדל.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'ביטול';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'אישור';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'ניקוי מטמון חלקי נכשל';

  @override
  String get appSetting_clearCache_snackBar_succText => 'המטמון נוקה בהצלחה';

  @override
  String get appSetting_clearCache_snackBar_failText => 'ניקוי המטמון נכשל';

  @override
  String get appSetting_debugger_titleText => 'מידע ניפוי שגיאות';

  @override
  String get appSetting_about_titleText => 'על אודות';

  @override
  String get appSetting_experimentalFeatureTile_titleText => 'תכונות ניסיוניות';

  @override
  String get appSetting_synSubgroupText => 'סנכרון';

  @override
  String get appSetting_syncOption_titleText => 'אפשרויות סנכרון';

  @override
  String get appSetting_notify_titleTile => 'התראות';

  @override
  String get appSetting_notify_subtitleTile => 'ניהול העדפות ההתראות';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'הקשה כאן תפתח את הגדרות ההתראות של המערכת';

  @override
  String get appSync_nowTile_titleText => 'סנכרון כעת';

  @override
  String get appSync_nowTile_titleText_syncing => 'מתבצע סנכרון';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '‏$ymdString‏ $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'מועד הסנכרון האחרון: לא ידוע';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'מועד הסנכרון האחרון: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate => 'סנכרון אחרון: (שגיאה): N/A';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'סנכרון אחרון (שגיאה): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'מתבצע סנכרון...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'מתבצע סנכרון: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'בתהליך ביטול...';

  @override
  String get appSync_nowTile_cancelText_noDate => 'סנכרון אחרון (בוטל): N/A';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'מועד סנכרון אחרון (בוטל): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'עיון ביומני כשל';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[שגיאה]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason:‏ $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'הושלם',
      'cancelled': 'בוטל',
      'failed': 'נכשל',
      'multi': 'מצבים מרובים',
      'other': 'מצב לא ידוע',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'הושלם בשל $reason',
      'cancelled': 'בוטל בשל $reason',
      'failed': 'נכשל בשל $reason',
      'multi': 'מצבים מרובים בשל $reason',
      'other': 'מצב לא ידוע',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'שגיאה',
      'userAction': 'נדרשת פעולה של המשתמש',
      'missingHabitUuid': 'מזהה ההרגל חסר',
      'empty': 'אין נתונים',
      'other': 'סיבה לא ידועה',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'מיקום חדש';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'הסנכרון ייצור את התיקיות הנדרשות ויעלה את ההרגלים המקומיים לשרת. להמשיך?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText => 'סנכרון כעת!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText => 'אישור הסנכרון';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'התיקייה אינה ריקה. הסנכרון ימזג את ההרגלים המקומיים עם אלה שבשרת. להמשיך?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText => 'אישור מיזוג';

  @override
  String get appSync_exportAllLogsTile_titleText => 'ייצוא יומני הסנכרון שנכשל';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'לא נמצאו יומנים',
      'false': 'יש להקיש כאן כדי לייצא',
      'other': 'בטעינה...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'כרגע: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'מזויף (לניפוי שגיאות בלבד)',
      'other': 'לא ידוע ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'נתונים ניידים',
      'wifi': 'רשת אלחוטית',
      'other': 'לא ידוע',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'באופן ידני',
      'minute5': '5 דקות',
      'minute15': 'רבע שעה',
      'minute30': 'חצי שעה',
      'hour1': 'שעה',
      'other': 'לא ידוע',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'מרווח זמן למשיכת נתונים';

  @override
  String get appSync_summaryTile_title => 'סנכרון עם השרת';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured => 'לא מוגדר';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'כל יומני הכשל האחרונים של הסנכרון';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'אישור שמירת השינויים';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'השמירה תשכתב את הגדרות השרת הקודמות.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'שינויים שלא נשמרו';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'היציאה תשליך את כל השינויים שלא נשמרו.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'אישור מחיקה';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'המחיקה תסיר את הגדרת השרת הנוכחית.';

  @override
  String get appSync_serverEditor_titleText_add => 'שרת סנכרון חדש';

  @override
  String get appSync_serverEditor_titleText_modify => 'עריכת שרת סנכרון';

  @override
  String get appSync_serverEditor_advance_titleText => 'הגדרות מתקדמות';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'נתיב';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'נא למלא כאן נתיב תקני ל־WebDAV.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'שדה הנתיב אינו יכול להיות ריק!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'שם משתמש';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'נא למלא כאן שם משתמש, אם אינו נדרש אפשר להשאיר שדה זה ריק.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'סיסמה';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'התעלמות מתעודת SSL';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'שניות מוקצבות לסנכרון';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'ללא הגבלה',
    );
    return 'ברירת מחדל: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 'שנ׳';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'כמות שניות מוקצבות לחיבור לרשת';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'ללא הגבלה',
    );
    return 'ברירת מחדל: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 'שנ׳';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'כמות ניסיונות חוזרים להתחברות לרשת';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'הניסיונות החוזרים מושבתים',
    );
    return 'ברירת מחדל: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText => 'מצב סנכרון רשת';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'סנכרון באמצעות נתונים ניידים',
      'wifi': 'סנכרון באמצעות רשת אלחוטית',
      'other': 'לא ידוע',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'חיסכון בנתונים';

  @override
  String get appSync_noti_readyToSync_body => 'בהכנות לסנכרון...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'התבצע סנכרון של ($type)',
      'failed': 'נכשל הסנכרון של ($type)',
      'other': 'מתבצע סנכרון של ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'סנכרון במצב חיסכון בנתונים';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'מופעלת תכונה ניסיונית אחת או יותר, השימוש באחריותך.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'סנכרון הרגלים עם הענן';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'לאחר ההפעלה, אפשרות הסנכרון של היישום תופיע בהגדרות';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'התכונה הניסיונית ($syncName) מושבתת, אך הרכיבים שלה עדיין פועלים.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'לצורך השבתה מלאה, יש לגשת אל ‚$menuName’ בעזרת לחיצה ארוכה ולכבות.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'חיפוש הרגלים';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'לאחר ההפעלה, תופיע שורת חיפוש בחלק העליון של מסך ההרגלים ויהיה ניתן לחפש הרגלים.';

  @override
  String get appAbout_appbarTile_titleText => 'על אודות';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'גרסה: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => '‏CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'קוד מקור';

  @override
  String get appAbout_issueTrackerTile_titleText => 'מעקב אחר תקלות';

  @override
  String get appAbout_contactEmailTile_titleText => 'יצירת קשר עם המפתח';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'היי, אני שמח שבחרת ליצור איתי קשר.\nאם רצית לדווח על תקלה, נא לציין מה גרסת היישום ולתאר בשפה האנגלית את הצעדים לשחזור התקלה מחדש.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'רישיון';

  @override
  String get appAbout_licenseTile_subtitleText => 'רישיון Apache, גרסה 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'הצהרת רישיון צד שלישי';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'Flutter';

  @override
  String get appAbout_privacyTile_titleText => 'פרטיות';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'עיון במדיניות הפרטיות של יישום זה';

  @override
  String get appAbout_donateTile_titleText => 'תרומה';

  @override
  String get appAbout_donateTile_subTitleText =>
      'אני מפתח עצמאי. אם אהבת את היישום, אפשר לקנות לי ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'פייפאל';

  @override
  String get donateWay_buyMeACoffee => '‏Buy me a coffee';

  @override
  String get donateWay_alipay => '‏Alipay';

  @override
  String get donateWay_wechatPay => '‏Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'מטבעות קריפטו';

  @override
  String get donateWay_cryptoCurrency_BTC => '‏BTC';

  @override
  String get donateWay_cryptoCurrency_ETH => '‏ETH';

  @override
  String get donateWay_cryptoCurrency_BNB => '‏BNB';

  @override
  String get donateWay_cryptoCurrency_AVAX => '‏AVAX';

  @override
  String get donateWay_cryptoCurrency_FTM => '‏FTM';

  @override
  String get donateWay_firstQRGroup => '‏Alipay ו־Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'הועתקה הכתובת של $name';
  }

  @override
  String get batchCheckin_appbar_title => 'סימון כמותי';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'היום הקודם';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'היום הבא';

  @override
  String get batchCheckin_status_skip_text => 'דילוג';

  @override
  String get batchCheckin_status_ok_text => 'הושלם';

  @override
  String get batchCheckin_status_double_text => 'פעמיים ברצף!';

  @override
  String get batchCheckin_status_zero_text => 'לא הושלם';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נבחרו $count הרגלים',
      one: 'נבחר הרגל אחד',
    );
    return '$_temp0';
  }

  @override
  String get batchCheckin_save_button_text => 'שמירה';

  @override
  String get batchCheckin_reset_button_text => 'איפוס';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'מצבם של $count הרגלים',
      one: 'מצב ההרגל',
    );
    return 'השתנה $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'שכתוב רשומות קיימות';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'הרשומות הקיימות ישוכתבו לאחר השמירה, הרשומות הקודמות יימחקו.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'שמירה';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'ביטול';

  @override
  String get batchCheckin_close_confirmDialog_title => 'אישור חזרה';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'השינויים במצב הסימון לא יוחלו עד שיישמרו';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'יציאה';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'ביטול';

  @override
  String get appReminder_dailyReminder_title => '🏝 האם דבקת בהרגלים שלך היום?';

  @override
  String get appReminder_dailyReminder_body =>
      'חשוב לסמן את ההרגל בזמן בעזרת לחיצה וכניסה ליישום.';

  @override
  String get common_habitColorType_cc1 => 'סגול כהה';

  @override
  String get common_habitColorType_cc2 => 'אדום';

  @override
  String get common_habitColorType_cc3 => 'סגול';

  @override
  String get common_habitColorType_cc4 => 'כחול רויאל';

  @override
  String get common_habitColorType_cc5 => 'טורקיז';

  @override
  String get common_habitColorType_cc6 => 'ירוק';

  @override
  String get common_habitColorType_cc7 => 'ענבר';

  @override
  String get common_habitColorType_cc8 => 'כתום';

  @override
  String get common_habitColorType_cc9 => 'ירוק לימון';

  @override
  String get common_habitColorType_cc10 => 'ורוד כהה';

  @override
  String get common_habitColorType_custom => 'מותאם אישית';

  @override
  String common_habitColorType_default(int index) {
    return 'צבע $index';
  }

  @override
  String get common_appThemeColor_system => 'מערכת';

  @override
  String get common_appThemeColor_primary => 'ראשי';

  @override
  String get common_appThemeColor_dynamic => 'דינמי';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'שימוש בתבניות המערכת';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'תבניות תאריכים';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'שנה חודש יום';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'חודש יום שנה';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'יום חודש שנה';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'מפריד';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'קו מפריד';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'קו נטוי';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'רווח';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'נקודה';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'ללא מפריד';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'שימוש בתבנית 12 שעות';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'שימוש בשם המלא';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'החלה על תרשים התדירות';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'החלה על לוח השנה';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'ביטול';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'אישור';

  @override
  String get common_errorPage_title => 'אופס, קרסנו!';

  @override
  String get common_errorPage_copied => 'מידע הקריסה הועתק';

  @override
  String get common_enable_text => 'מופעל';

  @override
  String get calendarPicker_clip_today => 'היום';

  @override
  String get calendarPicker_clip_tomorrow => 'מחר';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString הבא';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'לייצא את כל ההרגלים?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number הרגלים',
      one: 'הרגל אחד',
      zero: 'את ההרגל הנוכחי',
    );
    return 'לייצא $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'לכלול רשומות';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'ביטול';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'ייצוא';

  @override
  String get debug_logLevelTile_title => 'רמת תיעוד ביומן';

  @override
  String get debug_logLevelDialog_title => 'שינוי רמת התיעוד ביומן';

  @override
  String get debug_logLevel_debug => 'ניפוי שגיאות';

  @override
  String get debug_logLevel_info => 'מידע';

  @override
  String get debug_logLevel_warn => 'אזהרה';

  @override
  String get debug_logLevel_error => 'שגיאה';

  @override
  String get debug_logLevel_fatal => 'שגיאה חמורה';

  @override
  String get debug_collectLogTile_title => 'הנתונים נאספים ביומן';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'הקשה כאן תפסיק את איסוף הנתונים ביומן.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'הקשה כאן תתחיל את איסוף הנתונים ביומן.';

  @override
  String get debug_downladDebugLogs_subject => 'יומני ניפוי השגיאות מתקבלים';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'נוקו יומני ניפוי השגיאות.';

  @override
  String get debug_downladDebugInfo_subject => 'מידע ניפוי השגיאות מתקבל';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'מתבצעת הורדת $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'יומן ניפוי השגיאות אינו קיים.';

  @override
  String get debug_debuggerLogCard_title => 'מידע על התיעוד ביומן';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'כולל מידע על יומני ניפוי שגיאות מקומיים, צריך להפעיל את מתג איסוף הנתונים ביומן.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'הורדה';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'ניקוי';

  @override
  String get debug_debuggerInfoCard_title => 'מידע על ניפוי השגיאות';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'כולל את המידע על ניפוי השגיאות ביישום.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'פתיחה';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'שמירה';

  @override
  String get debug_debuggerInfo_notificationTitle => 'נאסף מידע על היישום...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'שמירה',
      'exit': 'יציאה',
      'delete': 'מחיקה',
      'other': 'אישור',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'ביטול';

  @override
  String get snackbar_undoText => 'ביטול';

  @override
  String get snackbar_dismissText => 'ביטול';

  @override
  String get contributors_tile_title => 'תורמים';

  @override
  String get userAction_tap => 'הקשה';

  @override
  String get userAction_doubleTap => 'כפולה';

  @override
  String get userAction_longTap => 'ארוכה';

  @override
  String get channelName_habitReminder => 'תזכורת להרגל';

  @override
  String get channelName_appReminder => 'הוראה';

  @override
  String get channelName_appDebugger => 'כלי ניפוי שגיאות';

  @override
  String get channelName_appSyncing => 'התקדמות הסנכרון';

  @override
  String get channelDesc_appSyncing =>
      'משמשת להצגת התקדמות הסנכרון ותוצאות שאינן כישלון';

  @override
  String get channelName_appSyncFailed => 'הסנכרון נכשל';

  @override
  String get channelDesc_appSyncFailed => 'משמשת להתרעה על סנכרון שנכשל';

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
}
