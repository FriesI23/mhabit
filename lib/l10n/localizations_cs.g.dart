// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class L10nCs extends L10n {
  L10nCs([String locale = 'cs']) : super(locale);

  @override
  String get localeScriptName => 'čeština';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Uložit';

  @override
  String get habitEdit_habitName_hintText => 'Název zvyku ...';

  @override
  String get habitEdit_colorPicker_title => 'Zvolte barvu';

  @override
  String get habitEdit_colorPicker_historySectionLabel => 'Nedávno použité';

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
  String get habitEdit_colorPicker_cancel => 'Zrušit';

  @override
  String get habitEdit_colorPicker_tintToggleLabel => 'Tint to theme';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Tónované';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Nezabarvené';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'Tinting may shift the final color away from the one you picked.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Some colors may reduce text readability in light or dark theme.';

  @override
  String get habitEdit_habitTypeDialog_title => 'Typ zvyku';

  @override
  String get habitEdit_habitType_positiveText => 'Pozitivní';

  @override
  String get habitEdit_habitType_negativeText => 'Negativní';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Denní cíl, $number je výchozí';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Minimum daily threshold, default $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'denní cíl musí být > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'denní cíl musí být ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'denní cíl musí být ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'denní cíl musí být ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Daily goal unit';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Očekávaný maximální denní cíl';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'neplatná hodna, musí být prázdné, nebo ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Maximální denní limit';

  @override
  String get habitEdit_frequencySelector_title => 'Zvolte četnost';

  @override
  String get habitEdit_habitFreq_daily => 'Denní';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% za týden';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% krát za měsíc';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% krát za %%day%% dnů';

  @override
  String get habitEdit_habitFreq_show_daily => 'Denní';

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
    return '$targetDays dnů';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Select Target Days';

  @override
  String get habitEdit_targetDays => 'days';

  @override
  String get habitEdit_reminder_hintText => 'Připomenutí';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Kterýkoli den v týdnu';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days každý týden';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Kterýkoli den v měsíci';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days každý měsíc';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Otázka, např. Cvičil jsi dnes?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Zvolte typ připomenutí';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'When need to check in';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Denní';

  @override
  String get habitEdit_reminder_dialogType_week => 'Týdně';

  @override
  String get habitEdit_reminder_dialogType_month => 'Měsíčně';

  @override
  String get habitEdit_reminder_dialogConfirm => 'Potvrdit';

  @override
  String get habitEdit_reminder_dialogCancel => 'Zrušit';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Potvrdit';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Do you confirm to remove this reminder';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'Potvrdit';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'Zrušit';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Po';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Út';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'St';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Čt';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Pá';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'So';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Ne';

  @override
  String get habitEdit_desc_hintText => 'Memo, podporuje Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Vytvořeno: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Upraveno: ';

  @override
  String get habitDisplay_fab_text => 'Nový zvyk';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'I ta nejdelší cesta začíná jediným krokem';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'Žádné odpovídající návyky';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'Žádné odpovídající zvyky pro \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Archive Selected Habits?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'Potvrdit';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'cancel';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Archivováno $count zvyků';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Unarchive Selected Habits?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'Potvrdit';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'cancel';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Unarchived $count habits';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Delete Selected Habits?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'potvrdit';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'zrušit';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Deleted $count habits';
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
  String get habitDisplay_editPopMenu_selectAll => 'Vybrat vše';

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
  String get habitDisplay_statsMenu_completedTileText => 'Dokončené';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Probíhající';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archivováno';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Top Habits: Last 30 Days Changes';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Světlý vzhled';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Tmavý vzhled';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Podle systému';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Zobrazit archivované';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'Zobrazit dokončené';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Zobrazit aktivované';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Nastavení';

  @override
  String get habitDisplay_groupType_name => 'Podle názvu';

  @override
  String get habitDisplay_groupType_colorType => 'Podle barvy';

  @override
  String get habitDisplay_groupType_createDate => 'By Creation Date';

  @override
  String get habitDisplay_groupType_habitCount => 'By Habit Count';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Group Sort';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'potvrdit';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'zrušit';

  @override
  String get habitDisplay_groupTypeDialog_none => 'Ploché';

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
  String get habitDisplay_sort_reverseText => 'Reverse';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Desc)';

  @override
  String get habitDisplay_sortType_manual => 'Moje pořadí';

  @override
  String get habitDisplay_sortType_name => 'Podle názvu';

  @override
  String get habitDisplay_sortType_colorType => 'Podle barvy';

  @override
  String get habitDisplay_sortType_progress => 'Podle četnosti';

  @override
  String get habitDisplay_sortType_startT => 'By Start Date';

  @override
  String get habitDisplay_sortType_status => 'Podle stavu';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sort';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'Potvrdit';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'cancel';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Debug';

  @override
  String get habitDisplay_searchBar_hintText => 'Vyhledat zvyky';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Probíhající';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'Dokončené';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Typ zvyku';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Zobrazit filtry';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Vymazat filtry';

  @override
  String get habitDisplay_tab_habits_label => 'Zvyky';

  @override
  String get habitDisplay_tab_today_label => 'Dnes';

  @override
  String get habitToday_appBar_title => 'Dnes';

  @override
  String get habitToday_image_desc => 'YOU MADE IT';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Kept it up for $days days';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Hotovo+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Přeskočit+';

  @override
  String get habitDetail_editButton_tooltip => 'Edit';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Unarchive';

  @override
  String get habitDetail_editPopMenu_archive => 'Archive';

  @override
  String get habitDetail_editPopMenu_export => 'Export';

  @override
  String get habitDetail_editPopMenu_delete => 'Smazat';

  @override
  String get habitDetail_editPopMenu_clone => 'Šablona';

  @override
  String get habitDetail_confirmDialog_confirm => 'Potvrdit';

  @override
  String get habitDetail_confirmDialog_cancel => 'zrušit';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Zaarchivovat zvyk?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Vyndat zvyk zpět z archivu?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Smazat návyk?';

  @override
  String get habitDetail_summary_title => 'Souhrn';

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
    return 'Jednotka: $unit';
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
  String get habitDetail_descRecordsNum_titleText => 'Záznamy';

  @override
  String get habitDetail_scoreChart_title => 'Hodnocení';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Den';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Týden';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Měsíc';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChart_freqTitle => 'Četnost';

  @override
  String get habitDetail_freqChart_historyTitle => 'Historie';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Frequency & History';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Týden';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Měsíc';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Nyní';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Hide History Chart';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Show History Chart';

  @override
  String get habitDetail_descSubgroup_title => 'Pozn.';

  @override
  String get habitDetail_otherSubgroup_title => 'Ostatní';

  @override
  String get habitDetail_habitType_title => 'Typ';

  @override
  String get habitDetail_reminderTile_title => 'Připomínka';

  @override
  String get habitDetail_freqTile_title => 'Opakovat';

  @override
  String get habitDetail_startDateTile_title => 'Datum zahájení';

  @override
  String get habitDetail_createDateTile_title => 'Vytvořeno';

  @override
  String get habitDetail_modifyDateTile_title => 'Změněno';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'datum';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'hodnota';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'back to today';

  @override
  String get common_loadError_text => 'Failed to load';

  @override
  String get common_loadError_retryText => 'Zkusit znovu';

  @override
  String get habitDetail_notFoundText => 'Load habit failed';

  @override
  String get habitDetail_notFoundRetryText => 'Zkusit znovu';

  @override
  String get habitDetail_changeGoal_title => 'Změnit cíl';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'stávající: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'hotovo: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'zrušit dokončení';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Daily goal, default: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'zrušit';

  @override
  String get habitDetail_changeGoal_saveText => 'uložit';

  @override
  String get habitDetail_skipReason_title => 'Důvod přeskočení';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Write something here...';

  @override
  String get habitDetail_skipReason_cancelText => 'zrušit';

  @override
  String get habitDetail_skipReason_saveText => 'uložit';

  @override
  String get appSetting_appbar_titleText => 'Nastavení';

  @override
  String get appSetting_displaySubgroupText => 'Zobrazení';

  @override
  String get appSetting_operationSubgroupText => 'Operace';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Drag calendar by page';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'If the switch is enabled, the app bar calendar on the home page will be dragged page by page. By default, the switch is disabled.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Change Record Status';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Modify the click behavior to change the status of daily records on main page.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Open Detailed Record';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Modify the click behavior to open the detailed popup for daily records on main page.';

  @override
  String get appSetting_expandTimerDelayTile_titleText => 'Group expand delay';

  @override
  String get appSetting_expandTimerDelayTile_subtitleText =>
      'Set how long to hover over a collapsed group header before it auto-expands during drag-and-drop.';

  @override
  String get appSetting_expandTimerDelay_default => 'Výchozí';

  @override
  String get appSetting_expandTimerDelay_fast => 'Rychlé';

  @override
  String get appSetting_expandTimerDelay_slow => 'Pomalé';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Barva vzhledu';

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
  String get appSetting_firstDayOfWeek_titleText => 'První den v týdnu';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Show first day of week';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Výchozí)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Follow System ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Podle systému';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Jazyk';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Vyberte jazyk';

  @override
  String get appSetting_languageSubgroupText => 'Jazyk';

  @override
  String get appSetting_openSystemLanguageTile_titleText =>
      'System Language Settings';

  @override
  String get appSetting_openSystemLanguageTile_dialogTitle =>
      'Open System Language Settings';

  @override
  String get appSetting_openSystemLanguageTile_macosDialogContent =>
      'Due to macOS limitations, the app language cannot be changed directly. To switch languages, follow these steps:\n\n1. Open **System Settings > General > Language & Region**\n2. Add this app in the **Applications** list and choose a language';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Date display format ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'follow system setting';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Configured date format will be applied to the date display on habit detail page.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Enable Compact UI on habits page';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Allow habits check table to display more content, but some UI and text may appear smaller.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Habits check area radio adjustment';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Adjust percentage for more/less space in habits check table area.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Výchozí';

  @override
  String get appSetting_reminderSubgroupText => 'Reminder & Notification';

  @override
  String get appSetting_dailyReminder_titleText => 'Denní připomenutí';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Záloha a obnovení';

  @override
  String get appSetting_export_titleText => 'Export';

  @override
  String get appSetting_export_subtitleText =>
      'Exported habits as JSON format, This file can be import back.';

  @override
  String get appSetting_import_titleText => 'Import';

  @override
  String get appSetting_import_subtitleText => 'Import habits from json file.';

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
    return 'Confirm import $count habits?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Note: Import doesn\'t delete existing habits.';

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
    return 'Zdroj: $provider';
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
  String get appSetting_importDialog_confirm_confirmText => 'Potvrdit';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'zrušit';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'Naimportováno $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Complete import $count habits';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Completed import $count groups';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'zavřít';

  @override
  String get appSetting_resetConfig_titleText => 'Resetovat nastavení';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Reset all configs to default.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Resetovat nastavení?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Reset all configs to default, must restart application to apply.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'zrušit';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'potvrdit';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'reset app configs succeed';

  @override
  String get appSetting_otherSubgroupText => 'Ostatní';

  @override
  String get appSetting_developMode_titleText => 'Režim pro vývojáře';

  @override
  String get appSetting_clearCache_titleText => 'Vymazat mezipaměť';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Vymazat mezipaměť';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'After clearing cache, some custom values will be restored to defaults.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'zrušit';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'potvrdit';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Partial Cache cleared failed';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Cache cleared successfully';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Cache cleared failed';

  @override
  String get appSetting_debugger_titleText => 'Ladící informace';

  @override
  String get appSetting_about_titleText => 'O aplikaci';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Experimentální funkce';

  @override
  String get appSetting_synSubgroupText => 'Synchr.';

  @override
  String get appSetting_syncOption_titleText => 'Možnosti synchronizace';

  @override
  String get appSetting_notify_titleTile => 'Notifikace';

  @override
  String get appSetting_notify_subtitleTile =>
      'Manage notification preferences';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Tap to open system notification settings';

  @override
  String get appSync_nowTile_titleText => 'Synchronizovat nyní';

  @override
  String get appSync_nowTile_titleText_syncing => 'Synchronizuje se';

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
  String get appSync_nowTile_syncingText => 'Synchronizování…';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Synchronizování: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Rušení…';

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
  String get appSync_webdav_newServerConfirmDialog_titleText => 'Nové umístění';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Syncing will create necessary directories and upload local habits to the server. Continue?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Synchronizovat nyní!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Potvrdit synchronizaci';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Directory isn\'t empty. Syncing will merge server and local habits. Continue?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Potvrdit sloučení';

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
  String get appSync_syncIntervalTile_title => 'Interval načítání';

  @override
  String get appSync_summaryTile_title => 'Synchronizační server';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured => 'Nenastaveno';

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
  String get appSync_serverEditor_exitDialog_titleText => 'Neuložené změny';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Exiting will discard all unsaved changes.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Potvrdit smazání';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Deleting will remove current server config.';

  @override
  String get appSync_serverEditor_titleText_add => 'New Sync Server';

  @override
  String get appSync_serverEditor_titleText_modify => 'Modify Sync Server';

  @override
  String get appSync_serverEditor_advance_titleText => 'Pokročilá nastavení';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Popis umístění';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Enter a valid WebDAV path here.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Path shouldn\'t be empty!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Uživatelské jméno';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Enter username here, leave empty if not required.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Heslo';

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
  String get experimentalFeatures_habitSearchTile_titleText => 'Hledání návyku';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Once enabled, a search bar will appear at the top of the Habits screen and allowing to search habits.';

  @override
  String get appAbout_appbarTile_titleText => 'O aplikaci';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Verze: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Zdrojové kódy';

  @override
  String get appAbout_issueTrackerTile_titleText =>
      'Systém pro správu hlášení chyb';

  @override
  String get appAbout_contactEmailTile_titleText => 'Kontaktujte mě';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licence';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Third Party Licensing Statement';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Soukromí';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Access the privacy policy in this app';

  @override
  String get appAbout_donateTile_titleText => 'Podpořit darováním';

  @override
  String get appAbout_donateTile_subTitleText =>
      'I\'m a personal developer. If you like this app, please buy me a ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Buy me a coffee';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Kryptoměny';

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
  String get batchCheckin_appbar_title => 'Dávkové check-in';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Předchozí den';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Následující den';

  @override
  String get batchCheckin_status_skip_text => 'Přeskočit';

  @override
  String get batchCheckin_status_ok_text => 'Dokončeno';

  @override
  String get batchCheckin_status_double_text => 'Dvojnásobný zásah!';

  @override
  String get batchCheckin_status_zero_text => 'Nedokončeno';

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
  String get batchCheckin_save_button_text => 'Uložit';

  @override
  String get batchCheckin_reset_button_text => 'Resetovat';

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
  String get batchCheckin_save_confirmDialog_title =>
      'Overwrite Existing Records';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Existing records will be overwritten After saving, previous records will be lost.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'uložit';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'zrušit';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Potvrdit návrat';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Check-in Status Changes won\'t be applied before saved';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'ukončit';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'zrušit';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Did you stick to your habits today?';

  @override
  String get appReminder_dailyReminder_body =>
      'click to enter app and punch in on time.';

  @override
  String get common_habitColorType_cc1 => 'Tmavě šeříková';

  @override
  String get common_habitColorType_cc2 => 'Červená';

  @override
  String get common_habitColorType_cc3 => 'Purpurová';

  @override
  String get common_habitColorType_cc4 => 'Královská modrá';

  @override
  String get common_habitColorType_cc5 => 'Tmavě azurová';

  @override
  String get common_habitColorType_cc6 => 'Zelená';

  @override
  String get common_habitColorType_cc7 => 'Jantarová';

  @override
  String get common_habitColorType_cc8 => 'Oranžová';

  @override
  String get common_habitColorType_cc9 => 'Limetová zelená';

  @override
  String get common_habitColorType_cc10 => 'Tmavá orchidej';

  @override
  String get common_habitColorType_custom => 'Uživatelsky určené';

  @override
  String common_habitColorType_default(int index) {
    return 'Barva $index';
  }

  @override
  String get common_appThemeColor_system => 'Systémové';

  @override
  String get common_appThemeColor_primary => 'Hlavní';

  @override
  String get common_appThemeColor_dynamic => 'Dynamické';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Use system format';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Formát data';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Year Month Day';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Month Day Year';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Day Month Year';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Oddělovač';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Pomlčka';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text =>
      'Dopředné lomítko';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Mezera';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Tečka';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Bez oddělovače';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: „$splitChar“';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Use 12-hour format';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Use full name';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Apply for Freq Chart';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Apply for Calendar';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'zrušit';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'potvrdit';

  @override
  String get common_errorPage_title => 'Jejda, zhavarovalo!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Povoleno';

  @override
  String get common_dontShowAgain => 'Don\'t show again';

  @override
  String get calendarPicker_clip_today => 'Dnes';

  @override
  String get calendarPicker_clip_tomorrow => 'Zítra';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Příští $dateString';
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
  String get exportConfirmDialog_option_includeRecords => 'zahrnout záznamy';

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
  String get exportConfirmDialog_cancel_buttonText => 'zrušit';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'export';

  @override
  String get debug_logLevelTile_title =>
      'Stupeň podrobnosti zaznamenávání událostí';

  @override
  String get debug_logLevelDialog_title => 'Change Logging Level';

  @override
  String get debug_logLevel_debug => 'Ladění';

  @override
  String get debug_logLevel_info => 'Pro informaci';

  @override
  String get debug_logLevel_warn => 'Varování';

  @override
  String get debug_logLevel_error => 'Chyba';

  @override
  String get debug_logLevel_fatal => 'Fatální';

  @override
  String get debug_collectLogTile_title => 'Shromažďování záznamů událostí';

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
    return 'Stahování $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Debug log doesn\'t exist.';

  @override
  String get debug_debuggerLogCard_title => 'Informace záznamu událostí';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Includes local debugging log information, need to turn on the log collection switcher.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Stáhnout';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Vyčištit';

  @override
  String get debug_debuggerInfoCard_title => 'Ladící informace';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Includes app\'s debugging information.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Otevřít';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Uložit';

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
  String get confirmDialog_cancel_text => 'Zrušit';

  @override
  String get snackbar_undoText => 'ZPĚT';

  @override
  String get snackbar_dismissText => 'ZAHODIT';

  @override
  String get contributors_tile_title => 'Přispěvatelé';

  @override
  String get userAction_tap => 'Klepnutí';

  @override
  String get userAction_doubleTap => 'Dvojité';

  @override
  String get userAction_longTap => 'Dlouhé';

  @override
  String get channelName_habitReminder => 'Připomínka návyku';

  @override
  String get channelName_appReminder => 'Dotázat';

  @override
  String get channelName_appDebugger => 'Nástroj pro ladění';

  @override
  String get channelName_appSyncing => 'Proces synchronizace';

  @override
  String get channelDesc_appSyncing =>
      'Used to show sync progress and non-failure results';

  @override
  String get channelName_appSyncFailed => 'Synchronizace se nezdařila';

  @override
  String get channelDesc_appSyncFailed => 'Used to alert when sync fails';

  @override
  String changelog_banner_title(String version) {
    return 'What\'s New in v$version';
  }

  @override
  String get changelog_banner_action => 'ZAVŘÍT';

  @override
  String get changelog_banner_view => 'ZOBRAZIT';

  @override
  String get changelog_dialog_title => 'Seznam změn';

  @override
  String get changelog_view_full => 'View Full Changelog';

  @override
  String get habitGroup_uncategorized => 'No Group';

  @override
  String get habitDetail_groupTile_title => 'Skupina';

  @override
  String get habitEdit_groupTile_title => 'Skupina';

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
  String get groupManage_deleteDialog_confirm => 'Smazat';

  @override
  String get groupManage_deleteDialog_cancel => 'Zrušit';

  @override
  String get groupManage_deleted_snackbarText => 'Group deleted';

  @override
  String get groupManage_undo_snackbarAction => 'Zpět';

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
  String get groupManage_name_label => 'Název';

  @override
  String get groupManage_desc_label => 'Popis';

  @override
  String groupManage_descTooLong(int max) {
    return 'Description should be ≤ $max characters';
  }

  @override
  String get groupManage_sortTile_text => 'Sort Groups';

  @override
  String get groupManage_sectionTitle_text => 'Skupiny';

  @override
  String get groupManage_createDateTile_title => 'Vytvořeno';

  @override
  String get groupManage_modifyDateTile_title => 'Změněno';

  @override
  String get groupManage_icon_label => 'Ikona';

  @override
  String get groupManage_icon_none => 'Žádná';

  @override
  String get groupManage_color_label => 'Barva';

  @override
  String get groupManage_color_none => 'Žádná';

  @override
  String get groupManage_reorder_tooltip => 'Reorder groups';

  @override
  String get groupManage_menu_edit => 'Upravit';

  @override
  String get groupManage_menu_delete => 'Smazat';

  @override
  String get groupManage_selectAll => 'Vybrat vše';

  @override
  String get groupHeader_menu_manage => 'Spravovat';

  @override
  String get groupHeader_menu_collapseAll => 'Collapse all';

  @override
  String get groupHeader_menu_expandAll => 'Expand all';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Create, edit, and delete habit groups';

  @override
  String get habitDisplay_groupType_manual => 'Ručně';
}
