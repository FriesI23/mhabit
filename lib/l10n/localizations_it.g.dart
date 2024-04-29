import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Italian (`it`).
class L10nIt extends L10n {
  L10nIt([String locale = 'it']) : super(locale);

  @override
  String get localeScriptName => 'Italiano';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Salva';

  @override
  String get habitEdit_habitName_hintText => 'Nome Abitudine ...';

  @override
  String get habitEdit_colorPicker_title => 'Scegli colore';

  @override
  String get habitEdit_habitTypeDialog_title => 'Tipologia abitudine';

  @override
  String get habitEdit_habitType_positiveText => 'Positiva';

  @override
  String get habitEdit_habitType_negativeText => 'Negativa';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Obiettivo giornaliero, predefinito $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Soglia minima giornaliera, predefinito $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Obiettivo giornaliero > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Obiettivo giornaliero ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Obiettivo giornaliero ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'Obiettivo giornaliero ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Unità obiettivo giornaliero';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Obiettivo giornaliero massimo desiderato';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Valore non valido, deve essere vuoto o ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Limite massimo giornaliero';

  @override
  String get habitEdit_frequencySelector_title => 'Seleziona frequenza';

  @override
  String get habitEdit_habitFreq_daily => 'Ogni giorno';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'volte a settimana';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'volte al mese';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'volte in';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'giorni';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Ogni Giorno';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Almeno $freq volte a settimana',
      one: 'A settimana',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Almeno $freq volte al mese',
      one: 'Al mese',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Almeno $freq volte ogni $days giorni',
      one: 'Ogni $days giorni',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays giorni';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Seleziona giorni target';

  @override
  String get habitEdit_targetDays => 'giorni';

  @override
  String get habitEdit_reminder_hintText => 'Promemoria';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Qualsiasi giorno della settimana';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => 'Ogni Giorno';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' a settimana';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Qualsiasi giorno del mese';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => 'Mensile';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' al mese';

  @override
  String get habitEdit_reminderQuest_hintText => 'Domanda, ad es. \"Ti sei allenato oggi?\"';

  @override
  String get habitEdit_reminder_dialogTitle => 'Scegli tipologia di promemoria';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Quando è il momento di fare il check-in';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Quotidianamente';

  @override
  String get habitEdit_reminder_dialogType_week => 'Settimanalmente';

  @override
  String get habitEdit_reminder_dialogType_month => 'Mensilmente';

  @override
  String get habitEdit_reminder_dialogConfirm => 'Conferma';

  @override
  String get habitEdit_reminder_dialogCancel => 'Annulla';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Conferma';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Sei sicuro di voler eliminare questo promemoria?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'Conferma';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'Annulla';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Lun';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Mar';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Mer';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Gio';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Ven';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sab';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Dom';

  @override
  String get habitEdit_desc_hintText => 'Note, supportano Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Creato il: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Modificato il: ';

  @override
  String get habitDisplay_fab_text => 'Nuova Abitudine';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Un viaggio di mille chilometri inizia con un solo passo';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Archivia le Abitudini Selezionate?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'Conferma';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'Annulla';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count abitudini archiviate';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Rimuovere dall\'archivio le abitudini selezionate?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'Conferma';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'Annulla';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count abitudini non archiviate';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Eliminare le abitudini selezionate?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'Conferma';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'Annulla';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count abitudini eliminate';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Seleziona tutto';

  @override
  String get habitDisplay_editPopMenu_export => 'Esporta';

  @override
  String get habitDisplay_editPopMenu_delete => 'Elimina';

  @override
  String get habitDisplay_editPopMenu_clone => 'Template';

  @override
  String get habitDisplay_editButton_tooltip => 'Modifica';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archivia';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Rimuovi dall\'archivio';

  @override
  String get habitDisplay_settingButton_tooltip => 'Impostazioni';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Attuale';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Completate';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'In Svolgimento';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archiviate';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Abitudini Principali: i cambiamenti degli ultimi 30 giorni';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Tema chiaro';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Tema scuro';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Segui sistema';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Visualizza archiviate';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Visualizza completate';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Mostra attive';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Impostazioni';

