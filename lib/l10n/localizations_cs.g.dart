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
  String get common_listSeparator => ', ';

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
  String get habitEdit_colorPicker_tintToggleLabel => 'Odstín motivu';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Tónované';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Nezabarvené';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'Odstíny mohou posunout výslednou barvu vůči té, kterou jste zvolili.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Některé barvy mohou zhoršit čitelnost textu v případě světlého nebo tmavého motivu vzhledu.';

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
    return 'Minimální denní práh, výchozí $number';
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
  String get habitEdit_habitDailyGoalUnit_hintText => 'Jednotka denního cíle';

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
  String get habitEdit_targetDays_dialogTitle => 'Vyberte cílové dny';

  @override
  String get habitEdit_targetDays => 'dnů';

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
      'Kdy je třeba zkontrolovat';

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
      'Potvrzujete odstranění této připomínky';

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
      'Přemístit označené návyky do archivu?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'Potvrdit';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'zrušit';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Archivováno $count zvyků';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Vrátit označené skupiny nazpět z archivu?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'Potvrdit';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'zrušit';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count návyků navráceno zpět z archivu';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Smazat označené návyky?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'potvrdit';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'zrušit';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Smazáno $count návyků';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Smazán návyk: „$name“';
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
      'Všechny návyky exportovány';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Vybrat vše';

  @override
  String get habitDisplay_editPopMenu_export => 'Export';

  @override
  String get habitDisplay_editPopMenu_delete => 'Smazat';

  @override
  String get habitDisplay_editPopMenu_clone => 'Šablona';

  @override
  String get habitDisplay_editButton_tooltip => 'Upravit';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archivovat';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Zrušit archivaci';

  @override
  String get habitDisplay_settingButton_tooltip => 'Nastavení';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Stávající';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Dokončené';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Probíhající';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archivováno';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Nej návyky: změny za uplynulých 30 dnů';

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
  String get habitDisplay_groupType_createDate => 'Podle data vytvoření';

  @override
  String get habitDisplay_groupType_habitCount => 'Podle počtu návyků';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Řazení skupiny';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'potvrdit';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'zrušit';

  @override
  String get habitDisplay_groupTypeDialog_none => 'Ploché';

  @override
  String get habitDisplay_editPopMenu_groupModify => 'Upravit skupinu';

  @override
  String get habitDisplay_groupModifyDialog_title => 'Upravit skupinu';

  @override
  String get habitDisplay_groupModifyDialog_removeGroup => 'Odebrat skupinu';

  @override
  String get habitDisplay_groupModifyDialog_emptyGroups =>
      'Nejsou k dispozici žádné skupiny';

  @override
  String get habitDisplay_groupModifyDialog_alreadyInGroup =>
      'Označené návyky už se nacházejí v této skupině';

  @override
  String get habitDisplay_groupModifyDialog_createGroup => 'Vytvořit skupinu';

  @override
  String get habitDisplay_groupModifyDialog_saveAndApply => 'Uložit a použít';

  @override
  String get habitDisplay_groupModifyConfirm_titleNew => 'Přesunout do skupiny';

  @override
  String get habitDisplay_groupModifyConfirm_titleMixed =>
      'Potvrďte změnu skupiny';

  @override
  String habitDisplay_groupModifyConfirm_bodyNewGroup(String groupName) {
    return 'návyky z $groupName budou přesunuty do této skupiny';
  }

  @override
  String get habitDisplay_groupModifyConfirm_bodyRemoveGroup =>
      'Návykům bude odebrána jejich skupina';

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
      'Skupina byla změněna odjinud – není možné provést navrácení zpět';

  @override
  String get habitDisplay_sort_reverseText => 'Obrácené';

  @override
  String get habitDisplay_sortDirection_asc => '(Vzest)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Popis)';

  @override
  String get habitDisplay_sortType_manual => 'Moje pořadí';

  @override
  String get habitDisplay_sortType_name => 'Podle názvu';

  @override
  String get habitDisplay_sortType_colorType => 'Podle barvy';

  @override
  String get habitDisplay_sortType_progress => 'Podle četnosti';

  @override
  String get habitDisplay_sortType_startT => 'Podle data zahájení';

  @override
  String get habitDisplay_sortType_status => 'Podle stavu';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Seřadit';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'Potvrdit';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'zrušit';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️ Ladění';

  @override
  String get habitDisplay_searchBar_hintText => 'Vyhledat zvyky';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Probíhající';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Zobrazit návyky které jsou v tuto chvíli aktivní a probíhající (ne archivované nebo smazané).';

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
  String get habitToday_image_desc => 'DOKÁZALI JSTE TO';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Ponechat po dobu až $days dnů';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Hotovo+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Přeskočit+';

  @override
  String get habitDetail_editButton_tooltip => 'Upravit';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Zrušit archivaci';

  @override
  String get habitDetail_editPopMenu_archive => 'Archivovat';

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
    return 'Stávající známka je $score, a je to $days dnů od zahájení.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Začíná za $days dny.',
      one: 'Začíná zítra.',
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
  String get habitDetail_freqChart_combinedTitle => 'Četnost a historie';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Týden';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Měsíc';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Nyní';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Skrýt graf historie';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Zobrazit graf historie';

  @override
  String get habitDetail_descSubgroup_title => 'Pozn.';

  @override
  String get habitDetail_otherSubgroup_title => 'Ostatní';

  @override
  String get habitDetail_habitType_title => 'Typ';

  @override
  String get habitDetail_reminderTile_title => 'Připomenutí';

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
      'zpět na dnešek';

  @override
  String get common_loadError_text => 'Nepodařilo se načíst';

  @override
  String get common_loadError_retryText => 'Zkusit znovu';

  @override
  String get habitDetail_notFoundText => 'Načtení návyku se nezdařilo';

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
    return 'Denní cíl, výchozí: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'zrušit';

  @override
  String get habitDetail_changeGoal_saveText => 'uložit';

  @override
  String get habitDetail_skipReason_title => 'Důvod přeskočení';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Něco sem napište…';

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
      'Přetáhněte kalendář po stránce';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Pokud je přepínač zapnutý, kalendář v pruhu aplikace na domovské stránce bude tažen s sebou po jednotlivých stránkách. Ve výchozím stavu je toto chování vypnuto.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Změnit stav záznamu';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Upravit chování klikání pro změnu stavu denních záznamů na hlavní stránce.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Otevřít podrobný záznam';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Změnit chování kliknutí pro otevření podrobného vyskakovacího podokna pro denní záznamy na hlavní stránce.';

  @override
  String get appSetting_expandTimerDelayTile_titleText =>
      'Prodleva rozbalení skupiny';

  @override
  String get appSetting_expandTimerDelayTile_subtitleText =>
      'Nastavit jak dlouho je třeba ponechat ukazatel najetý na záhlaví sbalené skupiny než se v rámci operace přetahování automaticky rozbalí.';

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
      'Zvolte motiv barev';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Použít hlavní barvu tapety (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'Použít vybranou barvu pozadí motivu GTK+';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Použít barvu systémového motivu';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Použít systémové zvýraznění nebo barvu okna/skla';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'První den v týdnu';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Zobrazit první den týdne';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Výchozí)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Podle systému ($localeName)';
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
      'Nastavení jazyka systému';

  @override
  String get appSetting_openSystemLanguageTile_dialogTitle =>
      'Otevřít nastavení jazyka systému';

  @override
  String get appSetting_openSystemLanguageTile_macosDialogContent =>
      'Kvůli omezením na straně macOS není možné měnit jazyk přímo v aplikaci. Pokud toto potřebujete provést, proveďte následující:\n\n1. Otevřete **Nastavení systému > Obecné > Jazyk a oblast**\n2. Přidejte tuto aplikaci do seznamu **Aplikace** a zvolte jazyk';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Formát zobrazení data ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'převzít z nastavení systému';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Nastavený formát data bude uplatněn na zobrazení data na stránce podrobností o návyku.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Zhustit podobu uživatelského rozhraní stránky s návyky';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Umožnit tabulce kontroly zvyků zobrazovat více obsahu, ale některé prvky uživatelského rozhraní a texty se mohou jevit jako (příliš) malé.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Přizpůsobení bezdrátového oblasti kontroly návyku';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Upravte procento pro více/méně prostoru v oblasti tabulky kontroly návyků.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Výchozí';

  @override
  String get appSetting_reminderSubgroupText => 'Připomínka a oznámení';

  @override
  String get appSetting_dailyReminder_titleText => 'Denní připomenutí';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Záloha a obnovení';

  @override
  String get appSetting_export_titleText => 'Export';

  @override
  String get appSetting_export_subtitleText =>
      'Návyky vyexportovány v JSON formátu. Z tohoto souboru je možné kdykoli naimportovat nazpátek.';

  @override
  String get appSetting_import_titleText => 'Import';

  @override
  String get appSetting_import_subtitleText =>
      'Naimportovat návyky z json souboru.';

  @override
  String get appSetting_thirdPartyImport_titleText =>
      'Naimportovat od třetí strany';

  @override
  String get appSetting_thirdPartyImport_subtitleText =>
      'Importovat návyky z jiných aplikací pro sledování návyků';

  @override
  String get appSetting_thirdPartyImport_provider_loopName =>
      'Loop Habit Tracker';

  @override
  String get appSetting_thirdPartyImport_provider_versionHint =>
      'Podporuje CSV (testováno až do <ver/>)';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Potvrdit import $count návyků?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Pozn.: Import nevymaže existující návyky.';

  @override
  String get appSetting_importDialog_option_includeHabits => 'Zahrnovat návyky';

  @override
  String get appSetting_importDialog_option_includeGroups => 'Zahrnout skupiny';

  @override
  String appSetting_importDialog_tile_includeHabits(int count) {
    return 'Zahrnout $count návyků';
  }

  @override
  String appSetting_importDialog_tile_includeGroups(int count) {
    return 'Zahrnout $count skupin';
  }

  @override
  String appSetting_importConfirmDialog_sourceLabel(String provider) {
    return 'Zdroj: $provider';
  }

  @override
  String get appSetting_thirdPartyImport_error_fileReadError =>
      'Zvolený soubor se nepodařilo načíst.';

  @override
  String get appSetting_thirdPartyImport_error_noHabitsFound =>
      'V importním souboru nenalezeny žádné návyky.';

  @override
  String get appSetting_thirdPartyImport_error_parseError =>
      'Importovaný soubor se nepodařilo zpracovat';

  @override
  String get appSetting_thirdPartyImport_error_unknown =>
      'Při importu došlo k neočekávané chybě.';

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
    return 'Dokončit import $count návyků';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Dokončen import $count skupin';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'zavřít';

  @override
  String get appSetting_resetConfig_titleText => 'Resetovat nastavení';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Vrátit veškerá nastavení na výchozí hodnoty.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Resetovat nastavení?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Vrátit veškerá nastavení na výchozí hodnoty. Aby se projevilo, je třeba poté aplikaci restartovat.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'zrušit';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'potvrdit';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'nastavení aplikace úspěšně vrácena do výchozího stavu';

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
      'Po vyčištění mezipaměti budou některé uživatelsky určené hodnoty obnoveny do výchozího stavu.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'zrušit';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'potvrdit';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Vymazání mezipaměti neúplného se nezdařilo';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Mezipaměť úspěšně vymazána';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Vymazání mezipaměti se nezdařilo';

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
  String get appSetting_notify_subtitleTile => 'Spravovat předvolby oznamování';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Klepnutím otevřete systémové nastavení notifikací';

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
  String get appSync_nowTile_text_noDate => 'Poslední synchronizace: N/A';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Poslední synchronizace: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Poslední synchronizace (Chyba): N/A';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Poslední synchronizace (chyba): $dateStr';
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
  String get appSync_nowTile_cancelText_noDate =>
      'Poslední synchronizace (zrušena): N/A';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Poslední synchronizace (zrušena): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText =>
      'Podívejte se do záznamů událostí při selhání';

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
      'Synchronizování vytvoří nezbytné složky a nahraje lokální návyky na server. Pokračovat?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Synchronizovat nyní!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Potvrdit synchronizaci';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Složka není prázdná. Synchronizování sloučí návyky ze serveru s těmi lokálními. Pokračovat?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Potvrdit sloučení';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Exportovat záznamy událostí nezdařené synchronizace';

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
      'Záznamy událostí veškerých nedávných nezdařených synchronizací';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Potvrďte uložení změn';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Uložení přepíše předchozí nastavení pro server.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'Neuložené změny';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Ukončení zahodí veškeré neuložené změny.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Potvrdit smazání';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Smazání odebere stávající nastavení pro server.';

  @override
  String get appSync_serverEditor_titleText_add => 'Nový synchronizační server';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Upravit synchronizační server';

  @override
  String get appSync_serverEditor_advance_titleText => 'Pokročilá nastavení';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Popis umístění';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Sem zadejte platný WebDAV popis umístění.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Popis umístění je třeba vyplnit!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Uživatelské jméno';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Sem zadejte uživatelské jméno (pokud není vyžadováno, nevyplňujte).';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Heslo';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Ignorovat SSL certifikát';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Sekundy časového limitu synchronizace';

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
      'Sekundy časového limit síťového připojení';

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
      'Počet pokusů o síťové připojení';

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
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Režim synchronizace po síti';

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
  String get appSync_noti_readyToSync_body => 'Příprava synchronizace…';

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
      'Synchronizovat v režimu s málo daty';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Je zapnutá jedna nebo více experimentálních funkcí – používejte je obezřetně.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Synchronizace s Habit Cloud';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Jakmile zapnuto, v nastavení se objeví předvolby synchronizace aplikace';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Experimental feature ($syncName) is disabled, but the function is still running.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Pro úplné zakázání, dlouze podržte pro přístup k „$menuName“ a vypněte to.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'Hledání návyku';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Jakmile zapnuto, v horní části okna aplikace se objeví pruh pro vyhledávání v návycích.';

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
      'Zdravím, těší mne, že jste na mne obrátili.\nPokud nahlašujete chybu, prosím dejte vědět verzi aplikace a popište kroky potřebné k zopakování jejího projevení se.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licence';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache licence, verze 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Prohlášení licencování třetích stran';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Soukromí';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Přístup k zásadám ochrany osobních údajů v této aplikaci';

  @override
  String get appAbout_donateTile_titleText => 'Podpořit darováním';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Jsem samostatně působící vývojář. Pokud se Vám tato aplikace líbí, prosím kupte mi ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Koupit mi kávu';

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
  String get donateWay_firstQRGroup => 'Alipay a Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'Zkopírována adresa $name';
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
      other: 'návyky',
      one: 'návyk',
    );
    return 'vybrán $count $_temp0';
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
      'Přepsát stávající záznamy';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Existující záznamy budou přepsány. Po uložení budou předchozí záznamy ztraceny.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'uložit';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'zrušit';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Potvrdit návrat';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Změny stavu přihlášení nebudou použity před uložením';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'ukončit';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'zrušit';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Držíte se dnes svých návyků?';

  @override
  String get appReminder_dailyReminder_body =>
      'kliknutím vstupte do aplikace a odpíchněte si čas.';

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
      'Použít formát systému';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Formát data';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Rok měsíc den';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Měsíc den rok';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Den měsíc rok';

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
      'Používat 12hodinový formát';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Používat celý název';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Použít na graf četnosti';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Uplatnit na kalendář';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'zrušit';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'potvrdit';

  @override
  String get common_errorPage_title => 'Jejda, zhavarovalo!';

  @override
  String get common_errorPage_copied => 'Informace o pádu zkopírována';

  @override
  String get common_enable_text => 'Povoleno';

  @override
  String get common_dontShowAgain => 'Příště se už nezobrazovat';

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
  String get exportConfirmDialog_title_exportAll =>
      'Exportovat všechny návyky?';

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
  String get exportConfirmDialog_option_includeGroups => 'zahrnují skupiny';

  @override
  String exportConfirmDialog_tile_includeRecords(int count) {
    return 'Zahrnout $count záznamů';
  }

  @override
  String exportConfirmDialog_tile_includeGroups(int count) {
    return 'Zahrnout $count skupin';
  }

  @override
  String get exportConfirmDialog_cancel_buttonText => 'zrušit';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'export';

  @override
  String get debug_logLevelTile_title =>
      'Stupeň podrobnosti zaznamenávání událostí';

  @override
  String get debug_logLevelDialog_title =>
      'Změnit úroveň podrobností záznamu událostí';

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
      'Klepnutím zastavíte shromažďování záznamu událostí.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Klepnutím spustíte sběr záznamů událostí.';

  @override
  String get debug_downladDebugLogs_subject =>
      'Stahování ladících záznamů událostí';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Záznamy ladících událostí smazány.';

  @override
  String get debug_downladDebugInfo_subject => 'Stahování ladicích informací';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Stahování $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Záznam ladících událostí neexistuje.';

  @override
  String get debug_debuggerLogCard_title => 'Informace záznamu událostí';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Zahrnout informace z lokálního záznamu ladicích událostí – vyžaduje zapnutí přepínače shromažďování záznamů událostí.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Stáhnout';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Vyčištit';

  @override
  String get debug_debuggerInfoCard_title => 'Ladící informace';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Obsahuje ladicí informace aplikace.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Otevřít';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Uložit';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Shromažďování informací o aplikaci…';

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
      'Slouží k zobrazování postupu synchronizace a nechybových výsledků';

  @override
  String get channelName_appSyncFailed => 'Synchronizace se nezdařila';

  @override
  String get channelDesc_appSyncFailed =>
      'Slouží k upozornění když se nezdaří synchronizace';

  @override
  String changelog_banner_title(String version) {
    return 'Co je nového ve v$version';
  }

  @override
  String get changelog_banner_action => 'ZAVŘÍT';

  @override
  String get changelog_banner_view => 'ZOBRAZIT';

  @override
  String get changelog_dialog_title => 'Seznam změn';

  @override
  String get changelog_view_full => 'Zobrazit celý seznam změn';

  @override
  String get habitGroup_uncategorized => 'Žádná skupina';

  @override
  String get habitDetail_groupTile_title => 'Skupina';

  @override
  String get habitEdit_groupTile_title => 'Skupina';

  @override
  String get habitEdit_groupPicker_hintText => 'Hledat nebo vytvořit skupinu';

  @override
  String get habitEdit_groupPicker_noGroup => 'Žádná skupina';

  @override
  String habitEdit_groupPicker_createGroup(String name) {
    return 'Vytvořit „$name“';
  }

  @override
  String get habitEdit_groupPicker_loading => 'Načítání skupin…';

  @override
  String get groupManage_appbar_title => 'Spravovat skupiny';

  @override
  String groupManage_selectionAppbar_title(int count) {
    return '$count vybráno';
  }

  @override
  String get groupManage_emptyState_text =>
      'Zatím ještě žádné skupiny\nVytvořte svou první skupinu klepnutím na +';

  @override
  String get groupManage_deleteDialog_title => 'Odstranit skupinu';

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
  String get groupManage_deleted_snackbarText => 'Skupina smazána';

  @override
  String get groupManage_undo_snackbarAction => 'Zpět';

  @override
  String get groupManage_editDialog_title => 'Upravit skupinu';

  @override
  String get groupManage_createDialog_title => 'Vytvořit skupinu';

  @override
  String get groupManage_nameRequired => 'Skupinu je třeba nějak nazvat';

  @override
  String groupManage_nameTooLong(int max) {
    return 'Je třeba, aby název nebyl delší než $max znaků';
  }

  @override
  String get groupManage_name_label => 'Název';

  @override
  String get groupManage_desc_label => 'Popis';

  @override
  String groupManage_descTooLong(int max) {
    return 'Je třeba, aby popis nebyl delší než $max znaků';
  }

  @override
  String get groupManage_sortTile_text => 'Seřadit skupiny';

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
  String get groupManage_reorder_tooltip => 'Přeuspořádat skupiny';

  @override
  String get groupManage_menu_edit => 'Upravit';

  @override
  String get groupManage_menu_delete => 'Smazat';

  @override
  String get groupManage_selectAll => 'Vybrat vše';

  @override
  String get groupHeader_menu_manage => 'Spravovat';

  @override
  String get groupHeader_menu_collapseAll => 'Sbalit vše';

  @override
  String get groupHeader_menu_expandAll => 'Rozbalit vše';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Vytvářejte, upravujte a mažte skupiny návyků';

  @override
  String get habitDisplay_groupType_manual => 'Ručně';
}
