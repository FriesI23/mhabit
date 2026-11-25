// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Esperanto (`eo`).
class L10nEo extends L10n {
  L10nEo([String locale = 'eo']) : super(locale);

  @override
  String get localeScriptName => 'Esperanto';

  @override
  String get appName => 'Table Habit';

  @override
  String get common_listSeparator => ', ';

  @override
  String get habitEdit_saveButton_text => 'Konservi';

  @override
  String get habitEdit_habitName_hintText => 'Nomo de la kutimo...';

  @override
  String get habitEdit_colorPicker_title => 'Elekti koloron';

  @override
  String get habitEdit_colorPicker_historySectionLabel => 'Lastatempe uzataj';

  @override
  String habitEdit_colorPicker_customSectionLabel(String tinted) {
    String _temp0 = intl.Intl.selectLogic(tinted, {
      'true': 'Propra (nuancita)',
      'false': 'Propra',
      'other': 'Propra',
    });
    return '$_temp0';
  }

  @override
  String get habitEdit_colorPicker_cancel => 'Nuligi';

  @override
  String get habitEdit_colorPicker_tintToggleLabel => 'Nuanci laŭ la etoso';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Nuancita';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Ne nuancita';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'La agordo de nuanco povas ŝanĝi la finan koloron for de tiu, kiun vi elektis.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Iuj koloroj povas malfaciligi la legadon de teksto en hela aŭ malhela etoso.';

  @override
  String get habitEdit_habitTypeDialog_title => 'Tipo de kutimo';

  @override
  String get habitEdit_habitType_positiveText => 'Pozitiva';

  @override
  String get habitEdit_habitType_negativeText => 'Negativa';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Ĉiutaga celo, defaŭlte $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Minimuma ĉiutaga sojlo, defaŭlte $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'ĉiutaga celo devas esti > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'ĉiutaga celo devas esti ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'ĉiutaga celo devas esti ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'ĉiutaga celo devas esti ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Unuo de la ĉiutaga celo';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Dezirata maksimuma ĉiutaga celo';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'nevalida valoro; devas esti malplena aŭ ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Maksimuma ĉiutaga limo';

  @override
  String get habitEdit_frequencySelector_title => 'Elekti oftecon';

  @override
  String get habitEdit_habitFreq_daily => 'Ĉiutage';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% fojojn semajne';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% fojojn monate';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% fojojn en %%day%% tagoj';

  @override
  String get habitEdit_habitFreq_show_daily => 'Ĉiutage';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Almenaŭ $freq fojojn semajne',
      one: 'Semajne',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Almenaŭ $freq fojojn monate',
      one: 'Monate',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Almenaŭ $freq fojojn ĉiujn $days tagojn',
      one: 'Ĉiujn $days tagojn',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays tagoj';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Elekti celajn tagojn';

  @override
  String get habitEdit_targetDays => 'tagoj';

  @override
  String get habitEdit_reminder_hintText => 'Memorigo';

  @override
  String get habitEdit_reminder_freq_weekHelpText =>
      'Iu ajn tago de la semajno';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days en ĉiu semajno';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText =>
      'Iu ajn tago de la monato';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days en ĉiu monato';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Demando, ekz. Ĉu vi ekzercis vin hodiaŭ?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Elekti tipon de memorigo';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Kiam necesas registri agadon';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Ĉiutage';

  @override
  String get habitEdit_reminder_dialogType_week => 'Semajne';

  @override
  String get habitEdit_reminder_dialogType_month => 'Monate';

  @override
  String get habitEdit_reminder_dialogConfirm => 'konfirmi';

  @override
  String get habitEdit_reminder_dialogCancel => 'nuligi';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Konfirmi';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Ĉu forigi ĉi tiun memorigon?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'konfirmi';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'nuligi';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Lun';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Mar';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Mer';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Ĵaŭ';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Ven';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sab';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Dim';

  @override
  String get habitEdit_desc_hintText => 'Noto, subtenas Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Kreita: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Modifita: ';

  @override
  String get habitDisplay_fab_text => 'Nova kutimo';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'Vojaĝo de mil mejloj komenciĝas per unuopa paŝo';

  @override
  String get habitDisplay_notFoundImage_text_01 =>
      'Neniuj kongruaj kutimoj trovitaj';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'Neniuj kutimoj kongruas kun \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Ĉu arkivi la elektitajn kutimojn?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'konfirmi';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'nuligi';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Arkivis $count kutimojn';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Ĉu malarkivi la elektitajn kutimojn?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'konfirmi';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'nuligi';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Malarkivis $count kutimojn';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Ĉu forigi la elektitajn kutimojn?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'konfirmi';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'nuligi';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Forigis $count kutimojn';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Forigis kutimon: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eksportis $count kutimojn.',
      one: 'Eksportis kutimon.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Ĉiuj kutimoj eksportitaj';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Elekti ĉion';

  @override
  String get habitDisplay_selectButton_label => 'Elekti';

  @override
  String get habitDisplay_doneButton_label => 'Farite';

  @override
  String habitDisplay_selectedHabits_title(int count) {
    return 'Elektitaj: $count';
  }

  @override
  String get habitDisplay_editPopMenu_export => 'Eksporti';

  @override
  String get habitDisplay_editPopMenu_delete => 'Forigi';

