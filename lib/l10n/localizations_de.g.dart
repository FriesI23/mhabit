// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get localeScriptName => 'Deutsch';

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
  String habitEdit_habitDailyGoal_hintText(num number) {
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
  String get habitEdit_targetDays_dialogTitle => 'Zieltage auswählen';

  @override
  String get habitEdit_targetDays => 'Tage';

  @override
  String get habitEdit_reminder_hintText => 'Erinnerung';

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
  String get habitEdit_reminder_weekdayText_thursday => 'Do';

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
  String get habitDisplay_exportAllHabitsSuccSnackbarText => 'Exported All Habits';

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
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Beste Gewohnheiten: Änderungen der letzten 30 Tage';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Helles Thema';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Dunkles Thema';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'System';

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
  String get habitDisplay_searchBar_hintText => 'Search habits';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Ongoing';

  @override
  String get habitDisplay_searchFilter_ongoing_desc => 'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'Abgeschlossen';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Gewohnheitstyp';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Show Filters';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clear Filters';

  @override
  String get habitToday_appBar_title => 'Heute';

  @override
  String get habitToday_image_desc => 'YOU MADE IT';

  @override
  String get habitToday_card_donePlusButton_label => 'Done+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Skip+';

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
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Der Kalender des Gewohnheitsverlaufs auf der Startseite kann Seite für Seiten gezogen werden. Standardmäßig ist diese Funktion deaktiviert.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Status ändern';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Einstellung zur Anpassung des Tipp-Verhaltens, um eine Gewohnheit für ein Datum als abgeschlossen zu markieren.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Detaillierte Aufzeichnung öffnen';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Einstellung zur Anpassung des Tipp-Verhaltens, um das Pop-Up zur Modifikation eines Datenpunktes einer Gewohnheit zu öffnen.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Erster Tag der Woche';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Ersten Tag der Woche auswählen';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Standard)';

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
    return 'Datumsformat ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'Systemeinstellungen folgen';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Das ausgewählte Datumsformat wird auf die Zeitstempel der Gewohnheitsseiten angewand.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Kompakte Benutzeroberfläche auf Gewohnheitsseiten';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Es werden mehr Informationen angezeigt werden, allerdings sind einige Textelemente kleiner dargestellt.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Bereich der Gewohnheitslist';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Zeige mehrere oder wenigere Gewohnheiten auf der Startseite.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Standard';

  @override
  String get appSetting_reminderSubgroupText => 'Erinnerung';

  @override
  String get appSetting_dailyReminder_titleText => 'Tägliche Erinnerung';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Sichern & Wiederherstellen';

  @override
  String get appSetting_export_titleText => 'Exportieren';

  @override
  String get appSetting_export_subtitleText => 'Gewohnheiten als JSON Datei exportieren. Diese kann zum wiederherstellen genutzt werden.';

  @override
  String get appSetting_import_titleText => 'Importieren';

  @override
  String get appSetting_import_subtitleText => 'Gewohnheits JSON Datei impotieren.';

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
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'Über diese App';

  @override
  String get appSetting_experimentalFeatureTile_titleText => 'Experimental Features';

  @override
  String get appSetting_synSubgroupText => 'Sync';

  @override
  String get appSetting_syncOption_titleText => 'Sync Options';

  @override
  String get appSetting_notify_titleTile => 'Notifications';

  @override
  String get appSetting_notify_subtitleTile => 'Manage notification preferences';

  @override
  String get appSetting_notify_subtitleTile_android => 'Tap to open system notification settings';

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
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'manual': 'Manual',
        'minute5': '5 Minutes',
        'minute15': '15 Minutes',
        'minute30': '30 Minutes',
        'hour1': '1 Hour',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Fetch Interval';

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
  String get appSync_noti_readyToSync_body => 'Preparing to sync...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(
      synced,
      {
        'synced': 'Synced ($type)',
        'failed': 'Sync Failed ($type)',
        'other': 'Syncing ($type)',
      },
    );
    return '$_temp0';
  }

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
  String get experimentalFeatures_habitSearchTile_titleText => 'Habit Search';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText => 'Once enabled, a search bar will appear at the top of the Habits screen and allowing to search habits.';

  @override
  String get appAbout_appbarTile_titleText => 'Über diese App';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Version: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Quellcode';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Fehlerverfolgung';

  @override
  String get appAbout_contactEmailTile_titleText => 'Kontaktiere den Author';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Lizens';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Drittanbierterlizensen';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'Flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Privacy';

  @override
  String get appAbout_privacyTile_subTitleText => 'Access the privacy policy in this app';

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
  String get donateWay_cryptoCurrency => 'Crypto Currencies';

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
  String get batchCheckin_appbar_title => 'Stapel-Check-in';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Vorheriger Tag';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Nächster Tag';

  @override
  String get batchCheckin_status_skip_text => 'Überspringen';

  @override
  String get batchCheckin_status_ok_text => 'Abgeschlossen';

  @override
  String get batchCheckin_status_double_text => 'Doppelter Erfolg!';

  @override
  String get batchCheckin_status_zero_text => 'Unvollständig';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gewohnheiten',
      one: 'Gewohnheit',
    );
    return '$_temp0 ausgewählt';
  }

  @override
  String get batchCheckin_save_button_text => 'Speichern';

  @override
  String get batchCheckin_reset_button_text => 'Zurücksetzen';

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
  String get batchCheckin_save_confirmDialog_title => 'Bestehende Einträge überschreiben';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Bestehende Einträge werden überschrieben. Nach dem Speichern gehen frühere Einträge verloren.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'Speichern';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'Abbrechen';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Rückkehr bestätigen';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Änderungen am Eincheckstatus werden erst nach dem Speichern angewendet.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'Beenden';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'Abbrechen';

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
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

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
  String get snackbar_undoText => 'Rückgängig';

  @override
  String get snackbar_dismissText => 'Ablehnen';

  @override
  String get contributors_tile_title => 'Mitwirkende';

  @override
  String get userAction_tap => 'Tippen';

  @override
  String get userAction_doubleTap => 'Doppel';

  @override
  String get userAction_longTap => 'Lang';

  @override
  String get channelName_habitReminder => 'Habit Reminder';

  @override
  String get channelName_appReminder => 'Prompt';

  @override
  String get channelName_appDebugger => 'Debugger';

  @override
  String get channelName_appSyncing => 'Sync Process';

  @override
  String get channelDesc_appSyncing => 'Used to show sync progress and non-failure results';

  @override
  String get channelName_appSyncFailed => 'Sync Failed';

  @override
  String get channelDesc_appSyncFailed => 'Used to alert when sync fails';
}