  @override
  String get habitDisplay_sort_reverseText => 'Inverti';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Disc)';

  @override
  String get habitDisplay_sortType_manual => 'Personale';

  @override
  String get habitDisplay_sortType_name => 'Per Nome';

  @override
  String get habitDisplay_sortType_colorType => 'Per Colore';

  @override
  String get habitDisplay_sortType_progress => 'Per Rateo';

  @override
  String get habitDisplay_sortType_startT => 'Per data di inizio';

  @override
  String get habitDisplay_sortType_status => 'Per stato';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Ordina';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'Conferma';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'Annulla';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Debug';

  @override
  String get habitDetail_editButton_tooltip => 'Modifica';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Rimuovi dall\'archivio';

  @override
  String get habitDetail_editPopMenu_archive => 'Archivia';

  @override
  String get habitDetail_editPopMenu_export => 'Esporta';

  @override
  String get habitDetail_editPopMenu_delete => 'Elimina';

  @override
  String get habitDetail_editPopMenu_clone => 'Template';

  @override
  String get habitDetail_confirmDialog_confirm => 'Conferma';

  @override
  String get habitDetail_confirmDialog_cancel => 'Annulla';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Archiviare l\'Abitudine?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Rimuovere dall\'archivio l\'Abitudine?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Eliminare l\'abitudine?';

  @override
  String get habitDetail_summary_title => 'Riepilogo';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Il punteggio attuale è $score, e sono passati $days giorni dall\'inizio.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tra $days giorni.',
      one: 'A partire da domani.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'INSUFFICIENTE',
      one: 'INCOMPLETO',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'IMPECCABILE',
      one: 'OVERFULFIL',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Obiettivo',
      two: 'Soglia',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Unità: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'vuoto';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Giorni',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'g';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Voci';

  @override
  String get habitDetail_scoreChart_title => 'Punteggio';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Giorno';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Settimana';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Mese';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Anno';

  @override
  String get habitDetail_freqChart_freqTitle => 'Frequenza';

  @override
  String get habitDetail_freqChart_historyTitle => 'Cronologia';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Frequenza & Cronologia';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Settimana';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Mese';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Anno';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Adesso';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Nascondi Grafico Cronologia';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Mostra Grafico Cronologia';

  @override
  String get habitDetail_descSubgroup_title => 'Note';

  @override
  String get habitDetail_otherSubgroup_title => 'Altro';

  @override
  String get habitDetail_habitType_title => 'Tipologia';

  @override
  String get habitDetail_reminderTile_title => 'Promemoria';

  @override
  String get habitDetail_freqTile_title => 'Ripeti';

  @override
  String get habitDetail_startDateTile_title => 'Data d\'inizio';

  @override
  String get habitDetail_createDateTile_title => 'Creato';

  @override
  String get habitDetail_modifyDateTile_title => 'Modificato';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'data';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'valore';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'torna ad oggi';

  @override
  String get habitDetail_notFoundText => 'Caricamento abitudini fallito';

  @override
  String get habitDetail_notFoundRetryText => 'Prova ancora';

  @override
  String get habitDetail_changeGoal_title => 'Cambia obiettivo';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'Attuale: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'fatto: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'Annullato';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Obiettivo giornaliero, predefinito:$goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'Annulla';

  @override
  String get habitDetail_changeGoal_saveText => 'salva';

  @override
  String get habitDetail_skipReason_title => 'Salta motivazione';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Scrivi qualcosa qui...';

  @override
  String get habitDetail_skipReason_cancelText => 'Annulla';

  @override
  String get habitDetail_skipReason_saveText => 'salva';

  @override
  String get appSetting_appbar_titleText => 'Impostazioni';

  @override
  String get appSetting_displaySubgroupText => 'Mostra';

  @override
  String get appSetting_operationSubgroupText => 'Operazione';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Scorri calendario per pagina';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Se attivo, il calendario della barra delle applicazioni nella pagina iniziale verrà trascinato pagina per pagina. Per impostazione predefinita, è disattivato.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Cambia Stato delle Voci';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Modifica il comportamento del tocco per cambiare lo stato dei record giornalieri sulla pagina principale.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Mostra Rapporto Dettagliato';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Modifica il comportamento del tocco per aprire il popup dettagliato dei record giornalieri nella pagina principale.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Primo giorno della settimana';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Mostra il primo giorno della settimana';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Predefinito)';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Formato visualizzazione data ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'segui le impostazioni di sistema';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Il formato impostato sarà applicato alla data visualizzata sulla pagina dei dettagli dell\'abitudine.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Abilita interfaccia compatta nella pagina delle abitudini';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Permetti alla tabella di conferma delle abitudini di visualizzare più contenuto, ma il testo e alcuni elementi dell\'interfaccia potrebbero diventare più piccoli.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Modifica dell\'area di conferma dell\'abitudine';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Regola per avere più o meno spazio nell\'area di conferma delle abitudini.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Predefinito';

  @override
  String get appSetting_reminderSubgroupText => 'Promemoria';

  @override
  String get appSetting_dailyReminder_titleText => 'Promemoria giornaliero';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Backup & Ripristino';

  @override
  String get appSetting_export_titleText => 'Esporta';

  @override
  String get appSetting_export_subtitleText => 'Esporta le abitudini in formato JSON, questo file può essere poi importato.';

  @override
  String get appSetting_import_titleText => 'Importa';

  @override
  String get appSetting_import_subtitleText => 'Importa le abitudini da un file JSON.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Confermi l\'importazione di $count abitudini?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Nota: l\'importazione non elimina le abitudini esistenti.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'Conferma';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'Annulla';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return '$completeCount/$totalCount importati';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Importazione completata $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'chiudi';

  @override
  String get appSetting_resetConfig_titleText => 'Ripristina impostazioni';

  @override
  String get appSetting_resetConfig_subtitleText => 'Ripristina tutte le impostazioni.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Ripristina le impostazioni?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Ripristina tutte le impostazioni, serve un riavvio dell\'app per applicare.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'Annulla';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'Conferma';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'ripristino impostazioni app riuscito';

  @override
  String get appSetting_otherSubgroupText => 'Altri';

  @override
  String get appSetting_developMode_titleText => 'Modalità Sviluppatore';

  @override
  String get appSetting_clearCache_titleText => 'Svuota Cache';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Svuota Cache';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Dopo aver svuotato la cache, alcuni valori saranno ripristinati a quelli predefiniti.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'Annulla';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'Conferma';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Eliminazione parziale Cache fallita';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Cache eliminata correttamente';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Eliminazione Cache fallita';

  @override
  String get appSetting_about_titleText => 'Riguardo a';

  @override
  String get appAbout_appbarTile_titleText => 'Riguardo a';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Versione: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Codice sorgente';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Issue tracker';

  @override
  String get appAbout_contactEmailTile_titleText => 'Contattami';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Ciao, sono lieto che tu mi abbia contattato.\nSe stai segnalando un bug, indica la versione dell\'app e descrivi i passaggi per riprodurlo.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licenza';

  @override
  String get appAbout_licenseTile_subtitleText => 'Licenza Apache, Versione 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Dichiarazione Licenza Di Terze Parti';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Dona';

  @override
  String get appAbout_donateTile_subTitleText => 'Sono uno sviluppatore personale. Se ti piace quest\'app, comprami un ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Comprami un caffè';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Criptovalute';

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
    return 'Indirizzo di $name copiato';
  }

  @override
  String get batchCheckin_appbar_title => 'Check-In di gruppo';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Giorno precedente';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Prossimo giorno';

  @override
  String get batchCheckin_status_skip_text => 'Salta';

  @override
  String get batchCheckin_status_ok_text => 'Completo';

  @override
  String get batchCheckin_status_double_text => 'x2 Hit!';

  @override
  String get batchCheckin_status_zero_text => 'Incompleto';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Abitudini',
      one: 'Abitudine',
    );
    return '$count $_temp0 selezionate';
  }

  @override
  String get batchCheckin_save_button_text => 'Salva';

  @override
  String get batchCheckin_reset_button_text => 'Ripristina';

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
  String get batchCheckin_save_confirmDialog_title => 'Sovrascrivi Voci Esistenti';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Le voci esistenti saranno sovrascritte. Dopo il salvataggio, le voci precedenti andranno perse.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'salva';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'Annulla';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Conferma di Tornare Indietro';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Le modifiche allo stato del Check-In non saranno applicate prima di aver salavto';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'esci';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'Annulla';

  @override
  String get appReminder_dailyReminder_title => '🏝 Hai mantenuto le tue abitudini oggi?';

  @override
  String get appReminder_dailyReminder_body => 'tocca per entrare nell\'app ed effettuare il check-in in tempo.';

  @override
  String get common_habitColorType_cc1 => 'Lilla intenso';

  @override
  String get common_habitColorType_cc2 => 'Rosso';

  @override
  String get common_habitColorType_cc3 => 'Viola';

  @override
  String get common_habitColorType_cc4 => 'Blu Reale';

  @override
  String get common_habitColorType_cc5 => 'Ciano scuro';

  @override
  String get common_habitColorType_cc6 => 'Verde';

  @override
  String get common_habitColorType_cc7 => 'Ambra';

  @override
  String get common_habitColorType_cc8 => 'Arancio';

  @override
  String get common_habitColorType_cc9 => 'Verde lime';

  @override
  String get common_habitColorType_cc10 => 'Orchidea scura';

  @override
  String common_habitColorType_default(int index) {
    return 'Colore $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Usa formato di sistema';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Formato data';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Anno Mese Giorno';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Mese Giorno Anno';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Giorno Mese Anno';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separatore';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Trattino';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Slash';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Spazio';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Punto';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Nessun separatore';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Usa il formato 12 ore';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Usa nome completo';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Applica per il Grafico della Frequenza';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Applica per il Calendario';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'Annulla';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'Conferma';

  @override
  String get calendarPicker_clip_today => 'Oggi';

  @override
  String get calendarPicker_clip_tomorrow => 'Domani';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Prossimo $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Esportare tutte le abitudini?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number abitudini',
      one: '1 abitudine',
      zero: 'l\'abitudine corrente',
    );
    return 'Esporta $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'includi voci';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'Annulla';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'esporta';

  @override
  String get snackbar_undoText => 'ANNULLA';

  @override
  String get snackbar_dismissText => 'IGNORA';

  @override
  String get contributors_tile_title => 'Contributori';

  @override
  String get userAction_tap => 'Tocco';

  @override
  String get userAction_doubleTap => 'Doppio';

  @override
  String get userAction_longTap => 'Lungo';
}
