// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class L10nHu extends L10n {
  L10nHu([String locale = 'hu']) : super(locale);

  @override
  String get localeScriptName => 'Hungarian';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Mentés';

  @override
  String get habitEdit_habitName_hintText => 'Szokás neve ...';

  @override
  String get habitEdit_colorPicker_title => 'Válassz színt';

  @override
  String get habitEdit_habitTypeDialog_title => 'Szokás típusa';

  @override
  String get habitEdit_habitType_positiveText => 'Pozitív';

  @override
  String get habitEdit_habitType_negativeText => 'Negatív';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Napi cél, alapértelmezett $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Minimális napi küszöbérték, alapértelmezett $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'napi cél > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'napi cél ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'napi cél ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'napi cél ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Napi célegység';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Kívánt maximális napi cél';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'érvénytelen érték, üresnek kell lennie, vagy ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Maximális napi limit';

  @override
  String get habitEdit_frequencySelector_title => 'Válassza ki a frekvenciát';

  @override
  String get habitEdit_habitFreq_daily => 'Napi';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% alkalommal hetente';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'alkalommal havonta';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'alkalommal';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'nap alatt';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Napi';

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
  String get habitEdit_targetDays_dialogTitle => 'Válassza a Célnapok';

  @override
  String get habitEdit_targetDays => 'nap';

  @override
  String get habitEdit_reminder_hintText => 'Emlékeztető';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'A hét bármely napja';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' minden héten';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'A hónap bármely napja';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' minden hónapban';

  @override
  String get habitEdit_reminderQuest_hintText => 'Kérdés, pl.: Mozogtál ma?';

  @override
  String get habitEdit_reminder_dialogTitle =>
      'Válassza ki az emlékeztető típusát';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Mikor kell bejelentkezni';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Napi';

  @override
  String get habitEdit_reminder_dialogType_week => 'Hetente';

  @override
  String get habitEdit_reminder_dialogType_month => 'Havonta';

  @override
  String get habitEdit_reminder_dialogConfirm => 'megerősítés';

  @override
  String get habitEdit_reminder_dialogCancel => 'mégse';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Megerősítés';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Megerősíti az emlékeztető eltávolítását';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'megerősítés';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'mégse';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Hétfő';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Kedd';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Szerda';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Csütörtök';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Péntek';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Szombat';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Vasárnap';

  @override
  String get habitEdit_desc_hintText => 'Feljegyzés, támogatja a Markdownt';

  @override
  String get habitEdit_create_datetime_prefix => 'Létrehozva: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Módosítva: ';

  @override
  String get habitDisplay_fab_text => 'Új szokás';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'Az ezer mérföldes utazás egyetlen lépéssel kezdődik';

  @override
  String get habitDisplay_notFoundImage_text_01 =>
      'Nem találhatók megfelelő szokások';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'Nincsenek megfelelő szokások a \"$keyword\" számára';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Archiválja a kiválasztott szokásokat?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'megerősítés';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'mégse';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count szokás archiválva';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Visszavonja a kiválasztott szokások archiválásaát?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'megerősítés';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'mégse';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count szokás archiválésa visszavonva';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Törli a kiválasztott szokásokat?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'megerősítés';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'mégse';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count szokás törölve';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Törölt szokás: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count szokás exportálva.',
      one: 'Szokás exportálva.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Összes szokás exportálva';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Összes kijelölése';

  @override
  String get habitDisplay_editPopMenu_export => 'Exportálás';

  @override
  String get habitDisplay_editPopMenu_delete => 'Törlés';

  @override
  String get habitDisplay_editPopMenu_clone => 'Sablon';

  @override
  String get habitDisplay_editButton_tooltip => 'Szerkesztés';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archiválás';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Archiválás visszavonása';

  @override
  String get habitDisplay_settingButton_tooltip => 'Beállítások';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Aktuális';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Teljesített';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Folyamatban lévő';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archivált';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Legnépszerűbb szokások: az elmúlt 30 nap változásai';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Világos téma';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Sötét téma';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Rendszer követése';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Archiváltak megjelenítése';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'Teljesítettek megjelenítése';

  @override
  String get habitDisplay_mainMenu_showActivedTileText =>
      'Aktívak megjelenítése';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Beállítások';

  @override
  String get habitDisplay_sort_reverseText => 'Fordított';

  @override
  String get habitDisplay_sortDirection_asc => '(Növ.)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Csök.)';

  @override
  String get habitDisplay_sortType_manual => 'Saját sorrend';

  @override
  String get habitDisplay_sortType_name => 'Név';

  @override
  String get habitDisplay_sortType_colorType => 'Szín';

  @override
  String get habitDisplay_sortType_progress => 'Sűrűség';

  @override
  String get habitDisplay_sortType_startT => 'Kezdő dátum lapján';

  @override
  String get habitDisplay_sortType_status => 'Állapot';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Rendezés';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'megerősítés';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'mégse';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Hibakeresés';

  @override
  String get habitDisplay_searchBar_hintText => 'Szokás keresése';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Folyamatban lévő';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Megjeleníti azokat a szokásokat, amelyek jelenleg aktívak és folyamatban vannak (nem archiváltak vagy töröltek).';

  @override
  String get habitDisplay_searchFilter_completed => 'Teljesített';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Szokás típusa';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Szűrők megjelenítése';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Szűrők törlése';

  @override
  String get habitDisplay_tab_habits_label => 'Szokások';

  @override
  String get habitDisplay_tab_today_label => 'Ma';

  @override
  String get habitToday_appBar_title => 'Ma';

  @override
  String get habitToday_image_desc => 'MEGCSINÁLTAD!';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Kitartottál mellette $days napig';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Kész+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Kihagyás+';

  @override
  String get habitDetail_editButton_tooltip => 'Szerkesztés';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Archiválás visszavonása';

  @override
  String get habitDetail_editPopMenu_archive => 'Archiválás';

  @override
  String get habitDetail_editPopMenu_export => 'Exportálás';

  @override
  String get habitDetail_editPopMenu_delete => 'Törlés';

  @override
  String get habitDetail_editPopMenu_clone => 'Sablon';

  @override
  String get habitDetail_confirmDialog_confirm => 'megerősítés';

  @override
  String get habitDetail_confirmDialog_cancel => 'mégse';

  @override
  String get habitDetail_archiveConfirmDialog_titleText =>
      'Archiválja a szokást?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Szokás archiválásának visszaállítása?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Törli a szokást?';

  @override
  String get habitDetail_summary_title => 'Összegzés';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'A jelenlegi értékelés $score, és $days nap telt el a kezdés óta.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days nap múlva kezdődik.',
      one: 'Holnaptól kezdődik.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'ALACSONY SZINT',
      one: 'NEM TELJESÍTETT',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'TÖKÉLETES',
      one: 'TÚLTELJESÍTETT',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Cél',
      two: 'Küszöb',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Mértékegység: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Napok',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'nap';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Értékek';

  @override
  String get habitDetail_scoreChart_title => 'Értékelés';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Nap';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Hét';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Hónap';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Év';

  @override
  String get habitDetail_freqChart_freqTitle => 'Sűrűség';

  @override
  String get habitDetail_freqChart_historyTitle => 'Előzmény';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Sűrűség & Előzmény';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Hét';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Hónap';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Év';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Most';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Előzmények diagram elrejtése';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Előzmények diagram megjelenítése';

  @override
  String get habitDetail_descSubgroup_title => 'Jegyzet';

  @override
  String get habitDetail_otherSubgroup_title => 'Más';

  @override
  String get habitDetail_habitType_title => 'Típus';

  @override
  String get habitDetail_reminderTile_title => 'Emlékeztető';

  @override
  String get habitDetail_freqTile_title => 'Ismétlés';

  @override
  String get habitDetail_startDateTile_title => 'Kezdő dátum';

  @override
  String get habitDetail_createDateTile_title => 'Létrehozva';

  @override
  String get habitDetail_modifyDateTile_title => 'Módosítva';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'dátum';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'érték';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'vissza a mai naphoz';

  @override
  String get habitDetail_notFoundText => 'Szokás betöltése sikertelen';

  @override
  String get habitDetail_notFoundRetryText => 'Próbáld újra';

  @override
  String get habitDetail_changeGoal_title => 'Cél változtatása';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'jelenlegi: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'kész: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'nem teljesített';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Napi cél, alapértelmezett: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'mégse';

  @override
  String get habitDetail_changeGoal_saveText => 'mentés';

  @override
  String get habitDetail_skipReason_title => 'Kihagyás oka';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Írj ide valamit...';

  @override
  String get habitDetail_skipReason_cancelText => 'mégse';

  @override
  String get habitDetail_skipReason_saveText => 'mentés';

  @override
  String get appSetting_appbar_titleText => 'Beállítások';

  @override
  String get appSetting_displaySubgroupText => 'Megjelenítés';

  @override
  String get appSetting_operationSubgroupText => 'Művelet';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Naptár húzása oldalanként';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Ha a kapcsoló be van kapcsolva, a kezdőlap felső sávjában lévő naptár oldalanként húzható. Alapértelmezés szerint a kapcsoló ki van kapcsolva.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Bejegyzés állapotának módosítása';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Módosítsd a kattintási viselkedést úgy, hogy a főoldalon a napi bejegyzések állapotát lehessen változtatni.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Részletes bejegyzés megnyitása';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Módosítsd a kattintási viselkedést úgy, hogy a főoldalon a napi bejegyzésekhez tartozó részletes felugró ablak nyíljon meg.';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Téma színe';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'Téma színének kiválasztása';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'A háttérkép fő színének használata (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'A GTK+ téma kiválasztott háttérszínének használata';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'A rendszer téma színének használata';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'A rendszer kiemelőszínének vagy ablak/üveg színének használata';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'A hét első napja';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Mutassa a hét első napját';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText =>
      ' (Alapértelmezett)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Renszer követése ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Rendszer Követése';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Nyelv';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Nyelv kiválasztása';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Dátum megjelenítési formátuma ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'rendszer követése';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'A beállított dátumformátum a szokás részletei oldalon jelenik meg.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Kompakt felület engedélyezése a szokások oldalán';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Lehetővé teszi, hogy a szokások ellenőrző táblája több tartalmat jelenítsen meg, de egyes UI elemek és szövegek kisebbnek tűnhetnek.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Szokások ellenőrző terület rádió-beállítása';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Állítsd a százalékos arányt a szokások ellenőrző táblájában több vagy kevesebb hely biztosításához.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText =>
      'Alapértelmezett';

  @override
  String get appSetting_reminderSubgroupText => 'Emlékeztető & Értesítés';

  @override
  String get appSetting_dailyReminder_titleText => 'Napi emlékeztető';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Biztonsági mentés és visszaállítás';

  @override
  String get appSetting_export_titleText => 'Exportálás';

  @override
  String get appSetting_export_subtitleText =>
      'A szokások JSON formátumban exportálva. Ez a fájl visszaimportálható.';

  @override
  String get appSetting_import_titleText => 'Importálás';

  @override
  String get appSetting_import_subtitleText =>
      'Szokások importálása JSON fájlból';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Importáljuk a $count szokást?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Megjegyzés: Az importálás nem törli a meglévő szokásokat.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'Megerősítés';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'mégse';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'Importálva $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return '$count importálása befejezve';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'bezárás';

  @override
  String get appSetting_resetConfig_titleText => 'Konfiguráció visszaállítása';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Összes konfiguráció visszaállítása alapértelmezettre';

  @override
  String get appSetting_resetConfigDialog_titleText =>
      'Visszaállítja a konfigurációkat?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Az összes beállítás alapértelmezettre állítása, az alkalmazást újra kell indítani az érvényesítéshez.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'mégse';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'megerősítés';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'reset app configs succeed';

  @override
  String get appSetting_otherSubgroupText => 'Egyéb';

  @override
  String get appSetting_developMode_titleText => 'Fejlesztői mód';

  @override
  String get appSetting_clearCache_titleText => 'Gyorsítótár törlése';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Gyorsítótár törlése';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'A gyorsítótár törlése után néhány egyéni érték alapértelmezett értékre áll vissza.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'mégse';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'megerősítés';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'A részleges gyorsítótár törlése sikertelen';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Gyorsítótár sikeresen törölve';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Gyorsítótár törlése sikeretelen';

  @override
  String get appSetting_debugger_titleText => 'Hibakeresés info';

  @override
  String get appSetting_about_titleText => 'Névjegy';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Kísérleti beállítások';

  @override
  String get appSetting_synSubgroupText => 'Szinkronizálás';

  @override
  String get appSetting_syncOption_titleText => 'Szinkronizálás opciók';

  @override
  String get appSetting_notify_titleTile => 'Értesítések';

  @override
  String get appSetting_notify_subtitleTile =>
      'Értesítési beállítások kezelése';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Koppints a rendszer értesítési beállításainak megnyitásához';

  @override
  String get appSync_nowTile_titleText => 'Szinkronizálás most';

  @override
  String get appSync_nowTile_titleText_syncing => 'Szinkronizálás';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'Utolsó szinkronizálás: N/A';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Utolsó szinkronizálás: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Utolsó szinkronizálás (Hiba): N/A';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Utolsó szinkronizálás (Hiba): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Szinkronizálás...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Szinkronizálás: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Mégsem...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Utolsó szinkronizálás (Törölve): N/A';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Utolsó szinkronizálás (Törölve): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Hiba napló keresése';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Hiba]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Befejezve',
      'cancelled': 'Mégsem',
      'failed': 'Sikertelen',
      'multi': 'Többszörös állapotok',
      'other': 'Ismeretlen állapot',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Befejezve ($reason miatt)',
      'cancelled': 'Mégsem ($reason miatt)',
      'failed': 'Sikertelen ($reason miatt)',
      'multi': 'Többszörös állapotok ($reason miatt)',
      'other': 'Ismeretlen állapot',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Hiba',
      'userAction': 'Felhasználói művelet szükséges',
      'missingHabitUuid': 'Hiányzó szokás UUID',
      'empty': 'Üres adat',
      'other': 'Ismeretlen ok',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'Új hely';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'A szinkron létrehozza a szükséges könyvtárakat és feltölti a helyi szokásokat a szerverre. Folytatod?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Szinkron most!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Szinkron megerősítése';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'A könyvtár nem üres. A szinkron összevonja a szerver és a helyi szokásokat. Folytatod?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Összevonás megerősítése';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Sikertelen szinkron naplók exportálása';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'Nincs napló',
      'false': 'Koppints az exportáláshoz',
      'other': 'betöltés...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Aktuális: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Fake (Csak hibakereséshez)',
      'other': 'Ismeretlen ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Mobil',
      'wifi': 'Wi-Fi',
      'other': 'Ismeretlen',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Kézi',
      'minute5': '5 perc',
      'minute15': '15 perc',
      'minute30': '30 perc',
      'hour1': '1 óra',
      'other': 'Ismeretlen',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Lekérdezési időköz';

  @override
  String get appSync_summaryTile_title => 'Szinkron szerver';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Nincs beállítva';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Minden legutóbbi sikertelen szinkron napló';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Módosítások mentésének megerősítése';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'A mentés felülírja az előző szerverkonfigurációt.';

  @override
  String get appSync_serverEditor_exitDialog_titleText =>
      'Mentetlen módosítások';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Kilépéskor minden mentetlen módosítás elvész.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText =>
      'Törlés megerősítése';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'A törlés eltávolítja az aktuális szerverkonfigurációt.';

  @override
  String get appSync_serverEditor_titleText_add => 'Új szinkron szerver';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Szinkron szerver módosítása';

  @override
  String get appSync_serverEditor_advance_titleText => 'Speciális beállítások';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Elérési út';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Írd be ide az érvényes WebDAV elérési utat.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Az elérési út nem lehet üres!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Felhasználónév';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Add meg a felhasználónevet, hagyd üresen, ha nem szükséges.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Jelszó';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'SSL tanúsítvány figyelmen kívül hagyása';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Szinkron időkorlát (másodperc)';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Végtelen',
    );
    return 'Alapértelmezett: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 'mp';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Hálózati kapcsolat időkorlát (mp)';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Végtelen',
    );
    return 'Alapértelmezett: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 'mp';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Hálózati újrapróbálkozások száma';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Újrapróbálkozás letiltva',
    );
    return 'Alapértelmezett: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Hálózati szinkron mód';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Szinkron mobilhálózaton',
      'wifi': 'Szinkron Wi-Fi-n',
      'other': 'Ismeretlen',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText =>
      'Alacsony adatforgalom';

  @override
  String get appSync_noti_readyToSync_body => 'Szinkron előkészítése...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Szinkron kész ($type)',
      'failed': 'Szinkron sikertelen ($type)',
      'other': 'Szinkron folyamatban ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Szinkron alacsony adatforgalom módban';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Egy vagy több kísérleti funkció engedélyezve, használatukkal óvatosan.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Szokások felhő szinkron';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Engedélyezés után a szinkron opció megjelenik a beállításokban';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'A kísérleti funkció ($syncName) le van tiltva, de a funkció továbbra is fut.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Teljes kikapcsoláshoz hosszú nyomással nyisd meg a \'$menuName\' menüt, és kapcsold ki.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'Szokás keresés';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Engedélyezés után a Szokások képernyő tetején keresősáv jelenik meg, ahol szokások kereshetők.';

  @override
  String get appAbout_appbarTile_titleText => 'Névjegy';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Verzió: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Forráskód';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Hibakövető';

  @override
  String get appAbout_contactEmailTile_titleText => 'Kapcsolatfelvétel';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Szia, örülök, hogy megkerestél.\nHa hibát jelzel, kérlek add meg az alkalmazás verzióját és írd le a reprodukálás lépéseit.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licenc';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Harmadik fél licenc nyilatkozat';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Adatvédelem';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Az alkalmazásban elérheted az adatvédelmi szabályzatot';

  @override
  String get appAbout_donateTile_titleText => 'Adományozás';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Személyes fejlesztő vagyok. Ha tetszik az alkalmazás, vegyél nekem egy ☕-t.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Vegyél nekem egy kávét';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Kriptovaluták';

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
    return '$name cím másolva';
  }

  @override
  String get batchCheckin_appbar_title => 'Tömeges bejelentkezés';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Előző nap';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Következő nap';

  @override
  String get batchCheckin_status_skip_text => 'Kihagyás';

  @override
  String get batchCheckin_status_ok_text => 'Teljesítve';

  @override
  String get batchCheckin_status_double_text => 'x2 Találat!';

  @override
  String get batchCheckin_status_zero_text => 'Nem teljesített';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'szokás',
      one: 'szokás',
    );
    return '$count $_temp0 kiválasztva';
  }

  @override
  String get batchCheckin_save_button_text => 'Mentés';

  @override
  String get batchCheckin_reset_button_text => 'Visszaállítás';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count szokás állapota',
      one: 'a szokás állapota',
    );
    return 'Módosítva $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title =>
      'Meglévő bejegyzések felülírása';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'A meglévő bejegyzések felülíródnak. Mentés után az előző bejegyzések elvesznek.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'mentés';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'mégse';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Kilépés megerősítése';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'A bejelentkezés állapotváltozásai nem kerülnek mentésre.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'kilépés';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'mégse';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Ma betartottad a szokásaidat?';

  @override
  String get appReminder_dailyReminder_body =>
      'Kattints a belépéshez és időben jelöld a teljesítést.';

  @override
  String get common_habitColorType_cc1 => 'Mélykáprázat lila';

  @override
  String get common_habitColorType_cc2 => 'Piros';

  @override
  String get common_habitColorType_cc3 => 'Lila';

  @override
  String get common_habitColorType_cc4 => 'Királis kék';

  @override
  String get common_habitColorType_cc5 => 'Sötét cián';

  @override
  String get common_habitColorType_cc6 => 'Zöld';

  @override
  String get common_habitColorType_cc7 => 'Ámbersárga';

  @override
  String get common_habitColorType_cc8 => 'Narancs';

  @override
  String get common_habitColorType_cc9 => 'Lime zöld';

  @override
  String get common_habitColorType_cc10 => 'Sötét orchidea';

  @override
  String common_habitColorType_default(int index) {
    return 'Szín $index';
  }

  @override
  String get common_appThemeColor_system => 'Rendszer';

  @override
  String get common_appThemeColor_primary => 'Elsődleges';

  @override
  String get common_appThemeColor_dynamic => 'Dinamikus';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Rendszer formátum használata';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Dátum formátum';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Év Hónap Nap';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Hónap Nap Év';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Nap Hónap Év';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Elválasztó';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Kötőjel';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Perjel';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Szóköz';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Pont';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Nincs elválasztó';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      '12 órás formátum használata';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Teljes hónapnév használata';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Alkalmazás a gyakorisági diagramhoz';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Alkalmazás a naptárhoz';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'mégse';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text =>
      'megerősítés';

  @override
  String get common_errorPage_title => 'Hoppá, összeomlott!';

  @override
  String get common_errorPage_copied => 'Összeomlási információk másolva';

  @override
  String get common_enable_text => 'Engedélyezve';

  @override
  String get calendarPicker_clip_today => 'Ma';

  @override
  String get calendarPicker_clip_tomorrow => 'Holnap';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Következő $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'Minden szokás exportálása?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number szokást',
      one: '1 szokást',
      zero: 'a jelenlegi szokást',
    );
    return 'Exportáljuk $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords =>
      'bejegyzésekkel együtt';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'mégse';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'exportálás';

  @override
  String get debug_logLevelTile_title => 'Naplózási szint';

  @override
  String get debug_logLevelDialog_title => 'Naplózási szint módosítása';

  @override
  String get debug_logLevel_debug => 'Debug';

  @override
  String get debug_logLevel_info => 'Info';

  @override
  String get debug_logLevel_warn => 'Figyelmeztetés';

  @override
  String get debug_logLevel_error => 'Hiba';

  @override
  String get debug_logLevel_fatal => 'Kritikus';

  @override
  String get debug_collectLogTile_title => 'Naplók gyűjtése';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Koppints a naplózás leállításához.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Koppints a naplózás elindításához.';

  @override
  String get debug_downladDebugLogs_subject => 'Naplók letöltése';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Naplók törölve.';

  @override
  String get debug_downladDebugInfo_subject => 'Debug információk letöltése';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return '$fileName letöltése';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Naplófájl nem található.';

  @override
  String get debug_debuggerLogCard_title => 'Napló információk';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Tartalmazza a helyi naplóadatokat, a gyűjtéshez a kapcsolót be kell kapcsolni.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Letöltés';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Törlés';

  @override
  String get debug_debuggerInfoCard_title => 'Debug információk';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Tartalmazza az alkalmazás hibakeresési adatait.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Megnyitás';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Mentés';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Alkalmazás információinak gyűjtése...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Mentés',
      'exit': 'Kilépés',
      'delete': 'Törlés',
      'other': 'Megerősítés',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'mégse';

  @override
  String get snackbar_undoText => 'VISSZA';

  @override
  String get snackbar_dismissText => 'ELVETÉS';

  @override
  String get contributors_tile_title => 'Közreműködők';

  @override
  String get userAction_tap => 'Koppintás';

  @override
  String get userAction_doubleTap => 'Dupla koppintás';

  @override
  String get userAction_longTap => 'Hosszú nyomás';

  @override
  String get channelName_habitReminder => 'Szokás emlékeztető';

  @override
  String get channelName_appReminder => 'Értesítés';

  @override
  String get channelName_appDebugger => 'Debugger';

  @override
  String get channelName_appSyncing => 'Szinkron folyamat';

  @override
  String get channelDesc_appSyncing =>
      'A szinkron állapotának és nem sikertelen eredmények megjelenítésére szolgál';

  @override
  String get channelName_appSyncFailed => 'Szinkron sikertelen';

  @override
  String get channelDesc_appSyncFailed => 'Értesítés szinkronhiba esetén';
}
