import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Speichern';

  @override
  String get habitEdit_habitName_hintText => 'Gewohnheit ...';

  @override
  String get habitEdit_colorPicker_title => 'Farbe wählen';

  @override
  String get habitEdit_habitTypeDialog_title => 'Gewohnheitstyp';

  @override
  String get habitEdit_habitType_positiveText => 'Positiv';

  @override
  String get habitEdit_habitType_negativeText => 'Negativ';

  @override
  String habitEdit_habitDailyGoal_hintText(Object number) {
    return 'Tägliches Ziel, Standard $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Minimaler täglicher Schwellwert, Standard $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Tägliches Ziel muss größer als $number sein.';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Tägliches Ziel darf maximal $number oder kleiner sein.';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Tägliches Ziel muss mindestens $number oder größer sein.';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'Tägliches Ziel darf maximal $number oder kleiner sein.';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Zieleinheit';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Gefordertes maximales Ziel';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Ungültiger Wert, muss mindestens $dailyGoal oder größer sein.';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Maximales tägliches Limit';

  @override
  String get habitEdit_frequencySelector_title => 'Häufigkeit auswählen';

  @override
  String get habitEdit_habitFreq_daily => 'Täglich';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'mal pro Woche';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'mal pro Monat';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'mal in';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'Tagen';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Täglich';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Mindestens ${freq}mal pro Woche',
      one: 'Pro Woche',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Mindestens ${freq}mal pro Monat',
      one: 'Pro Monat',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Mindestens ${freq}mal pro $days Tage',
      one: 'Jede $days Tage',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays Tage';
  }

  @override
  String get habitEidt_targetDays_dialogTitle => 'Zieltage auswählen';

  @override
  String get habitEdit_targetDays => 'Tage';

  @override
  String get habitEdit_reminder_hintText => 'Reminder';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Jeden Tag der Woche';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' in jeder Woche';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Jeder Tag des Monats';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' jeden Monat';

  @override
  String get habitEdit_reminderQuest_hintText => 'Frage, z. B. “Hast du heute schon trainiert?”';

  @override
  String get habitEdit_reminder_dialogTitle => 'Erinnerungstypen auswählen';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Wann überprüft werden muss';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Täglich';

  @override
  String get habitEdit_reminder_dialogType_week => 'Pro Woche';

  @override
  String get habitEdit_reminder_dialogType_month => 'Pro Monat';

  @override
  String get habitEdit_reminder_dialogConfirm => 'Hinzufügen';

  @override
  String get habitEdit_reminder_dialogCancel => 'Abbrechen';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Bestätigen';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Möchtest du diese Erinnerung wirklich entfernen?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'Entfernen';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'Behalten';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Mo';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Di';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Mi';

  @override
  String get habitEdit_reminder_weekdayText_tursday => 'Do';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Fr';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sa';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'So';

  @override
  String get habitEdit_desc_hintText => 'Memo, unterstützt Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Erstellt: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Modifiziert: ';

  @override
  String get habitDisplay_fab_text => 'Neue Gewohnheit';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Eine tausend-kilometer Reise beginnt mit einem einzigen Schritt';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Ausgewählte Gewohnheiten archivieren?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'Archivieren';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'Abbrechen';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count Gewohnheiten archiviert';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Ausgewählte Gewohnheiten entarchivieren?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'Bestätigen';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'Abbrechen';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count Gewohnheiten dearchiviert';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Ausgewählte Gewohnheiten löschen?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'Löschen';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'Abbrechen';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count Gewohnheiten gelöscht';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Alle Auswählen';

  @override
  String get habitDisplay_editPopMenu_export => 'Exportieren';

  @override
  String get habitDisplay_editPopMenu_delete => 'Löschen';

  @override
  String get habitDisplay_editPopMenu_clone => 'Vorlage';

  @override
  String get habitDisplay_editButton_tooltip => 'Bearbeiten';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archivieren';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Dearchivieren';

  @override
  String get habitDisplay_settingButton_tooltip => 'Einstellungen';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Aktuell';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Abgeschlossen';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'In Bearbeitung';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archiviert';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Beste Gewohnheiten: Änderungen der letzten 30 TAge';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Helles Thema';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Dunkles Thema';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Systemthema';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Archivierte anzeigen';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Abgeschlossene anzeigen';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Aktive anzeigen';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Einstellungen';

  @override
  String get habitDisplay_sort_reverseText => 'Umgekehrt';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Desc)';

  @override
  String get habitDisplay_sortType_manual => 'Meine Reihenfolge';

  @override
  String get habitDisplay_sortType_name => 'Nach Name';

  @override
  String get habitDisplay_sortType_colorType => 'Nach Farbe';

  @override
  String get habitDisplay_sortType_progress => 'Nach Rate';

  @override
  String get habitDisplay_sortType_startT => 'Nach Start-Datum';

  @override
  String get habitDisplay_sortType_status => 'Nach Status';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sortieren';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'Bestätigen';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'Abbrechen';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Debug';

  @override
  String get habitDetail_editButton_tooltip => 'Bearbeiten';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Dearchivieren';

  @override
  String get habitDetail_editPopMenu_archive => 'Archivieren';

  @override
  String get habitDetail_editPopMenu_export => 'Exportieren';

  @override
  String get habitDetail_editPopMenu_delete => 'Löschen';

  @override
  String get habitDetail_editPopMenu_clone => 'Vorlage';

  @override
  String get habitDetail_confirmDialog_confirm => 'Bestätigen';

  @override
  String get habitDetail_confirmDialog_cancel => 'Abbrechen';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Gewohnheit archivieren?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Gewohnheit entarchivieren?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Gewohnheit löschen?';

  @override
  String get habitDetail_summary_title => 'Zusammenfassung';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Deine aktuelle Note ist $score, und du hast vor $days Tage angefangen.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Beginnt in $days Tagen.',
      one: 'Beginnt morgen.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'UNTERSTANDARD',
      one: 'UNVOLLSTÄNDIG',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'EINWANDFREI',
      one: 'ÜBERERFÜLLT',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Ziel',
      two: 'Schwellenwert',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Einheit: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Tage',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'T';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Aufzeichnungen';

  @override
  String get habitDetail_scoreChart_title => 'Punkte';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Tag';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Woche';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Monat';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Jahr';

  @override
  String get habitDetail_freqChart_freqTitle => 'Häufigkeit';

  @override
  String get habitDetail_freqChart_historyTitle => 'Verlauf';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Häufigkeit & Verlauf';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Woche';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Monat';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Jahr';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Jetzt';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Verlaufsdiagramm verstecken';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Verlaufsdiagramm zeigen';

  @override
  String get habitDetail_descSubgroup_title => 'Memo';

  @override
  String get habitDetail_otherSubgroup_title => 'Andere';

  @override
  String get habitDetail_habitType_title => 'Typ';

  @override
  String get habitDetail_reminderTile_title => 'Erinnerung';

  @override
  String get habitDetail_freqTile_title => 'Wiederholen';

  @override
  String get habitDetail_startDateTile_title => 'Start-Datum';

  @override
  String get habitDetail_createDateTile_title => 'Erstellt';

  @override
  String get habitDetail_modifyDateTile_title => 'Modifiziert';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'Datum';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'Wert';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'Zurück nach heute';

  @override
  String get habitDetail_notFoundText => 'Laden der Gewohnheit fehlgeschlagen';

  @override
  String get habitDetail_notFoundRetryText => 'Noch einmal Versuchen';

  @override
  String get habitDetail_changeGoal_title => 'Ziel ändern';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'Aktuell: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'Abgeschlossen: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'Nicht fertiggestellt';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Tägliches Ziel, Standard: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'Abbrechen';

  @override
  String get habitDetail_changeGoal_saveText => 'Speichern';

  @override
  String get habitDetail_skipReason_title => 'Überspingungsgrund';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Schreibe hier etwas...';

  @override
  String get habitDetail_skipReason_cancelText => 'Abbrechen';

  @override
  String get habitDetail_skipReason_saveText => 'Speichern';

  @override
  String get appSetting_appbar_titleText => 'Einstellungen';

  @override
  String get appSetting_displaySubgroupText => 'Anzeige';

  @override
  String get appSetting_operationSubgroupText => 'Bedienen';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Kalender nach Seite ziehen';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Wenn der Schalter aktiviert ist, wird der Balkenkalender der App auf der Startseite Seite für Seiten gezogen. Standardmäßig ist diese Funktion deaktiviert.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Status ändern';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Modify the click behavior to change the status of daily records on main page.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Detaillierte Aufzeichnung öffnen';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Modify the click behavior to open the detailed popup for daily records on main page.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Erster Tag der Woche';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Ersten Tag der Woche auswählen';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Standard)';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Datumsformat ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'Systemeinstellungen folgen';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Eingestelltes Datumformat wird auf die Daten der Gewohnheitsseiten angewand.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Kompate Benutzeroberfläche auf Gewohnheitsseiten';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Es können mehr Informationen angezeigt werden, allerdings sind einige Textelemente kleiner dargestellt.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Gewohnheitschecklisten Bereich';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Zeige mehr oder weniger von der Checkliste auf der Startseite.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Standard';

  @override
  String get appSetting_reminderSubgroupText => 'Erinnerung';

  @override
  String get appSetting_dailyReminder_titleText => 'tägliche Erinnerung';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Sichern & Wiederherstellen';

  @override
  String get appSetting_export_titleText => 'Exportieren';

  @override
  String get appSetting_export_subtitleText => 'Gewohnheiten als JSON Datei exportieren. Diese kann zum wiederherstellen genutzt werden.';

  @override
  String get appSetting_import_titleText => 'Importieren';

  @override
  String get appSetting_import_subtitleText => 'Gewohnheits JSON Date impotieren.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Wirklich $count Gewohnheiten importieren?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Hinweis: Der Import löscht keine existierende Gewohnheiten.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'Bestätigen';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'Abbrechen';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Importiert: $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Import abgeschlossen: $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'Schließen';

  @override
  String get appSetting_resetConfig_titleText => 'Einstellungen zurücksetzen';

  @override
  String get appSetting_resetConfig_subtitleText => 'Alle Einstellungen zurücksetzen.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Einstellungen zurücksetzen?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Alle Einstellungen werden zurückgesetzt. Die Anwendung muss neu gestartet werden, um die Änderungen anzuwenden.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'Abbrechen';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'Bestätigen';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'Zurücksetzen erfolgreich';

  @override
  String get appSetting_otherSubgroupText => 'Andere';

  @override
  String get appSetting_developMode_titleText => 'Entwicklermodus';

  @override
  String get appSetting_clearCache_titleText => 'Cache leeren';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Cache leeren';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Nachdem der Cache geleert wurde, werden einige Wert wieder auf ihren Standard gestellt sein.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'Abbrechen';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'Bestätigen';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Partielles Leeren des Cache fehlgeschlagen';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Cache erfolgreich geleert';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Cache konnte nicht geleert werden';

  @override
  String get appSetting_about_titleText => 'Über';

  @override
  String get appAbout_appbarTile_titleText => 'Über';

  @override
  String appAbout_verionTile_titleText(String appVersion) {
    return 'Version: $appVersion';
  }

  @override
  String get appAbout_verionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Quellcode';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Fehlerverfolgung';

  @override
  String get appAbout_contactEmailTile_titleText => 'Kontaktiere mich';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Lizens';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Third Party Licensing Statement';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Spenden';

  @override
  String get appAbout_donateTile_subTitleText => 'Ich entwickle diese App als Hobby. Bitte kaufe mir doch einen ☕.';

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
    return '${name}s Adresse kopiert';
  }

  @override
  String get appReminder_dailyReminder_title => '🏝 Bist du heute bei deinen Gewohnheiten geblieben?';

  @override
  String get appReminder_dailyReminder_body => 'click to enter app and punch in on time.';

  @override
  String get common_habitColorType_cc1 => 'Flieder';

  @override
  String get common_habitColorType_cc2 => 'Rot';

  @override
  String get common_habitColorType_cc3 => 'Violett';

  @override
  String get common_habitColorType_cc4 => 'Königsblau';

  @override
  String get common_habitColorType_cc5 => 'Dunkles Türkis';

  @override
  String get common_habitColorType_cc6 => 'Grün';

  @override
  String get common_habitColorType_cc7 => 'Bernstein';

  @override
  String get common_habitColorType_cc8 => 'Orange';

  @override
  String get common_habitColorType_cc9 => 'Limette';

  @override
  String get common_habitColorType_cc10 => 'Dunkle Orchidee';

  @override
  String common_habitColorType_default(int index) {
    return 'Farbe $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Systemeinstellungen nutzen';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Datumsformat';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Jahr Monat Tag';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Monat Tag Jahr';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Tag Monat Jahr';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Trennzeichen';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Strich';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Schrägstrich';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Leerzeichen';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Punkt';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'kein Trennzeichen';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Nutze 12-Stunden Format';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Nutze vollen Namen';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Auf Häufigkeitsdiagramm anwenden';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Auf Kalender anwenden';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'Abbrechen';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'Bestätigen';

  @override
  String get calendarPicker_clip_today => 'Heute';

  @override
  String get calendarPicker_clip_tomorrow => 'Morgen';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Nächstes $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Alle Gewohnheiten exportieren?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number Gewohnheiten',
      one: 'eine Gewohnheit',
      zero: 'aktuelle Gewohnheit',
    );
    return 'Exportiere $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'Verlauf einschließen?';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'Abbrechen';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'Exportieren';

  @override
  String get snackbar_undoText => 'Rückgängig';

  @override
  String get snackbar_dissmessText => 'Ablehnen';

  @override
  String get userAction_tap => 'Tippen';

  @override
  String get userAction_doubleTap => 'Doppel';

  @override
  String get userAction_longTap => 'Lang';
}