  @override
  String get habitDisplay_editPopMenu_clone => 'Ŝablono';

  @override
  String get habitDisplay_editButton_tooltip => 'Redakti';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Arkivi';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Malarkivi';

  @override
  String get habitDisplay_settingButton_tooltip => 'Agordo';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Aktuala';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Finita';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Daŭranta';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Arkivita';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Ĉefaj kutimoj: Ŝanĝoj en la lastaj 30 tagoj';

  @override
  String get habitDisplay_statisticsAction_label => 'Statistikoj';

  @override
  String get habitDisplay_displayFilterAction_label => 'Montra filtrilo';

  @override
  String get habitDisplay_displayFilter_inProgress => 'Daŭranta';

  @override
  String get habitDisplay_displayFilter_archived => 'Arkivita';

  @override
  String get habitDisplay_displayFilter_completed => 'Finita';

  @override
  String get common_appThemeMode_light => 'Hela';

  @override
  String get common_appThemeMode_dark => 'Malhela';

  @override
  String get common_appThemeMode_followSystem => 'Aŭtomata';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Montri arkivitajn';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Montri finitajn';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Montri daŭrantajn';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Agordoj';

  @override
  String get habitDisplay_groupType_name => 'Laŭ nomo';

  @override
  String get habitDisplay_groupType_colorType => 'Laŭ koloro';

  @override
  String get habitDisplay_groupType_createDate => 'Laŭ kreodato';

  @override
  String get habitDisplay_groupType_habitCount => 'Laŭ nombro da kutimoj';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Ordigi grupojn';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'konfirmi';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'nuligi';

  @override
  String get habitDisplay_groupTypeDialog_none => 'Sen grupigo';

  @override
  String get habitDisplay_editPopMenu_groupModify => 'Modifi grupon';

  @override
  String get habitDisplay_groupModifyDialog_title => 'Modifi grupon';

  @override
  String get habitDisplay_groupModifyDialog_removeGroup => 'Forigi grupon';

  @override
  String get habitDisplay_groupModifyDialog_emptyGroups =>
      'Neniuj grupoj disponeblaj';

  @override
  String get habitDisplay_groupModifyDialog_alreadyInGroup =>
      'Elektitaj kutimoj jam estas en ĉi tiu grupo';

  @override
  String get habitDisplay_groupModifyDialog_createGroup => 'Krei grupon';

  @override
  String get habitDisplay_groupModifyDialog_saveAndApply =>
      'Konservi kaj apliki';

  @override
  String get habitDisplay_groupModifyConfirm_titleNew => 'Movi al grupo';

  @override
  String get habitDisplay_groupModifyConfirm_titleMixed =>
      'Konfirmi ŝanĝon de grupo';

  @override
  String habitDisplay_groupModifyConfirm_bodyNewGroup(String groupName) {
    return 'Kutimoj de $groupName estos movitaj al ĉi tiu grupo';
  }

  @override
  String get habitDisplay_groupModifyConfirm_bodyRemoveGroup =>
      'La grupo de la kutimoj estos forigita';

