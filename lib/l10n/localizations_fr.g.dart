// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

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
  String get habitEdit_habitDailyGoalUnit_hintText =>
      'Unité de l’objectif journalier';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Objectif journalier maximum souhaité';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Valeur invalide. Ce doit être vide ou ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Limite journalière maximale';

  @override
  String get habitEdit_frequencySelector_title => 'Sélectionner une fréquence';

  @override
  String get habitEdit_habitFreq_daily => 'Journalier';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% fois par semaine';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% fois par mois';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% fois en %%day%% jours';

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
  String get habitEdit_targetDays_dialogTitle =>
      'Sélectionner le nombre de jours ciblé';

  @override
  String get habitEdit_targetDays => 'jours';

  @override
  String get habitEdit_reminder_hintText => 'Rappel';

  @override
  String get habitEdit_reminder_freq_weekHelpText =>
      'Tous les jours de la semaine';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days de chaque semaine';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Tous les jours du mois';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days de chaque mois';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Question. Par exemple: avez-vous fait de l’exercice aujourd’hui ?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Choisir un type de rappel';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Lorsque c’est nécessaire';

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
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Confirmez-vous la suppression de ce rappel ?';

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
  String get habitEdit_reminder_weekdayText_thursday => 'Jeu';

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
  String get habitDisplay_emptyImage_text_01 =>
      'Un voyage de mille lieux commence par un pas';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'No matching habits found';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'No matching habits for \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Archiver les habitudes sélectionnées ?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'Annuler';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count habitudes archivées';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Désarchiver les habitudes sélectionnées ?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'Annuler';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count habitudes désarchivées';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Supprimer les habitudes sélectionnées ?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'Confirmer';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'Annuler';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count habitudes supprimées';
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
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Podium des habitudes: 30 derniers jours';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Thème clair';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Thème sombre';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Suivre le système';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Afficher les archivées';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'Afficher les complétées';

  @override
  String get habitDisplay_mainMenu_showActivedTileText =>
      'Afficher les actives';

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
  String get habitDisplay_searchBar_hintText => 'Search habits';

  @override
  String get habitDisplay_searchFilter_ongoing => 'En cours';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'Complétées';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle =>
      'Type d’habitude';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Show Filters';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clear Filters';

  @override
  String get habitDisplay_tab_habits_label => 'Habits';

  @override
  String get habitDisplay_tab_today_label => 'Aujourd’hui';

  @override
  String get habitToday_appBar_title => 'Aujourd’hui';

  @override
  String get habitToday_image_desc => 'YOU MADE IT';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Kept it up for $days days';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Done+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Skip+';

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
  String get habitDetail_archiveConfirmDialog_titleText =>
      'Archiver l’habitude ?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Désarchiver l’habitude ?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText =>
      'Supprimer l’habitude ?';

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
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Masquer le graphe d’historique';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Afficher le graphe d’historique';

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
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'revenir à aujourd’hui';

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
  String get habitDetail_skipReason_bodyHelpText =>
      'Écrivez quelque chose ici…';

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
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Défilement du calendrier page par page';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Si ce bouton est activé, le calendrier présent sur la barre d’application de la page d’accueil défilera page par page. Par défaut, le bouton est désactivé.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Modifier le statut de l’entrée';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Modifier le type de clic permettant de changer le statut des entrées journalières sur la page principale.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Ouvrir le détail de l’entrée';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Modifier le type de clic permettant d’ouvrir la boîte de dialgue détaillée des entrées journalières sur la page principale.';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Theme Color';

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
  String get appSetting_firstDayOfWeek_titleText =>
      'Premier jour de la semaine';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Afficher le premier jour de la semaine';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (par défaut)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Follow System ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Follow System';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Language';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Select Language';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Format de l’affichage des dates ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'suivre le paramétrage du système';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Le format configuré sera appliqué à l’affichage des dates sur le détail de l’habitude.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Activer l’interface compacte sur la page des habitudes';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Permet au tableau des habitudes d’afficher plus de contenu. Certains éléments et textes apparaitront plus petits.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Ajustement de la zone de validation des habitudes';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Ajuster le pourcentage pour avoir plus ou moins d’espace dans la zone de validation des habitudes.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Défaut';

  @override
  String get appSetting_reminderSubgroupText => 'Rappel';

  @override
  String get appSetting_dailyReminder_titleText => 'Rappel journalier';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Sauvegarder et restaurer';

  @override
  String get appSetting_export_titleText => 'Exporter';

  @override
  String get appSetting_export_subtitleText =>
      'Exporter les habitudes au format JSON. Ce fichier peut être importé.';

  @override
  String get appSetting_import_titleText => 'Importer';

  @override
  String get appSetting_import_subtitleText =>
      'Importer les habitudes à partir d’un fichier au format JSON.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Confirmer l’import de $count habitudes ?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Note: l’import ne supprime pas les habitudes existantes.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'Confirmer';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'Annuler';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return '$completeCount/$totalCount importées';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Import complet $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'Fermer';

  @override
  String get appSetting_resetConfig_titleText =>
      'Réinitialiser la configuration';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Réinitialiser la configuration aux valeurs par défaut.';

  @override
  String get appSetting_resetConfigDialog_titleText =>
      'Réinitialiser la configuration ?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'La configuration sera réinitialisée aux valeurs par défaut. Vous devrez redémarrer l’application pour que ce soit appliqué.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'Annuler';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'Confirmer';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'Réinitialisation de la configuration réussie';

  @override
  String get appSetting_otherSubgroupText => 'Autre';

  @override
  String get appSetting_developMode_titleText => 'Mode développement';

  @override
  String get appSetting_clearCache_titleText => 'Vider le cache';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Vider le cache';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Après avoir vidé le cache, certaines valeurs personnelles seront réinitialisées aux valeurs par défaut.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'Annuler';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'Confirmer';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Échec du vidage partiel du cache';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Cache vidé avec succès';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Échec du vidage du cache';

  @override
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'À propos';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Experimental Features';

  @override
  String get appSetting_synSubgroupText => 'Sync';

  @override
  String get appSetting_syncOption_titleText => 'Sync Options';

  @override
  String get appSetting_notify_titleTile => 'Notifications';

  @override
  String get appSetting_notify_subtitleTile =>
      'Manage notification preferences';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Tap to open system notification settings';

  @override
  String get appSync_nowTile_titleText => 'Synchroniser maintenant';

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
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
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
  String get appSync_webdav_newServerConfirmDialog_titleText => 'New Location';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Syncing will create necessary directories and upload local habits to the server. Continue?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText => 'Sync Now!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText => 'Confirm Sync';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Directory isn\'t empty. Syncing will merge server and local habits. Continue?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Confirm Merge';

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
  String get appSync_syncIntervalTile_title => 'Fetch Interval';

  @override
  String get appSync_summaryTile_title => 'Sync Server';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Not Configured';

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
  String get appSync_serverEditor_exitDialog_titleText => 'Unsaved Changes';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Exiting will discard all unsaved changes.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Confirm Delete';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Deleting will remove current server config.';

  @override
  String get appSync_serverEditor_titleText_add => 'New Sync Server';

  @override
  String get appSync_serverEditor_titleText_modify => 'Modify Sync Server';

  @override
  String get appSync_serverEditor_advance_titleText => 'Advanced Configs';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Path';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Enter a valid WebDAV path here.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Path shouldn\'t be empty!';

  @override
  String get appSync_serverEditor_usernameTile_titleText =>
      'Nom d\'utilisateur';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Enter username here, leave empty if not required.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Mot de passe';

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
  String get experimentalFeatures_habitSearchTile_titleText => 'Habit Search';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Once enabled, a search bar will appear at the top of the Habits screen and allowing to search habits.';

  @override
  String get appAbout_appbarTile_titleText => 'À propos';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Version: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Code source';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Suivi des tickets';

  @override
  String get appAbout_contactEmailTile_titleText => 'Me contacter';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Salut, je suis content que vous me contactiez.\nSi vous voulez remonter une anomalie, merci d’indiquer la version de l’application et de décrire les étapes pour la reproduire.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licence';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Déclaration des licences pour les tierces parties';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Privacy';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Access the privacy policy in this app';

  @override
  String get appAbout_donateTile_titleText => 'Don';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Je suis un développeur particulier. Si vous aimez cette application, offrez-moi un ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

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
  String get batchCheckin_appbar_title => 'Validation groupée';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Jour précédent';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Jour suivant';

  @override
  String get batchCheckin_status_skip_text => 'Passer';

  @override
  String get batchCheckin_status_ok_text => 'Complet';

  @override
  String get batchCheckin_status_double_text => 'Double réussite !';

  @override
  String get batchCheckin_status_zero_text => 'Incomplet';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habitudes',
      one: 'Habitude',
    );
    return '$_temp0 sélectionnée(s)';
  }

  @override
  String get batchCheckin_save_button_text => 'Enregistrer';

  @override
  String get batchCheckin_reset_button_text => 'Réinitialiser';

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
      'Écraser les enregistrements existants';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Les enregistrements existants seront écrasés. Après l\'enregistrement, les enregistrements précédents seront perdus.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text =>
      'Enregistrer';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'Annuler';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirmer le retour';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Les changements d\'état de validation ne seront pas appliqués avant d\'être enregistrés.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'Quitter';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'Annuler';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Avez-vous gardé vos habitudes, aujourd’hui ?';

  @override
  String get appReminder_dailyReminder_body =>
      'click to enter app and punch in on time.';

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
  String get common_appThemeColor_system => 'System';

  @override
  String get common_appThemeColor_primary => 'Primary';

  @override
  String get common_appThemeColor_dynamic => 'Dynamic';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Utiliser le format du système';

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
  String get common_customDateTimeFormatPicker_empty_text =>
      'Pas de séparateur';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Utiliser le système horaire sur 12 heures';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Utiliser les noms complets';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Appliquer pour le tableau des fréquences';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Appliquer pour le calendrier';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'Annuler';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text =>
      'Confirmer';

  @override
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

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
  String get exportConfirmDialog_title_exportAll =>
      'Exporter toutes les habitudes ?';

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
    return 'Downloading $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Debug log doesn\'t exist.';

  @override
  String get debug_debuggerLogCard_title => 'Logging Information';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Includes local debugging log information, need to turn on the log collection switcher.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Download';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Clear';

  @override
  String get debug_debuggerInfoCard_title => 'Debugging Information';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Includes app\'s debugging information.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Open';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Save';

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
  String get confirmDialog_cancel_text => 'Cancel';

  @override
  String get snackbar_undoText => 'ANNULER';

  @override
  String get snackbar_dismissText => 'REJETER';

  @override
  String get contributors_tile_title => 'Contributeurs';

  @override
  String get userAction_tap => 'Appui';

  @override
  String get userAction_doubleTap => 'Double';

  @override
  String get userAction_longTap => 'Long';

  @override
  String get channelName_habitReminder => 'Habit Reminder';

  @override
  String get channelName_appReminder => 'Prompt';

  @override
  String get channelName_appDebugger => 'Debugger';

  @override
  String get channelName_appSyncing => 'Sync Process';

  @override
  String get channelDesc_appSyncing =>
      'Used to show sync progress and non-failure results';

  @override
  String get channelName_appSyncFailed => 'Sync Failed';

  @override
  String get channelDesc_appSyncFailed => 'Used to alert when sync fails';
}
