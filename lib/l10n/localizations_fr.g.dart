import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get localeScriptName => 'Français';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Sauvegarder';

  @override
  String get habitEdit_habitName_hintText => 'Nom de l’habitude…';

  @override
  String get habitEdit_colorPicker_title => 'Choisir une couleur';

  @override
  String get habitEdit_habitTypeDialog_title => 'Type d’habitude';

  @override
  String get habitEdit_habitType_positiveText => 'Positive';

  @override
  String get habitEdit_habitType_negativeText => 'Négative';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Objectif journalier, par défaut à $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Seuil minimum journalier, par défaut à $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'L’objectif journalier doit être > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'L’objectif journalier doit être ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'L’objectif journalier doit être ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'L’objectif journalier doit être ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Unité de l’objectif journalier';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Objectif journalier maximum souhaité';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Valeur invalide. Ce doit être vide ou ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Limite journalière maximale';

  @override
  String get habitEdit_frequencySelector_title => 'Sélectionner une fréquence';

  @override
  String get habitEdit_habitFreq_daily => 'Journalier';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'fois par semaine';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'fois par mois';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'fois en';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'jours';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Journalier';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Au moins $freq fois par semaine',
      one: 'Hebdomadaire',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Au moins $freq fois par mois',
      one: 'Mensuel',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Au moins $freq fois tous les $days jours',
      one: 'Tous les $days jours',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays jours';
  }

  @override
  String get habitEidt_targetDays_dialogTitle => 'Sélectionner le nombre de jours ciblé';

  @override
  String get habitEdit_targetDays => 'jours';

  @override
  String get habitEdit_reminder_hintText => 'Rappel';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Tous les jours de la semaine';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' de chaque semaine';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Tous les jours du mois';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' de chaque mois';

  @override
  String get habitEdit_reminderQuest_hintText => 'Question. Par exemple: avez-vous fait de l’exercice aujourd’hui ?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Choisir un type de rappel';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Lorsque c’est nécessaire';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Journalier';

  @override
  String get habitEdit_reminder_dialogType_week => 'Hebdomadaire';

  @override
  String get habitEdit_reminder_dialogType_month => 'Mensuel';

  @override
  String get habitEdit_reminder_dialogConfirm => 'Confirmer';

  @override
  String get habitEdit_reminder_dialogCancel => 'Annuler';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Confirmer';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Confirmez-vous la suppression de ce rappel ?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'Confirmer';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'Annuler';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Lun';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Mar';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Mer';

  @override
  String get habitEdit_reminder_weekdayText_tursday => 'Jeu';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Ven';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sam';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Dim';

  @override
  String get habitEdit_desc_hintText => 'Mémo, supporte la syntaxe Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Créée: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Modifiée: ';

  @override
  String get habitDisplay_fab_text => 'Nouvelle habitude';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Un voyage de mille lieux commence par un pas';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Archiver les habitudes sélectionnées ?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'Annuler';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count habitudes archivées';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Désarchiver les habitudes sélectionnées ?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'Annuler';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count habitudes désarchivées';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Supprimer les habitudes sélectionnées ?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'Annuler';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count habitudes supprimées';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Tout sélectionner';

  @override
  String get habitDisplay_editPopMenu_export => 'Exporter';

  @override
  String get habitDisplay_editPopMenu_delete => 'Supprimer';

  @override
  String get habitDisplay_editPopMenu_clone => 'Modèle';

  @override
  String get habitDisplay_editButton_tooltip => 'Éditer';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archiver';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Désarchiver';

  @override
  String get habitDisplay_settingButton_tooltip => 'Paramètre';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Courantes';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Complétées';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'En cours';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archivées';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Podium des habitudes: 30 derniers jours';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Thème clair';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Thème sombre';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Suivre le système';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Afficher les archivées';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Afficher les complétées';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Afficher les actives';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Paramètres';

  @override
  String get habitDisplay_sort_reverseText => 'Inversé';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Desc)';

  @override
  String get habitDisplay_sortType_manual => 'Ordre personnel';

  @override
  String get habitDisplay_sortType_name => 'Par nom';

  @override
  String get habitDisplay_sortType_colorType => 'Par couleur';

  @override
  String get habitDisplay_sortType_progress => 'Par score';

  @override
  String get habitDisplay_sortType_startT => 'Par date de début';

  @override
  String get habitDisplay_sortType_status => 'Par statut';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Tri';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'Annuler';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Débogage';

  @override
  String get habitDetail_editButton_tooltip => 'Éditer';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Désarchiver';

  @override
  String get habitDetail_editPopMenu_archive => 'Archiver';

  @override
  String get habitDetail_editPopMenu_export => 'Exporter';

  @override
  String get habitDetail_editPopMenu_delete => 'Supprimer';

  @override
  String get habitDetail_editPopMenu_clone => 'Modèle';

  @override
  String get habitDetail_confirmDialog_confirm => 'Confirmer';

  @override
  String get habitDetail_confirmDialog_cancel => 'Annuler';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Archiver l’habitude ?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Désarchiver l’habitude ?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Supprimer l’habitude ?';

  @override
  String get habitDetail_summary_title => 'Résumé';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Le score actuel est de $score, et cela fait $days jours depuis le début.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Démarre dans $days jours.',
      one: 'Démarre demain.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'INSUFFISANT',
      one: 'INACHEVÉE',
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
      one: 'DÉPASSÉ',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Objectif',
      two: 'Seuil',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Unité: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Jours',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'd';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Entrées';

  @override
  String get habitDetail_scoreChart_title => 'Score';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Jour';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Semaine';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Mois';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Année';

  @override
  String get habitDetail_freqChart_freqTitle => 'Fréquence';

  @override
  String get habitDetail_freqChart_historyTitle => 'Historique';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Fréquence et historique';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Semaine';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Mois';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Année';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Maintenant';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Masquer le graphe d’historique';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Afficher le graphe d’historique';

  @override
  String get habitDetail_descSubgroup_title => 'Mémo';

  @override
  String get habitDetail_otherSubgroup_title => 'Autre';

  @override
  String get habitDetail_habitType_title => 'Type';

  @override
  String get habitDetail_reminderTile_title => 'Rappel';

  @override
  String get habitDetail_freqTile_title => 'Répétition';

  @override
  String get habitDetail_startDateTile_title => 'Date de début';

  @override
  String get habitDetail_createDateTile_title => 'Créée';

  @override
  String get habitDetail_modifyDateTile_title => 'Modifiée';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'date';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'valeur';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'revenir à aujourd’hui';

  @override
  String get habitDetail_notFoundText => 'Échec du chargement de l’habitude';

  @override
  String get habitDetail_notFoundRetryText => 'Essayez une nouvelle fois';

  @override
  String get habitDetail_changeGoal_title => 'Modifier l’objectif';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'Courant: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'Fait: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'Non fait';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Objectif journalier, $goal par défaut';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'Annuler';

  @override
  String get habitDetail_changeGoal_saveText => 'Sauvegarder';

  @override
  String get habitDetail_skipReason_title => 'Raison pour avoir ignoré';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Écrivez quelque chose ici…';

  @override
  String get habitDetail_skipReason_cancelText => 'Annuler';

  @override
  String get habitDetail_skipReason_saveText => 'Sauvegarder';

  @override
  String get appSetting_appbar_titleText => 'Paramètres';

  @override
  String get appSetting_displaySubgroupText => 'Affichage';

  @override
  String get appSetting_operationSubgroupText => 'Opération';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Défilement du calendrier page par page';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Si ce bouton est activé, le calendrier présent sur la barre d’application de la page d’accueil défilera page par page. Par défaut, le bouton est désactivé.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Modifier le statut de l’entrée';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Modifier le type de clic permettant de changer le statut des entrées journalières sur la page principale.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Ouvrir le détail de l’entrée';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Modifier le type de clic permettant d’ouvrir la boîte de dialgue détaillée des entrées journalières sur la page principale.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Premier jour de la semaine';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Afficher le premier jour de la semaine';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (par défaut)';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Format de l’affichage des dates ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'suivre le paramétrage du système';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Le format configuré sera appliqué à l’affichage des dates sur le détail de l’habitude.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Activer l’interface compacte sur la page des habitudes';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Permet au tableau des habitudes d’afficher plus de contenu. Certains éléments et textes apparaitront plus petits.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Ajustement de la zone de validation des habitudes';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Ajuster le pourcentage pour avoir plus ou moins d’espace dans la zone de validation des habitudes.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Défaut';

  @override
  String get appSetting_reminderSubgroupText => 'Rappel';

  @override
  String get appSetting_dailyReminder_titleText => 'Rappel journalier';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Sauvegarder et restaurer';

  @override
  String get appSetting_export_titleText => 'Exporter';

  @override
  String get appSetting_export_subtitleText => 'Exporter les habitudes au format JSON. Ce fichier peut être importé.';

  @override
  String get appSetting_import_titleText => 'Importer';

  @override
  String get appSetting_import_subtitleText => 'Importer les habitudes à partir d’un fichier au format JSON.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Confirmer l’import de $count habitudes ?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Note: l’import ne supprime pas les habitudes existantes.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'Confirmer';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'Annuler';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return '$completeCount/$totalCount importées';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Import complet $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'Fermer';

  @override
  String get appSetting_resetConfig_titleText => 'Réinitialiser la configuration';

  @override
  String get appSetting_resetConfig_subtitleText => 'Réinitialiser la configuration aux valeurs par défaut.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Réinitialiser la configuration ?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'La configuration sera réinitialisée aux valeurs par défaut. Vous devrez redémarrer l’application pour que ce soit appliqué.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'Annuler';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'Confirmer';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'Réinitialisation de la configuration réussie';

  @override
  String get appSetting_otherSubgroupText => 'Autre';

  @override
  String get appSetting_developMode_titleText => 'Mode développement';

  @override
  String get appSetting_clearCache_titleText => 'Vider le cache';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Vider le cache';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Après avoir vidé le cache, certaines valeurs personnelles seront réinitialisées aux valeurs par défaut.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'Annuler';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'Confirmer';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Échec du vidage partiel du cache';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Cache vidé avec succès';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Échec du vidage du cache';

  @override
  String get appSetting_about_titleText => 'À propos';

  @override
  String get appAbout_appbarTile_titleText => 'À propos';

  @override
  String appAbout_verionTile_titleText(String appVersion) {
    return 'Version: $appVersion';
  }

  @override
  String get appAbout_verionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Code source';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Suivi des tickets';

  @override
  String get appAbout_contactEmailTile_titleText => 'Me contacter';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Salut, je suis content que vous me contactiez.\nSi vous voulez remonter une anomalie, merci d’indiquer la version de l’application et de décrire les étapes pour la reproduire.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licence';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Déclaration des licences pour les tierces parties';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Don';

  @override
  String get appAbout_donateTile_subTitleText => 'Je suis un développeur particulier. Si vous aimez cette application, offrez-moi un ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'M’offrir un café';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Cryptomonnaies';

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
  String get donateWay_firstQRGroup => 'Alipay et Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'Adresse de $name copiée';
  }

  @override
  String get batchCheckin_appbar_title => 'Batch Check-in';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Previous day';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Next day';

  @override
  String get batchCheckin_status_skip_text => 'Skip';

  @override
  String get batchCheckin_status_ok_text => 'Complete';

  @override
  String get batchCheckin_status_double_text => 'x2 Hit!';

  @override
  String get batchCheckin_status_zero_text => 'Incomplete';

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
  String get batchCheckin_save_button_text => 'Save';

  @override
  String get batchCheckin_reset_button_text => 'Reset';

  @override
  String get batchCheckin_save_confirmDialog_title => 'Overwrite Existing Records';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Existing records will be overwritten After saving, previous records will be lost.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'save';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'cancel';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirm Return';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Check-in Status Changes won\'t be applied before saved';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'exit';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'cancel';

  @override
  String get appReminder_dailyReminder_title => '🏝 Avez-vous gardé vos habitudes, aujourd’hui ?';

  @override
  String get appReminder_dailyReminder_body => 'click to enter app and punch in on time.';

  @override
  String get common_habitColorType_cc1 => 'Lilas profond';

  @override
  String get common_habitColorType_cc2 => 'Rouge';

  @override
  String get common_habitColorType_cc3 => 'Violet';

  @override
  String get common_habitColorType_cc4 => 'Bleu royal';

  @override
  String get common_habitColorType_cc5 => 'Cyan foncé';

  @override
  String get common_habitColorType_cc6 => 'Vert';

  @override
  String get common_habitColorType_cc7 => 'Ambre';

  @override
  String get common_habitColorType_cc8 => 'Orange';

  @override
  String get common_habitColorType_cc9 => 'Vert citron';

  @override
  String get common_habitColorType_cc10 => 'Orchidée foncée';

  @override
  String common_habitColorType_default(int index) {
    return 'Couleur $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Utiliser le format du système';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Format de date';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Année Mois Jour';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Mois Jour Année';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Jour Mois Année';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Séparateur';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Tiret';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Barre oblique';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Espace';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Point';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Pas de séparateur';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Utiliser le système horaire sur 12 heures';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Utiliser les noms complets';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Appliquer pour le tableau des fréquences';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Appliquer pour le calendrier';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'Annuler';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'Confirmer';

  @override
  String get calendarPicker_clip_today => 'Aujourd’hui';

  @override
  String get calendarPicker_clip_tomorrow => 'Demain';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Suivant $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Exporter toutes les habitudes ?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number habitudes',
      one: '1 habitude',
      zero: 'l’habitude courante',
    );
    return 'Exporter $_temp0 ?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'Inclure les entrées';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'Annuler';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'Exporter';

  @override
  String get snackbar_undoText => 'ANNULER';

  @override
  String get snackbar_dissmessText => 'REJETER';

  @override
  String get contributors_tile_title => 'Contributeurs';

  @override
  String get userAction_tap => 'Appui';

  @override
  String get userAction_doubleTap => 'Double';

  @override
  String get userAction_longTap => 'Long';
}