  @override
  String habitDisplay_groupModifyConfirm_bodyChangeStat(
    int count,
    String fromGroup,
    String toGroup,
    int remainingGroupCount,
    int totalGroupCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remainingGroupCount,
      locale: localeName,
      other:
          ' kaj $remainingGroupCount pliaj grupoj ($totalGroupCount grupoj entute)',
      one: ' kaj 1 plia grupo ($totalGroupCount grupoj entute)',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      remainingGroupCount,
      locale: localeName,
      other:
          ' kaj $remainingGroupCount pliaj grupoj ($totalGroupCount grupoj entute)',
      one: ' kaj 1 plia grupo ($totalGroupCount grupoj entute)',
      zero: '',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kutimoj ŝanĝiĝos de \"$fromGroup\"$_temp0 al \"$toGroup\"',
      one: '$count kutimo ŝanĝiĝos de \"$fromGroup\"$_temp1 al \"$toGroup\"',
    );
    return '$_temp2';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyAddStat(
    int count,
    String toGroup,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nekategoriitaj kutimoj estos aldonitaj al \"$toGroup\"',
      one: '$count nekategoriita kutimo estos aldonita al \"$toGroup\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyRemoveStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'La grupoj de $count kutimoj estos forigitaj',
      one: 'La grupo de $count kutimo estos forigita',
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
      other: '$count kutimoj movitaj al \"$groupName\"',
      one: 'Kutimo movita al \"$groupName\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModify_snackbarTextRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Forigis grupojn de $count kutimoj',
      one: 'Forigis grupon de kutimo',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_groupModify_undoFailed =>
      'La grupo estis modifita aliloke; ne eblas malfari la agon';

  @override
  String get habitDisplay_sort_reverseText => 'Inversigi';

  @override
  String get habitDisplay_sortDirection_asc => '(kreskante)';

  @override
  String get habitDisplay_sortDirection_Desc => '(malkreskante)';

  @override
  String get habitDisplay_sortType_manual => 'Mia ordo';

  @override
  String get habitDisplay_sortType_name => 'Laŭ nomo';

  @override
  String get habitDisplay_sortType_colorType => 'Laŭ koloro';

  @override
  String get habitDisplay_sortType_progress => 'Laŭ sukcesprocento';

  @override
  String get habitDisplay_sortType_startT => 'Laŭ komencdato';

  @override
  String get habitDisplay_sortType_status => 'Laŭ stato';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Ordigi';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'konfirmi';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'nuligi';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Sencimigi';

  @override
  String get habitDisplay_searchBar_hintText => 'Serĉi kutimojn';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Daŭrantaj';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Montras kutimojn, kiuj estas nuntempe aktivaj kaj daŭrantaj (ne arkivitaj aŭ forigitaj).';

  @override
  String get habitDisplay_searchFilter_completed => 'Finita';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Tipo de kutimo';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Montri filtrilojn';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Forigi filtrilojn';

  @override
  String get habitDisplay_tab_habits_label => 'Kutimoj';

  @override
  String get habitDisplay_tab_today_label => 'Hodiaŭ';

  @override
  String get habitToday_appBar_title => 'Hodiaŭ';

  @override
  String get habitToday_image_desc => 'VI SUKCESIS';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Vi daŭrigis la kutimon dum $days tagoj';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Fari+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Preterlasi+';

  @override
  String get habitDetail_editButton_tooltip => 'Redakti';

  @override
  String get habitDetail_recordCalendar_label => 'Registri agadon';

  @override
  String get habitDetail_recordCalendar_tooltip =>
      'Malfermi kalendaron por registrado';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Malarkivi';

  @override
  String get habitDetail_editPopMenu_archive => 'Arkivi';

  @override
  String get habitDetail_editPopMenu_export => 'Eksporti';

  @override
  String get habitDetail_editPopMenu_delete => 'Forigi';

  @override
  String get habitDetail_editPopMenu_clone => 'Ŝablono';

  @override
  String get habitDetail_confirmDialog_confirm => 'konfirmi';

  @override
  String get habitDetail_confirmDialog_cancel => 'nuligi';

  @override
  String get habitDetail_archiveConfirmDialog_titleText =>
      'Ĉu arkivi la kutimon?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Ĉu malarkivi la kutimon?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText =>
      'Ĉu forigi la kutimon?';

  @override
  String get habitDetail_summary_title => 'Resumo';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'La nuna takso estas $score, kaj pasis $days tagoj de la komenco.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Komenciĝos post $days tagoj.',
      one: 'Komenciĝos morgaŭ.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'SUBNORMA',
      one: 'NEKOMPLETA',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'SENMAKULA',
      one: 'SUPERPLENUMITA',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Celo',
      two: 'Sojlo',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Unuo: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Tagoj',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 't';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Registraĵoj';

  @override
  String get habitDetail_scoreChart_title => 'Poentaro';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Tago';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Semajno';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Monato';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Jaro';

  @override
  String get habitDetail_freqChart_freqTitle => 'Ofteco';

  @override
  String get habitDetail_freqChart_historyTitle => 'Historio';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Ofteco kaj historio';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Semajno';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Monato';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Jaro';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Nun';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Kaŝi la diagramon de historio';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Montri la diagramon de historio';

  @override
  String get habitDetail_descSubgroup_title => 'Noto';

  @override
  String get habitDetail_otherSubgroup_title => 'Alia';

  @override
  String get habitDetail_habitType_title => 'Tipo';

  @override
  String get habitDetail_reminderTile_title => 'Memorigo';

  @override
  String get habitDetail_freqTile_title => 'Ripeto';

  @override
  String get habitDetail_startDateTile_title => 'Komenca dato';

  @override
  String get habitDetail_createDateTile_title => 'Kreita';

  @override
  String get habitDetail_modifyDateTile_title => 'Modifita';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'dato';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'valoro';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'reveni al hodiaŭ';

  @override
  String get common_loadError_text => 'Ŝargado malsukcesis';

  @override
  String get common_loadError_retryText => 'Provi denove';

  @override
  String get habitDetail_notFoundText => 'Ŝargado de kutimo malsukcesis';

  @override
  String get habitDetail_notFoundRetryText => 'Provi denove';

  @override
  String get habitDetail_changeGoal_title => 'Ŝanĝi celon';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'aktuala: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'plenumita: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'neplenumita';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Ĉiutaga celo, defaŭlte: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'nuligi';

  @override
  String get habitDetail_changeGoal_saveText => 'konservi';

  @override
  String get habitDetail_skipReason_title => 'Kialo por preterlasi';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Skribu ion ĉi tie...';

  @override
  String get habitDetail_skipReason_cancelText => 'nuligi';

  @override
  String get habitDetail_skipReason_saveText => 'konservi';

  @override
  String get appSetting_appbar_titleText => 'Agordoj';

  @override
  String get appSetting_displaySubgroupText => 'Montrado';

  @override
  String get appSetting_operationSubgroupText => 'Uzado';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Treni la kalendaron po paĝo';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Se ĉi tiu opcio estas aktivigita, la kalendaro en la aplikaĵa breto sur la ĉefpaĝo estos trenata paĝon post paĝo. Defaŭlte, la opcio estas malaktivigita.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Ŝanĝi staton de registraĵo';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Agordi la konduton de klako por ŝanĝi la staton de ĉiutagaj registraĵoj sur la ĉefpaĝo.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Malfermi detalan registraĵon';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Agordi la konduton de klako por malfermi la detalan ŝprucfenestron por ĉiutagaj registraĵoj sur la ĉefpaĝo.';

  @override
  String get appSetting_expandTimerDelayTile_titleText =>
      'Prokrasto por vastigi grupon';

  @override
  String get appSetting_expandTimerDelayTile_subtitleText =>
      'Agordi kiom longe ŝvebi super faldita grupkapo antaŭ ol ĝi aŭtomate vastiĝos dum trenado kaj faligo.';

  @override
  String get appSetting_expandTimerDelay_default => 'Defaŭlte';

  @override
  String get appSetting_expandTimerDelay_fast => 'Rapide';

  @override
  String get appSetting_expandTimerDelay_slow => 'Malrapide';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Etosa koloro';

  @override
  String get appSetting_appThemeModeTile_titleText => 'Etosa reĝimo';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'Elekti etosan koloron';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Uzi la ĉefan koloron de tapeto (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'Uzi la elektitan fonkoloron de GTK+-temo';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Uzi sisteman etoskoloron';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Uzi la sisteman akcentan koloron aŭ la koloron de fenestro/vitro';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Unua tago de semajno';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Montri la unuan tagon de la semajno';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Defaŭlta)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Sekvi sistemon ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Sekvi sistemon';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Lingvo';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Elekti lingvon';

  @override
  String appSetting_changeLanguageDialog_currentLanguage_text(
    String localeName,
  ) {
    return 'Nuna lingvo: $localeName';
  }

  @override
  String get appSetting_languageSubgroupText => 'Lingvo';

  @override
  String get appSetting_openSystemLanguageTile_titleText =>
      'Sistemaj lingvaj agordoj';

  @override
  String get appSetting_openSystemLanguageTile_dialogTitle =>
      'Malfermi sistemajn lingvo-agordojn';

  @override
  String get appSetting_openSystemLanguageTile_macosDialogContent =>
      'Pro macOS-limigoj, la aplikaĵa lingvo ne povas esti rekte ŝanĝita. Por ŝanĝi lingvojn, sekvu ĉi tiujn paŝojn:\n\n1. Malfermu **Sistemaj Agordoj > Ĝenerala > Lingvo kaj Regiono**\n2. Aldonu ĉi tiun programon en la liston de **Aplikoj** kaj elektu lingvon';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Dato-montra formato ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'sekvi sisteman agordon';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Agordita datformato estos aplikita al la dato-montrado sur la detala paĝo de kutimo.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Ebligi kompaktan uzantinterfacon sur la paĝo de kutimoj';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Permesas al la registra tabelo de kutimoj montri pli da enhavo, sed iuj interfacaj elementoj kaj teksto povas aperi pli malgrandaj.';

  @override
  String get appSetting_appleCollapsedSidebarSwitcher_titleText =>
      'Montri horizontalan flankbreton';

  @override
  String get appSetting_appleCollapsedSidebarSwitcher_subtitleText =>
      'Montri navigaciajn cellokojn en la supra breto dum la flankbreto estas kaŝita.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Grando de la registra areo?';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Alĝustigi la grandon de la registra tabelo.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Defaŭlte';

  @override
  String get appSetting_reminderSubgroupText => 'Memorigo kaj sciigo';

  @override
  String get appSetting_dailyReminder_titleText => 'Ĉiutaga memorigo';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Sekurkopio kaj restarigo';

  @override
  String get appSetting_export_titleText => 'Eksporto';

  @override
  String get appSetting_export_subtitleText =>
      'Eksportas kutimojn en JSON-formato. Ĉi tiun dosieron oni povas reimporti.';

  @override
  String get appSetting_import_titleText => 'Importi';

  @override
  String get appSetting_import_subtitleText =>
      'Importi kutimojn el json-dosiero.';

  @override
  String get appSetting_thirdPartyImport_titleText =>
      'Importi el aliaj aplikaĵoj';

  @override
  String get appSetting_thirdPartyImport_subtitleText =>
      'Importi kutimojn el aliaj aplikaĵoj por spuri kutimojn';

  @override
  String get appSetting_thirdPartyImport_provider_loopName =>
      'Loop Habit Tracker';

  @override
  String get appSetting_thirdPartyImport_provider_versionHint =>
      'Subtenas CSV (testita ĝis <ver/>)';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Ĉu importi $count kutimojn?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Noto: Importado ne forigas ekzistantajn kutimojn.';

  @override
  String get appSetting_importDialog_option_includeHabits =>
      'Inkluzivi kutimojn';

  @override
  String get appSetting_importDialog_option_includeGroups =>
      'Inkluzivi grupojn';

  @override
  String appSetting_importDialog_tile_includeHabits(int count) {
    return 'Inkluzivi $count kutimojn';
  }

  @override
  String appSetting_importDialog_tile_includeGroups(int count) {
    return 'Inkluzivi $count grupojn';
  }

  @override
  String appSetting_importConfirmDialog_sourceLabel(String provider) {
    return 'Fonto: $provider';
  }

  @override
  String get appSetting_thirdPartyImport_error_fileReadError =>
      'Malsukcesis legi la elektitan dosieron.';

  @override
  String get appSetting_thirdPartyImport_error_noHabitsFound =>
      'Neniuj kutimoj trovitaj en la importdosiero.';

  @override
  String get appSetting_thirdPartyImport_error_parseError =>
      'Malsukcesis analizi importdosieron';

  @override
  String get appSetting_thirdPartyImport_error_unknown =>
      'Neatendita eraro okazis dum importo.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'konfirmi';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'nuligi';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'Importitaj $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Importitaj kutimoj: $count';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Importitaj grupoj: $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'fermi';

  @override
  String get appSetting_resetConfig_titleText => 'Restarigi agordojn';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Restarigi ĉiujn agordojn al la defaŭltoj.';

  @override
  String get appSetting_resetConfigDialog_titleText =>
      'Ĉu restarigi la agordojn?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Restarigi ĉiujn agordojn al la defaŭltoj; necesas rekomenci la aplikaĵon por apliki ilin.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'nuligi';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'konfirmi';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'Agordoj sukcese restarigitaj';

  @override
  String get appSetting_otherSubgroupText => 'Aliaj';

  @override
  String get appSetting_developMode_titleText => 'Programista reĝimo';

  @override
  String get appSetting_clearCache_titleText => 'Malplenigi kaŝmemoron';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Malplenigi kaŝmemoron';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Post malplenigo de kaŝmemoro, iuj propraj valoroj estos restarigitaj al defaŭltoj.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'nuligi';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'konfirmi';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Malplenigo de kaŝmemoro parte malsukcesis';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Malplenigo de kaŝmemoro sukcesis';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Malplenigo de kaŝmemoro malsukcesis';

  @override
  String get appSetting_debugger_titleText => 'Sencimigaj informoj';

  @override
  String get appSetting_about_titleText => 'Pri';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Eksperimentaj funckioj';

  @override
  String get appSetting_synSubgroupText => 'Sinkronigi';

  @override
  String get appSetting_syncOption_titleText => 'Opcioj de sinkronigo';

  @override
  String get appSetting_notify_titleTile => 'Sciigoj';

  @override
  String get appSetting_notify_subtitleTile => 'Administri sciigajn preferojn';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Frapu por malfermi sistemajn sciigajn agordojn';

  @override
  String get appSync_nowTile_titleText => 'Sinkronigi nun';

  @override
  String get appSync_nowTile_titleText_syncing => 'Sinkronigado';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'Lasta sinkronigo: neniam';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Lasta sinkronigo: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Lasta sinkronigo (eraro): neniam';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Lasta sinkronigo (eraro): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Sinkronigante...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Sinkronigado: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Nuligante...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Lasta sinkronigo (nuligita): neniam';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Lasta sinkronigo (nuligita): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText =>
      'Kontroli protokolojn de malsukcesoj';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Eraro]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Finita',
      'cancelled': 'Nuligita',
      'failed': 'Malsukcesis',
      'multi': 'Pluraj statoj',
      'other': 'Nekonata stato',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Finita pro $reason',
      'cancelled': 'Nuligita pro $reason',
      'failed': 'Malsukcesis pro $reason',
      'multi': 'Pluraj statoj pro $reason',
      'other': 'Nekonata stato',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Eraro',
      'userAction': 'Necesas ago de uzanto',
      'missingHabitUuid': 'Mankas UUID de kutimo',
      'empty': 'Malplenaj datumoj',
      'other': 'Nekonata kialo',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'Nova loko';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Sinkronigado kreos necesajn dosierujojn kaj alŝutos lokajn kutimojn al la servilo. Ĉu daŭrigi?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Sinkronigi nun!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Konfirmi sinkronigon';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'La dosierujo ne estas malplena. Sinkronigado kunfandos la kutimojn de la servilo kaj la lokajn. Ĉu daŭrigi?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Konfirmi kunfandon';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Eksporti protokolojn de malsukcesaj sinkronigoj';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'Neniu protokolo trovita',
      'false': 'Frapetu por eksporti',
      'other': 'ŝargado...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Nuna: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Falsa (nur por sencimigilo)',
      'other': 'Nekonata ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Poŝtelefona reto',
      'wifi': 'Wifi',
      'other': 'Nekonata',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Permane',
      'minute5': '5 minutoj',
      'minute15': '15 minutoj',
      'minute30': '30 minutoj',
      'hour1': '1 horo',
      'other': 'Nekonata',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Intervalo de sinkronigo';

  @override
  String get appSync_summaryTile_title => 'Sinkroniga servilo';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured => 'Ne agordita';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Ĉiuj lastatempaj malsukcesaj sinkronigaj protokoloj';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Konfirmi konservon de ŝanĝoj';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Konservado anstataŭigos la antaŭan servilan agordon.';

  @override
  String get appSync_serverEditor_exitDialog_titleText =>
      'Nekonservitaj ŝanĝoj';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Eliro forĵetos ĉiujn nekonservitajn ŝanĝojn.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Konfirmi forigon';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Tio forigos la nunan servilan agordon.';

  @override
  String get appSync_serverEditor_titleText_add => 'Nova sinkroniga servilo';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Modifi sinkronigan servilon';

  @override
  String get appSync_serverEditor_advance_titleText => 'Altnivelaj agordoj';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Vojo';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Enigi validan WebDAV-vojon ĉi tie.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'La vojo ne povas esti malplena!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Uzantnomo';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Enigu uzantnomon ĉi tie, lasu malplena se ne necesas.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Pasvorto';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Ignori SSL-atestilon';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Tempolimo de sinkronigo (sekundoj)';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Senfina',
    );
    return 'Defaŭlte: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Tempolimo de reta konekto (sekundoj)';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Senfina',
    );
    return 'Defaŭlte: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Nombro de reprovoj por reta konekto';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Reprovado malŝaltita',
    );
    return 'Defaŭlte: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Reta sinkroniga reĝimo';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Sinkronigo per poŝtelefona reto',
      'wifi': 'Sinkronigo per Wifi',
      'other': 'Nekonata',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'LowData';

  @override
  String get appSync_noti_readyToSync_body => 'Pretigante sinkronigon...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Sinkronigita ($type)',
      'failed': 'Sinkronigo malsukcesis ($type)',
      'other': 'Sinkronigado ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Sinkronigi en datumŝpara reĝimo';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Unu aŭ pluraj eksperimentaj funkcioj estas ebligitaj. Uzu singarde.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Nuba sinkronigo de kutimoj';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Post ebligo, la sinkroniga opcio de la aplikaĵo aperos en la agordoj';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Eksperimenta funkcio ($syncName) estas malŝaltita, sed ĝi ankoraŭ ruliĝas.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Por tute malŝalti, longe premu por aliri \'$menuName\' kaj malŝalti ĝin.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText =>
      'Serĉo de kutimoj';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Post ebligo, serĉbreto aperos supre de la ekrano Kutimoj, per kiu vi povos serĉi kutimojn.';

  @override
  String get appAbout_appbarTile_titleText => 'Pri';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Versio: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Fontkodo';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Spurilo de problemoj';

  @override
  String get appAbout_contactEmailTile_titleText => 'Kontakti min';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Saluton, mi ĝojas, ke vi kontaktis min.\nSe vi raportas cimon, bonvolu indiki la version de la aplikaĵo kaj priskribi la paŝojn por reprodukti ĝin.\n-------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licenco';

  @override
  String get appAbout_licenseTile_subtitleText =>
      'Apache-permesilo, versio 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Deklaro pri licencoj de triaj partioj';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Privateco';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Aliri la privatecan politikon en ĉi tiu aplikaĵo';

  @override
  String get appAbout_donateTile_titleText => 'Donaci';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Mi estas sendependa programisto. Se vi ŝatas ĉi tiun aplikaĵon, bonvolu aĉeti al mi ☕.';

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
  String get donateWay_cryptoCurrency => 'Kriptomonoj';

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
    return 'Adreso de $name kopiita';
  }

  @override
  String get batchCheckin_appbar_title => 'Amasa registrado';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Antaŭa tago';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Sekva tago';

  @override
  String get batchCheckin_status_skip_text => 'Preterlasi';

  @override
  String get batchCheckin_status_ok_text => 'Plenumita';

  @override
  String get batchCheckin_status_double_text => 'x2 Trafo!';

  @override
  String get batchCheckin_status_zero_text => 'Neplenumita';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kutimoj elektitaj',
      one: 'kutimo elektita',
    );
    return '$count $_temp0';
  }

  @override
  String get batchCheckin_save_button_text => 'Konservi';

  @override
  String get batchCheckin_reset_button_text => 'Restarigi';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'la statojn de $count kutimoj',
      one: 'la staton de kutimo',
    );
    return 'Modifis $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title =>
      'Anstataŭigi ekzistantajn registraĵojn';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Konservado anstataŭigos ekzistantajn registraĵojn por la elektita tago.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'konservi';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'nuligi';

  @override
  String habitRecord_delete_buttonText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Forigi registradojn',
      one: 'Forigi registradon',
    );
    return '$_temp0';
  }

  @override
  String habitRecord_deleteConfirmDialog_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Forigi $count registradojn?',
      one: 'Forigi registradon?',
    );
    return '$_temp0';
  }

  @override
  String get batchCheckin_close_confirmDialog_title => 'Konfirmi revenon';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Nekonservitaj registraĵoŝanĝoj estos perditaj se vi foriros.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'eliri';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'nuligi';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Ĉu vi plenumis viajn kutimojn hodiaŭ?';

  @override
  String get appReminder_dailyReminder_body =>
      'Frapetu por malfermi la aplikaĵon kaj registri.';

  @override
  String get common_habitColorType_cc1 => 'Profunda siringo';

  @override
  String get common_habitColorType_cc2 => 'Ruĝa';

  @override
  String get common_habitColorType_cc3 => 'Purpura';

  @override
  String get common_habitColorType_cc4 => 'Reĝa blua';

  @override
  String get common_habitColorType_cc5 => 'Malhela cejana';

  @override
  String get common_habitColorType_cc6 => 'Verda';

  @override
  String get common_habitColorType_cc7 => 'Sukcena';

  @override
  String get common_habitColorType_cc8 => 'Oranĝa';

  @override
  String get common_habitColorType_cc9 => 'Limetverda';

  @override
  String get common_habitColorType_cc10 => 'Malhela orkidea';

  @override
  String get common_habitColorType_custom => 'Propra';

  @override
  String common_habitColorType_default(int index) {
    return 'Koloro $index';
  }

  @override
  String get common_appThemeColor_system => 'Sistemo';

  @override
  String get common_appThemeColor_primary => 'Primara';

  @override
  String get common_appThemeColor_dynamic => 'Dinamika';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Uzi sisteman formaton';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Datformato';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Jaro monato tago';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Monato tago jaro';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Tago monato jaro';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Apartigilo';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Streketo';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Oblikvo';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Spaceto';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Punkto';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Neniu apartigilo';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Uzi 12-horan formaton';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Uzi plenan nomon';

  @override
  String get appDateFormat_leadingZero_text => 'Uzi antaŭajn nulojn';

  @override
  String get appDateFormat_preview_text => 'Antaŭrigardo';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Apliki al la diagramo de ofteco';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Apliki al la kalendaro';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'nuligi';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'konfirmi';

  @override
  String get common_errorPage_title => 'Ho, kraŝis!';

  @override
  String get common_errorPage_copied => 'Kopiitaj kraŝinformoj';

  @override
  String get common_enable_text => 'Ebligita';

  @override
  String get common_dontShowAgain => 'Ne montri denove';

  @override
  String get calendarPicker_clip_today => 'Hodiaŭ';

  @override
  String get calendarPicker_clip_tomorrow => 'Morgaŭ';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Venonta $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'Ĉu eksporti ĉiujn kutimojn?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number kutimojn',
      one: '1 kutimon',
      zero: 'la nunan kutimon',
    );
    return 'Ĉu eksporti $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords =>
      'inkluzivi registraĵojn';

  @override
  String get exportConfirmDialog_option_includeGroups => 'inkluzivi grupojn';

  @override
  String exportConfirmDialog_tile_includeRecords(int count) {
    return 'Inkluzivi $count registraĵojn';
  }

  @override
  String exportConfirmDialog_tile_includeGroups(int count) {
    return 'Inkluzivi $count grupojn';
  }

  @override
  String get exportConfirmDialog_cancel_buttonText => 'nuligi';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'eksporti';

  @override
  String get debug_logLevelTile_title => 'Protokola nivelo';

  @override
  String get debug_logLevelDialog_title => 'Ŝanĝi protokolan nivelon';

  @override
  String get debug_logLevel_debug => 'Sencimigi';

  @override
  String get debug_logLevel_info => 'Info';

  @override
  String get debug_logLevel_warn => 'Averto';

  @override
  String get debug_logLevel_error => 'Eraro';

  @override
  String get debug_logLevel_fatal => 'Fatala';

  @override
  String get debug_collectLogTile_title => 'Kolektado de protokoloj';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Frapetu por ĉesigi la kolektadon de protokoloj.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Frapetu por komenci la kolektadon de protokoloj.';

  @override
  String get debug_downladDebugLogs_subject =>
      'Elŝutante sencimigajn protokolojn';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Sencimigaj protokoloj forigitaj.';

  @override
  String get debug_downladDebugInfo_subject => 'Elŝutante sencimigan informon';

  @override
  String get debug_shareDebugZip_tooltip => 'Kunhavigi sencimigan pakaĵon';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Elŝutante $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Sencimiga protokolo ne ekzistas.';

  @override
  String get debug_debuggerLogCard_title => 'Protokolaj informoj';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Inkluzivas lokajn sencimigajn protokolojn; necesas ŝalti la kolektadon de protokoloj.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Elŝuti';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Malplenigi';

  @override
  String get debug_debuggerInfoCard_title => 'Sencimigaj informoj';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Inkluzivas la sencimigan informon de la aplikaĵo.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Malfermi';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Konservi';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Kolektante informojn de la aplikaĵo...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Konservi',
      'exit': 'Eliri',
      'delete': 'Forigi',
      'other': 'Konfirmi',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'Nuligi';

  @override
  String get snackbar_undoText => 'MALFARI';

  @override
  String get snackbar_dismissText => 'FERMI';

  @override
  String get contributors_tile_title => 'Kontribuantoj';

  @override
  String get userAction_tap => 'Frapeti';

  @override
  String get userAction_doubleTap => 'Duoble';

  @override
  String get userAction_longTap => 'Longe';

  @override
  String get channelName_habitReminder => 'Kutimo-memorigo';

  @override
  String get channelName_appReminder => 'Prompto';

  @override
  String get channelName_appDebugger => 'Sencimigilo';

  @override
  String get channelName_appSyncing => 'Sinkroniga procezo';

  @override
  String get channelDesc_appSyncing =>
      'Uzata por montri sinkronigan progreson kaj ne-malsukcesajn rezultojn';

  @override
  String get channelName_appSyncFailed => 'Sinkronigo malsukcesis';

  @override
  String get channelDesc_appSyncFailed =>
      'Uzata por atentigi kiam la sinkronigo malsukcesas';

  @override
  String changelog_banner_title(String version) {
    return 'Kio estas nova en v$version';
  }

  @override
  String get changelog_banner_action => 'FERMI';

  @override
  String get changelog_banner_view => 'VIDI';

  @override
  String get changelog_dialog_title => 'Ŝanĝprotokolo';

  @override
  String get changelog_view_full => 'Vidi la plenan ŝanĝprotokolon';

  @override
  String get habitGroup_uncategorized => 'Neniu grupo';

  @override
  String get habitDetail_groupTile_title => 'Grupo';

  @override
  String get habitEdit_groupTile_title => 'Grupo';

  @override
  String get habitEdit_groupPicker_hintText => 'Serĉi aŭ krei grupon';

  @override
  String get habitEdit_groupPicker_noGroup => 'Neniu grupo';

  @override
  String habitEdit_groupPicker_createGroup(String name) {
    return 'Krei \"$name\"';
  }

  @override
  String get habitEdit_groupPicker_loading => 'Ŝargante grupojn…';

  @override
  String get groupManage_appbar_title => 'Administri grupojn';

  @override
  String groupManage_selectionAppbar_title(int count) {
    return 'Elektitaj: $count';
  }

  @override
  String get groupManage_emptyState_text =>
      'Ankoraŭ neniuj grupoj\nFrapetu + por krei vian unuan grupon';

  @override
  String get groupManage_deleteDialog_title => 'Forigi grupon';

  @override
  String groupManage_deleteDialog_content(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kutimoj en ĉi tiuj $count grupoj fariĝos nekategoriigitaj.',
      one: 'Kutimoj en ĉi tiu grupo fariĝos nekategoriigitaj.',
    );
    return '$_temp0';
  }

  @override
  String get groupManage_deleteDialog_confirm => 'Forigi';

  @override
  String get groupManage_deleteDialog_cancel => 'Nuligi';

  @override
  String get groupManage_deleted_snackbarText => 'Grupo forigita';

  @override
  String get groupManage_undo_snackbarAction => 'Malfari';

  @override
  String get groupManage_editDialog_title => 'Redakti grupon';

  @override
  String get groupManage_createButton_tooltip => 'Krei grupon';

  @override
  String get groupManage_createDialog_title => 'Krei grupon';

  @override
  String get groupManage_nameRequired => 'Nomo estas postulata';

  @override
  String groupManage_nameTooLong(int max) {
    return 'Nomo devas esti ≤ $max signoj';
  }

  @override
  String get groupManage_name_label => 'Nomo';

  @override
  String get groupManage_desc_label => 'Priskribo';

  @override
  String groupManage_descTooLong(int max) {
    return 'Priskribo devus esti ≤ $max signoj';
  }

  @override
  String get groupManage_sortTile_text => 'Ordigi grupojn';

  @override
  String get groupManage_sectionTitle_text => 'Grupoj';

  @override
  String get groupManage_createDateTile_title => 'Kreita';

  @override
  String get groupManage_modifyDateTile_title => 'Modifita';

  @override
  String get groupManage_icon_label => 'Ikono';

  @override
  String get groupManage_icon_none => 'Neniu';

  @override
  String get groupManage_color_label => 'Koloro';

  @override
  String get groupManage_color_none => 'Neniu';

  @override
  String get groupManage_reorder_tooltip => 'Reordigi grupojn';

  @override
  String get groupManage_menu_edit => 'Redakti';

  @override
  String get groupManage_menu_delete => 'Forigi';

  @override
  String get groupManage_selectAll => 'Elekti ĉiujn';

  @override
  String get groupHeader_menu_manage => 'Administri';

  @override
  String get groupHeader_menu_collapseAll => 'Faldi ĉion';

  @override
  String get groupHeader_menu_expandAll => 'Malfaldi ĉion';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Krei, redakti kaj forigi grupojn de kutimoj';

  @override
  String get habitDisplay_groupType_manual => 'Permane';

  @override
  String confirmDialog_confirmAndSkip_text(String action) {
    return '$action kaj ne plu demandi';
  }

  @override
  String get habitDisplay_groupModifyConfirm_previewTitle => 'Antaŭrigardi';

  @override
  String get appSupport_title => 'Subteni Table Habit';

  @override
  String get appSupport_message =>
      'Via subteno helpas plibonigi Table Habit kaj atingi pli da homoj.';

  @override
  String get appSupport_starOnGitHub => 'Steligi en GitHub';

  @override
  String get appSupport_rateOnGooglePlay => 'Taksi en Google Play';

  @override
  String get appSupport_rateOnAppStore => 'Taksi en la App Store';

  @override
  String get appSupport_openOnMicrosoftStore => 'Taksi en Microsoft Store';

  @override
  String get appSupport_favoriteOnFlathub => 'Ŝatmarki en Flathub';

  @override
  String get appSupport_later => 'Memorigi min poste';

  @override
  String get appSupport_never => 'Ne memorigi min denove';

  @override
  String get appSupport_linkFailed =>
      'Ne eblas plenumi ĉi tiun agon. Bonvolu provi denove.';

  @override
  String get appSupport_participateTitle => 'Kontribui al Table Habit';

  @override
  String get appSupport_participateMessage =>
      'Esplori la fontkodon, kontribui aŭ kunhavigi aferojn kaj ideojn.';

  @override
  String appSupport_page(int page, int count) {
    return 'Paĝo $page el $count';
  }

  @override
  String get appSupport_saveFailed =>
      'La memorigo ne povis esti konservita. Bonvolu provi denove.';

  @override
  String get appSetting_uiStyle_titleText => 'Stilo de interfaco';

  @override
  String get appSetting_uiStyle_automatic => 'Aŭtomata';

  @override
  String get appSetting_uiStyle_material => 'Material';

  @override
  String get appSetting_uiStyle_apple => 'Apple';

  @override
  String get appSetting_appleSidebarStyle_titleText =>
      'Aspekto de la flankbreto de Apple';

  @override
  String get appSetting_appleSidebarStyle_inset => 'Enmetita';

  @override
  String get appSetting_appleSidebarStyle_edge => 'Rando';
}
