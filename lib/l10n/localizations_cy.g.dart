// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Welsh (`cy`).
class L10nCy extends L10n {
  L10nCy([String locale = 'cy']) : super(locale);

  @override
  String get localeScriptName => 'Cymraeg';

  @override
  String get appName => 'Table Habit';

  @override
  String get common_listSeparator => ', ';

  @override
  String get habitEdit_saveButton_text => 'Cadw';

  @override
  String get habitEdit_habitName_hintText => 'Enw\'r arfer...';

  @override
  String get habitEdit_colorPicker_title => 'Dewis lliw';

  @override
  String get habitEdit_colorPicker_historySectionLabel =>
      'Defnyddiwyd yn ddiweddar';

  @override
  String habitEdit_colorPicker_customSectionLabel(String tinted) {
    String _temp0 = intl.Intl.selectLogic(tinted, {
      'true': 'Personol (arlliwiedig)',
      'false': 'Personol',
      'other': 'Personol',
    });
    return '$_temp0';
  }

  @override
  String get habitEdit_colorPicker_cancel => 'Canslo';

  @override
  String get habitEdit_colorPicker_tintToggleLabel => 'Arlliwio yn ôl y thema';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Arlliwiedig';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Heb ei arlliwio';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'Gall arlliwio symud y lliw terfynol i ffwrdd o\'r un a ddewisoch.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Gall rhai lliwiau leihau darllenadwyedd testun mewn thema ysgafn neu dywyll.';

  @override
  String get habitEdit_habitTypeDialog_title => 'Math o arfer';

  @override
  String get habitEdit_habitType_positiveText => 'Cadarnhaol';

  @override
  String get habitEdit_habitType_negativeText => 'Negyddol';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Nod dyddiol, $number rhagosodedig';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Trothwy dyddiol lleiaf, $number rhagosodedig';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'rhaid i nod dyddiol fod > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'rhaid i nod dyddiol fod ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'rhaid i nod dyddiol fod ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'rhaid i nod dyddiol fod ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Uned y nod dyddiol';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Uchafswm y nod dyddiol a ddymunir';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'gwerth annilys, rhaid iddo fod yn wag neu ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Uchafswm terfyn dyddiol';

  @override
  String get habitEdit_frequencySelector_title => 'Dewis amlder';

  @override
  String get habitEdit_habitFreq_daily => 'Dyddiol';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% gwaith yr wythnos';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% gwaith y mis';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% gwaith mewn %%day%% diwrnod';

  @override
  String get habitEdit_habitFreq_show_daily => 'Dyddiol';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'O leiaf $freq gwaith yr wythnos',
      one: 'Yr wythnos',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'O leiaf $freq gwaith y mis',
      one: 'Y mis',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'O leiaf $freq gwaith ym mhob $days diwrnod',
      one: 'Ym mhob $days diwrnod',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays diwrnod';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Dewis diwrnodau targed';

  @override
  String get habitEdit_targetDays => 'diwrnod';

  @override
  String get habitEdit_reminder_hintText => 'Nodyn atgoffa';

  @override
  String get habitEdit_reminder_freq_weekHelpText =>
      'Unrhyw ddiwrnod o\'r wythnos';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days ym mhob wythnos';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText =>
      'Unrhyw ddiwrnod o\'r mis';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days ym mhob mis';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Cwestiwn, e.e. Wnest ti ymarfer corff heddiw?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Dewis math o nodyn atgoffa';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Pan fydd angen cofnodi';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Dyddiol';

  @override
  String get habitEdit_reminder_dialogType_week => 'Yr wythnos';

  @override
  String get habitEdit_reminder_dialogType_month => 'Y mis';

  @override
  String get habitEdit_reminder_dialogConfirm => 'cadarnhau';

  @override
  String get habitEdit_reminder_dialogCancel => 'canslo';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Cadarnhau';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Dileu\'r nodyn atgoffa hwn?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'cadarnhau';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'canslo';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Llu';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Maw';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Mer';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Iau';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Gwe';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sad';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Sul';

  @override
  String get habitEdit_desc_hintText => 'Nodyn, yn cefnogi Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Wedi\'i greu: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Wedi\'i addasu: ';

  @override
  String get habitDisplay_fab_text => 'Arfer newydd';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'Mae taith o fil o filltiroedd yn dechrau gydag un cam';

  @override
  String get habitDisplay_notFoundImage_text_01 =>
      'Ni chanfuwyd unrhyw arferion cyfatebol';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'Dim arferion cyfatebol ar gyfer \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Archifo\'r arferion a ddewiswyd?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'cadarnhau';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'canslo';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Wedi archifo $count arfer';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Dad-archifo\'r arferion a ddewiswyd?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'cadarnhau';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'canslo';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Wedi dad-archifo $count arfer';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Dileu\'r arferion a ddewiswyd?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'cadarnhau';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'canslo';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Wedi dileu $count arfer';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Arfer wedi\'i ddileu: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arfer wedi\'u hallforio.',
      one: 'Arfer wedi\'i allforio.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Wedi allforio pob arfer';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Dewis y cyfan';

  @override
  String get habitDisplay_selectButton_label => 'Dewis';

  @override
  String get habitDisplay_doneButton_label => 'Gorffen';

  @override
  String habitDisplay_selectedHabits_title(int count) {
    return 'Wedi dewis $count';
  }

  @override
  String get habitDisplay_editPopMenu_export => 'Allforio';

  @override
  String get habitDisplay_editPopMenu_delete => 'Dileu';

  @override
  String get habitDisplay_editPopMenu_clone => 'Templed';

  @override
  String get habitDisplay_editButton_tooltip => 'Golygu';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archifo';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Dad-archifo';

  @override
  String get habitDisplay_settingButton_tooltip => 'Gosodiad';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Cyfredol';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Wedi\'u cwblhau';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Ar waith';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Wedi\'u harchifo';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Arferion gorau: newidiadau\'r 30 diwrnod diwethaf';

  @override
  String get habitDisplay_statisticsAction_label => 'Ystadegau';

  @override
  String get habitDisplay_displayFilterAction_label => 'Hidlydd dangos';

  @override
  String get habitDisplay_displayFilter_inProgress => 'Ar waith';

  @override
  String get habitDisplay_displayFilter_archived => 'Wedi\'u harchifo';

  @override
  String get habitDisplay_displayFilter_completed => 'Wedi\'u cwblhau';

  @override
  String get common_appThemeMode_light => 'Ysgafn';

  @override
  String get common_appThemeMode_dark => 'Tywyll';

  @override
  String get common_appThemeMode_followSystem => 'Awtomatig';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Dangos arferion wedi\'u harchifo';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'Dangos arferion wedi\'u cwblhau';

  @override
  String get habitDisplay_mainMenu_showActivedTileText =>
      'Dangos arferion ar waith';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Gosodiadau';

  @override
  String get habitDisplay_groupType_name => 'Yn ôl enw';

  @override
  String get habitDisplay_groupType_colorType => 'Yn ôl lliw';

  @override
  String get habitDisplay_groupType_createDate => 'Yn ôl dyddiad creu';

  @override
  String get habitDisplay_groupType_habitCount => 'Yn ôl nifer yr arferion';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Trefnu grwpiau';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'cadarnhau';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'canslo';

  @override
  String get habitDisplay_groupTypeDialog_none => 'Heb grwpio';

  @override
  String get habitDisplay_editPopMenu_groupModify => 'Addasu grŵp';

  @override
  String get habitDisplay_groupModifyDialog_title => 'Addasu grŵp';

  @override
  String get habitDisplay_groupModifyDialog_removeGroup => 'Tynnu o\'r grŵp';

  @override
  String get habitDisplay_groupModifyDialog_emptyGroups =>
      'Dim grwpiau ar gael';

  @override
  String get habitDisplay_groupModifyDialog_alreadyInGroup =>
      'Mae\'r arferion a ddewiswyd eisoes yn y grŵp hwn';

  @override
  String get habitDisplay_groupModifyDialog_createGroup => 'Creu grŵp';

  @override
  String get habitDisplay_groupModifyDialog_saveAndApply => 'Cadw a gweithredu';

  @override
  String get habitDisplay_groupModifyConfirm_titleNew => 'Symud i grŵp';

  @override
  String get habitDisplay_groupModifyConfirm_titleMixed =>
      'Cadarnhau newid grŵp';

  @override
  String habitDisplay_groupModifyConfirm_bodyNewGroup(String groupName) {
    return 'Bydd arferion $groupName yn cael eu symud i\'r grŵp hwn';
  }

  @override
  String get habitDisplay_groupModifyConfirm_bodyRemoveGroup =>
      'Bydd yr arferion yn cael eu tynnu o\'u grŵp';

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
      other: ' a $remainingGroupCount grŵp arall ($totalGroupCount grŵp i gyd)',
      one: ' ac 1 grŵp arall ($totalGroupCount grŵp i gyd)',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      remainingGroupCount,
      locale: localeName,
      other: ' a $remainingGroupCount grŵp arall ($totalGroupCount grŵp i gyd)',
      one: ' ac 1 grŵp arall ($totalGroupCount grŵp i gyd)',
      zero: '',
    );
    String _temp2 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Bydd $count arfer yn symud o \"$fromGroup\"$_temp0 i \"$toGroup\"',
      one: 'Bydd $count arfer yn symud o \"$fromGroup\"$_temp1 i \"$toGroup\"',
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
      other:
          'Bydd $count arfer heb gategori yn cael eu hychwanegu at \"$toGroup\"',
      one:
          'Bydd $count arfer heb gategori yn cael ei ychwanegu at \"$toGroup\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyRemoveStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bydd grwpiau $count arfer yn cael eu tynnu',
      one: 'Bydd grŵp $count arfer yn cael ei dynnu',
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
      other: 'Wedi symud $count arfer i \"$groupName\"',
      one: 'Wedi symud yr arfer i \"$groupName\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModify_snackbarTextRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wedi tynnu grwpiau o $count arfer',
      one: 'Wedi tynnu\'r grŵp o\'r arfer',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_groupModify_undoFailed =>
      'Mae\'r grŵp wedi\'i addasu yn rhywle arall, ni ellir dadwneud';

  @override
  String get habitDisplay_sort_reverseText => 'Gwrthdroi';

  @override
  String get habitDisplay_sortDirection_asc => '(esgynnol)';

  @override
  String get habitDisplay_sortDirection_Desc => '(disgynnol)';

  @override
  String get habitDisplay_sortType_manual => 'Fy nhrefn';

  @override
  String get habitDisplay_sortType_name => 'Yn ôl enw';

  @override
  String get habitDisplay_sortType_colorType => 'Yn ôl lliw';

  @override
  String get habitDisplay_sortType_progress => 'Yn ôl cyfradd llwyddiant';

  @override
  String get habitDisplay_sortType_startT => 'Yn ôl dyddiad dechrau';

  @override
  String get habitDisplay_sortType_status => 'Yn ôl statws';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Trefnu';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'cadarnhau';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'canslo';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Dadfygio';

  @override
  String get habitDisplay_searchBar_hintText => 'Chwilio arferion';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Ar waith';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Yn dangos arferion sy\'n weithredol ac yn barhaus ar hyn o bryd (heb eu harchifo na\'u dileu).';

  @override
  String get habitDisplay_searchFilter_completed => 'Wedi\'u cwblhau';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Math o arfer';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Dangos yr hidlyddion';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clirio\'r hidlyddion';

  @override
  String get habitDisplay_tab_habits_label => 'Arferion';

  @override
  String get habitDisplay_tab_today_label => 'Heddiw';

  @override
  String get habitToday_appBar_title => 'Heddiw';

  @override
  String get habitToday_image_desc => 'LLWYDDIANT!';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Wedi dal ati am $days diwrnod';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Cwblhau+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Hepgor+';

  @override
  String get habitDetail_editButton_tooltip => 'Golygu';

  @override
  String get habitDetail_recordCalendar_label => 'Cofnodi';

  @override
  String get habitDetail_recordCalendar_tooltip => 'Agor calendr cofnodi';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Dad-archifo';

  @override
  String get habitDetail_editPopMenu_archive => 'Archifo';

  @override
  String get habitDetail_editPopMenu_export => 'Allforio';

  @override
  String get habitDetail_editPopMenu_delete => 'Dileu';

  @override
  String get habitDetail_editPopMenu_clone => 'Templed';

  @override
  String get habitDetail_confirmDialog_confirm => 'cadarnhau';

  @override
  String get habitDetail_confirmDialog_cancel => 'canslo';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Archifo\'r arfer?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Dad-archifo\'r arfer?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Dileu\'r arfer?';

  @override
  String get habitDetail_summary_title => 'Crynodeb';

  @override
  String habitDetail_summary_body(String score, int days) {
    return '$score yw\'r radd gyfredol, ac mae $days diwrnod wedi mynd heibio ers y dechrau.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Yn dechrau ymhen $days diwrnod.',
      one: 'Yn dechrau yfory.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'IS-SAFONOL',
      one: 'ANGHYFLAWN',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'PERFFAITH',
      one: 'WEDI RHAGORI',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Nod',
      two: 'Trothwy',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Uned: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Diwrnodau',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'd';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Cofnodion';

  @override
  String get habitDetail_scoreChart_title => 'Sgôr';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Diwrnod';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Wythnos';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Mis';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Blwyddyn';

  @override
  String get habitDetail_freqChart_freqTitle => 'Amlder';

  @override
  String get habitDetail_freqChart_historyTitle => 'Hanes';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Amlder a hanes';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Wythnos';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Mis';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Blwyddyn';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Nawr';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Cuddio siart hanes';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Dangos siart hanes';

  @override
  String get habitDetail_descSubgroup_title => 'Nodyn';

  @override
  String get habitDetail_otherSubgroup_title => 'Arall';

  @override
  String get habitDetail_habitType_title => 'Math';

  @override
  String get habitDetail_reminderTile_title => 'Nodyn atgoffa';

  @override
  String get habitDetail_freqTile_title => 'Ailadrodd';

  @override
  String get habitDetail_startDateTile_title => 'Dyddiad dechrau';

  @override
  String get habitDetail_createDateTile_title => 'Wedi\'i greu';

  @override
  String get habitDetail_modifyDateTile_title => 'Wedi\'i addasu';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'dyddiad';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'gwerth';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'yn ôl i heddiw';

  @override
  String get common_loadError_text => 'Methodd llwytho';

  @override
  String get common_loadError_retryText => 'Ceisio eto';

  @override
  String get habitDetail_notFoundText => 'Methodd llwytho\'r arfer';

  @override
  String get habitDetail_notFoundRetryText => 'Ceisio eto';

  @override
  String get habitDetail_changeGoal_title => 'Newid nod';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'cyfredol: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'wedi\'i gwblhau: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'heb ei wneud';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Nod dyddiol, rhagosodiad: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'canslo';

  @override
  String get habitDetail_changeGoal_saveText => 'cadw';

  @override
  String get habitDetail_skipReason_title => 'Rheswm dros hepgor';

  @override
  String get habitDetail_skipReason_bodyHelpText =>
      'Ysgrifennwch rywbeth yma...';

  @override
  String get habitDetail_skipReason_cancelText => 'canslo';

  @override
  String get habitDetail_skipReason_saveText => 'cadw';

  @override
  String get appSetting_appbar_titleText => 'Gosodiadau';

  @override
  String get appSetting_displaySubgroupText => 'Golwg';

  @override
  String get appSetting_operationSubgroupText => 'Gweithrediad';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Llusgo\'r calendr fesul tudalen';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Os yw\'r switsh wedi\'i alluogi, bydd y calendr ym mar yr ap ar y dudalen gartref yn cael ei lusgo fesul tudalen. Yn ddiofyn, mae\'r switsh wedi\'i analluogi.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Newid statws cofnod';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Addasu\'r ymddygiad clicio i newid statws cofnodion dyddiol ar y brif dudalen.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Agor cofnod manwl';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Addasu\'r ymddygiad clicio i agor y naidlen fanwl ar gyfer cofnodion dyddiol ar y brif dudalen.';

  @override
  String get appSetting_expandTimerDelayTile_titleText =>
      'Oedi cyn ehangu grŵp';

  @override
  String get appSetting_expandTimerDelayTile_subtitleText =>
      'Gosod pa mor hir i hofran dros bennawd grŵp sydd wedi\'i blygu cyn iddo ehangu\'n awtomatig wrth lusgo a gollwng.';

  @override
  String get appSetting_expandTimerDelay_default => 'Rhagosodedig';

  @override
  String get appSetting_expandTimerDelay_fast => 'Cyflym';

  @override
  String get appSetting_expandTimerDelay_slow => 'Araf';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Lliw\'r thema';

  @override
  String get appSetting_appThemeModeTile_titleText => 'Modd y thema';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'Dewis lliw\'r thema';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Defnyddio prif liw\'r papur wal (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'Defnyddio lliw cefndir a ddewiswyd yn thema GTK+';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Defnyddio lliw thema\'r system';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Defnyddio lliw acen y system neu liw ffenestr/gwydr';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Diwrnod cyntaf yr wythnos';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Dangos diwrnod cyntaf yr wythnos';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Rhagosodedig)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Dilyn y system ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Dilyn y system';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Iaith';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Dewis iaith';

  @override
  String appSetting_changeLanguageDialog_currentLanguage_text(
    String localeName,
  ) {
    return 'Iaith bresennol: $localeName';
  }

  @override
  String get appSetting_languageSubgroupText => 'Iaith';

  @override
  String get appSetting_openSystemLanguageTile_titleText =>
      'Gosodiadau iaith y system';

  @override
  String get appSetting_openSystemLanguageTile_dialogTitle =>
      'Agor gosodiadau iaith y system';

  @override
  String get appSetting_openSystemLanguageTile_macosDialogContent =>
      'Oherwydd cyfyngiadau macOS, ni ellir newid iaith yr ap yn uniongyrchol. I newid yr iaith, dilynwch y camau hyn:\n\n1. Agorwch **System Settings > General > Language & Region**\n2. Ychwanegwch yr ap hwn yn y rhestr **Applications** a dewiswch iaith';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Fformat dangos dyddiad ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'dilyn gosodiad system';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Bydd fformat dyddiad wedi\'i ffurfweddu yn cael ei gymhwyso i\'r dyddiad a ddangosir ar dudalen manylion arfer.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Galluogi rhyngwyneb cryno ar dudalen yr arferion';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Caniatáu i dabl cofnodi arferion arddangos mwy o gynnwys, ond gall rhai o elfennau\'r rhyngwyneb a thestun ymddangos yn llai.';

  @override
  String get appSetting_appleCollapsedSidebarSwitcher_titleText =>
      'Dangos bar ochr llorweddol';

  @override
  String get appSetting_appleCollapsedSidebarSwitcher_subtitleText =>
      'Dangos cyrchfannau llywio yn y bar uchaf tra bod y bar ochr wedi\'i guddio.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Maint yr ardal cofnodi';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Addasu\'r ganran ar gyfer mwy/llai o le yn ardal y tabl cofnodi arferion.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText =>
      'Rhagosodedig';

  @override
  String get appSetting_reminderSubgroupText =>
      'Nodiadau atgoffa a hysbysiadau';

  @override
  String get appSetting_dailyReminder_titleText => 'Nodyn atgoffa dyddiol';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Gwneud copi wrth gefn ac adfer';

  @override
  String get appSetting_export_titleText => 'Allforio';

  @override
  String get appSetting_export_subtitleText =>
      'Yn allforio arferion mewn fformat JSON. Gellir mewnforio\'r ffeil hon eto.';

  @override
  String get appSetting_import_titleText => 'Mewnforio';

  @override
  String get appSetting_import_subtitleText =>
      'Mewnforio arferion o ffeil JSON.';

  @override
  String get appSetting_thirdPartyImport_titleText =>
      'Mewnforio o drydydd parti';

  @override
  String get appSetting_thirdPartyImport_subtitleText =>
      'Mewnforio arferion o apiau olrhain arferion eraill';

  @override
  String get appSetting_thirdPartyImport_provider_loopName =>
      'Loop Habit Tracker';

  @override
  String get appSetting_thirdPartyImport_provider_versionHint =>
      'Yn cefnogi CSV (wedi\'i brofi hyd at <ver/>)';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Cadarnhau mewnforio $count arfer?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Nodyn: Nid yw mewnforio yn dileu arferion presennol.';

  @override
  String get appSetting_importDialog_option_includeHabits => 'Cynnwys arferion';

  @override
  String get appSetting_importDialog_option_includeGroups => 'Cynnwys grwpiau';

  @override
  String appSetting_importDialog_tile_includeHabits(int count) {
    return 'Cynnwys $count arfer';
  }

  @override
  String appSetting_importDialog_tile_includeGroups(int count) {
    return 'Cynnwys $count grŵp';
  }

  @override
  String appSetting_importConfirmDialog_sourceLabel(String provider) {
    return 'Ffynhonnell: $provider';
  }

  @override
  String get appSetting_thirdPartyImport_error_fileReadError =>
      'Methodd darllen y ffeil a ddewiswyd.';

  @override
  String get appSetting_thirdPartyImport_error_noHabitsFound =>
      'Ni chanfuwyd unrhyw arferion yn y ffeil mewnforio.';

  @override
  String get appSetting_thirdPartyImport_error_parseError =>
      'Methodd dosrannu\'r ffeil mewnforio';

  @override
  String get appSetting_thirdPartyImport_error_unknown =>
      'Digwyddodd gwall annisgwyl wrth fewnforio.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'cadarnhau';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'canslo';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'Wedi mewnforio $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Arferion wedi\'u mewnforio: $count';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Grwpiau wedi\'u mewnforio: $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'cau';

  @override
  String get appSetting_resetConfig_titleText => 'Ailosod ffurfweddiadau';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Ailosod yr holl ffurfweddiadau i\'r rhagosodiadau.';

  @override
  String get appSetting_resetConfigDialog_titleText =>
      'Ailosod ffurfweddiadau?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Ailosod yr holl ffurfweddiadau i\'r rhagosodiadau; rhaid ailgychwyn yr ap i\'w rhoi ar waith.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'canslo';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'cadarnhau';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'Wedi ailosod gosodiadau\'r ap';

  @override
  String get appSetting_otherSubgroupText => 'Eraill';

  @override
  String get appSetting_developMode_titleText => 'Modd datblygwr';

  @override
  String get appSetting_clearCache_titleText => 'Clirio\'r storfa';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Clirio\'r storfa';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Ar ôl clirio\'r storfa, bydd rhai gwerthoedd personol yn dychwelyd i\'r rhagosodiadau.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'canslo';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'cadarnhau';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Methodd clirio\'r storfa yn rhannol';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Wedi llwyddo i glirio\'r storfa';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Methodd clirio\'r storfa';

  @override
  String get appSetting_debugger_titleText => 'Gwybodaeth ddadfygio';

  @override
  String get appSetting_about_titleText => 'Ynghylch';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Nodweddion arbrofol';

  @override
  String get appSetting_synSubgroupText => 'Cysoni';

  @override
  String get appSetting_syncOption_titleText => 'Opsiynau cysoni';

  @override
  String get appSetting_notify_titleTile => 'Hysbysiadau';

  @override
  String get appSetting_notify_subtitleTile => 'Rheoli dewisiadau hysbysu';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Tapiwch i agor gosodiadau hysbysu\'r system';

  @override
  String get appSync_nowTile_titleText => 'Cysoni nawr';

  @override
  String get appSync_nowTile_titleText_syncing => 'Yn cysoni';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'Cysoni diwethaf: dim eto';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Cysoni diwethaf: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Cysoni diwethaf (gwall): dim eto';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Cysoni diwethaf (gwall): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Yn cysoni...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Yn cysoni: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Yn canslo...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Cysoni diwethaf (wedi\'i ganslo): dim eto';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Cysoni diwethaf (wedi\'i ganslo): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Gwirio logiau methiant';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Gwall]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Wedi\'i gwblhau',
      'cancelled': 'Wedi\'i ganslo',
      'failed': 'Wedi methu',
      'multi': 'Sawl statws',
      'other': 'Statws anhysbys',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Wedi\'i gwblhau oherwydd $reason',
      'cancelled': 'Wedi\'i ganslo oherwydd $reason',
      'failed': 'Wedi methu oherwydd $reason',
      'multi': 'Sawl statws oherwydd $reason',
      'other': 'Statws anhysbys',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Gwall',
      'userAction': 'Angen gweithred defnyddiwr',
      'missingHabitUuid': 'UUID arfer ar goll',
      'empty': 'Data gwag',
      'other': 'Rheswm anhysbys',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText =>
      'Lleoliad newydd';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Bydd cysoni yn creu cyfeiriaduron angenrheidiol ac yn uwchlwytho arferion lleol i\'r gweinydd. Parhau?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Cysoni nawr!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Cadarnhau cysoni';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Nid yw\'r cyfeiriadur yn wag. Bydd cysoni yn uno arferion y gweinydd a\'r rhai lleol. Parhau?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Cadarnhau cyfuno';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Allforio logiau cysoni a fethodd';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'Dim log wedi\'i ganfod',
      'false': 'Tapiwch i allforio',
      'other': 'wrthi\'n llwytho...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Presennol: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Ffug (dim ond ar gyfer dadfygiwr)',
      'other': 'Anhysbys ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Data symudol',
      'wifi': 'Wifi',
      'other': 'Anhysbys',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Â llaw',
      'minute5': '5 munud',
      'minute15': '15 munud',
      'minute30': '30 munud',
      'hour1': '1 awr',
      'other': 'Anhysbys',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Cyfwng cysoni';

  @override
  String get appSync_summaryTile_title => 'Gweinydd cysoni';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Heb ei ffurfweddu';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Pob log cysoni a fethodd yn ddiweddar';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Cadarnhau cadw newidiadau';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Bydd cadw yn trosysgrifennu ffurfweddiad blaenorol y gweinydd.';

  @override
  String get appSync_serverEditor_exitDialog_titleText =>
      'Newidiadau heb eu cadw';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Bydd gadael yn gwaredu pob newid heb ei gadw.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Cadarnhau dileu';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Bydd hyn yn dileu ffurfweddiad cyfredol y gweinydd.';

  @override
  String get appSync_serverEditor_titleText_add => 'Gweinydd cysoni newydd';

  @override
  String get appSync_serverEditor_titleText_modify => 'Addasu gweinydd cysoni';

  @override
  String get appSync_serverEditor_advance_titleText => 'Ffurfweddiadau uwch';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Llwybr';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Rhowch lwybr WebDAV dilys yma.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Ni ddylai\'r llwybr fod yn wag!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Enw defnyddiwr';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Rhowch enw defnyddiwr yma, gadewch yn wag os nad oes ei angen.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Cyfrinair';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Anwybyddu tystysgrif SSL';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Terfyn amser cysoni (eiliadau)';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'anfeidraidd',
    );
    return 'Rhagosodedig: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Terfyn amser cysylltiad rhwydwaith (eiliadau)';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'anfeidraidd',
    );
    return 'Rhagosodedig: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Nifer yr ailgynigion cysylltiad rhwydwaith';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Ailgynnig wedi\'i analluogi',
    );
    return 'Rhagosodedig: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Modd cysoni rhwydwaith';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Cysoni ar ddata symudol',
      'wifi': 'Cysoni ar Wifi',
      'other': 'Anhysbys',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'LowData';

  @override
  String get appSync_noti_readyToSync_body => 'Yn paratoi i gysoni...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Wedi cysoni ($type)',
      'failed': 'Methodd cysoni ($type)',
      'other': 'Yn cysoni ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Cysoni yn y modd data isel';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Mae un neu fwy o nodweddion arbrofol wedi\'u galluogi. Defnyddiwch yn ofalus.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Cysoni arferion yn y cwmwl';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Unwaith y bydd wedi\'i alluogi, bydd opsiwn cysoni\'r ap yn ymddangos yn y gosodiadau';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Mae nodwedd arbrofol ($syncName) wedi\'i hanalluogi, ond mae\'r swyddogaeth yn dal i redeg.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'I analluogi\'n llwyr, pwyswch yn hir i gael mynediad i \'$menuName\' a\'i ddiffodd.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText =>
      'Chwilio arferion';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Unwaith y bydd wedi\'i alluogi, bydd bar chwilio yn ymddangos ar frig y sgrin Arferion ac yn gadael i chi chwilio arferion.';

  @override
  String get appAbout_appbarTile_titleText => 'Ynghylch';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Fersiwn: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Cod ffynhonnell';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Traciwr problemau';

  @override
  String get appAbout_contactEmailTile_titleText => 'Cysylltu â mi';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Helo, rwy\'n falch eich bod wedi cysylltu â mi.\nOs ydych chi\'n riportio nam, nodwch fersiwn yr ap a disgrifiwch y camau i\'w atgynhyrchu.\n-----------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Trwydded';

  @override
  String get appAbout_licenseTile_subtitleText =>
      'Trwydded Apache, fersiwn 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Datganiad trwyddedu trydydd parti';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Preifatrwydd';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Gweld y polisi preifatrwydd yn yr ap hwn';

  @override
  String get appAbout_donateTile_titleText => 'Rhoi rhodd';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Rwy\'n ddatblygwr annibynnol. Os ydych chi\'n hoffi\'r ap hwn, prynwch ☕ i mi.';

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
  String get donateWay_cryptoCurrency => 'Arian cripto';

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
    return 'Copïwyd cyfeiriad $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Cofnodi swmp';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip =>
      'Y diwrnod blaenorol';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Y diwrnod nesaf';

  @override
  String get batchCheckin_status_skip_text => 'Hepgor';

  @override
  String get batchCheckin_status_ok_text => 'Cwblhau';

  @override
  String get batchCheckin_status_double_text => 'Taro x2!';

  @override
  String get batchCheckin_status_zero_text => 'Heb ei gwblhau';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'arfer',
      one: 'arfer',
    );
    return 'Dewiswyd $count $_temp0';
  }

  @override
  String get batchCheckin_save_button_text => 'Cadw';

  @override
  String get batchCheckin_reset_button_text => 'Ailosod';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arfer',
      one: 'arfer',
    );
    return 'Newidiwyd statws $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title =>
      'Trosysgrifo cofnodion presennol';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Bydd cadw yn trosysgrifo\'r cofnodion presennol ar gyfer y diwrnod a ddewiswyd.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'cadw';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'canslo';

  @override
  String habitRecord_delete_buttonText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cofnodion',
      one: 'cofnod',
    );
    return 'Dileu $_temp0';
  }

  @override
  String habitRecord_deleteConfirmDialog_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cofnod?',
      one: 'cofnod?',
    );
    return 'Dileu $_temp0';
  }

  @override
  String get batchCheckin_close_confirmDialog_title => 'Cadarnhau mynd yn ôl';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Bydd newidiadau cofnodi heb eu cadw yn cael eu colli os byddwch yn gadael.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'gadael';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'canslo';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 A wnaethoch chi gadw at eich arferion heddiw?';

  @override
  String get appReminder_dailyReminder_body =>
      'Tapiwch i agor yr ap a chofnodi.';

  @override
  String get common_habitColorType_cc1 => 'Lila dwfn';

  @override
  String get common_habitColorType_cc2 => 'Coch';

  @override
  String get common_habitColorType_cc3 => 'Porffor';

  @override
  String get common_habitColorType_cc4 => 'Glas brenhinol';

  @override
  String get common_habitColorType_cc5 => 'Cyan tywyll';

  @override
  String get common_habitColorType_cc6 => 'Gwyrdd';

  @override
  String get common_habitColorType_cc7 => 'Ambr';

  @override
  String get common_habitColorType_cc8 => 'Oren';

  @override
  String get common_habitColorType_cc9 => 'Gwyrdd leim';

  @override
  String get common_habitColorType_cc10 => 'Orchid tywyll';

  @override
  String get common_habitColorType_custom => 'Personol';

  @override
  String common_habitColorType_default(int index) {
    return 'Lliw $index';
  }

  @override
  String get common_appThemeColor_system => 'System';

  @override
  String get common_appThemeColor_primary => 'Prif liw';

  @override
  String get common_appThemeColor_dynamic => 'Dynamig';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Defnyddio fformat y system';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Fformat dyddiad';

  @override
  String get common_customDateTimeFormatPicker_ymd_text =>
      'Blwyddyn mis diwrnod';

  @override
  String get common_customDateTimeFormatPicker_mdy_text =>
      'Mis diwrnod blwyddyn';

  @override
  String get common_customDateTimeFormatPicker_dmy_text =>
      'Diwrnod mis blwyddyn';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Gwahanydd';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Cysylltnod';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Llinell oledd';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Bwlch';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Dot';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Dim gwahanydd';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Defnyddio fformat 12 awr';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Defnyddio enw llawn';

  @override
  String get appDateFormat_leadingZero_text => 'Defnyddio seroau ar y dechrau';

  @override
  String get appDateFormat_preview_text => 'Rhagolwg';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Cymhwyso i\'r siart amlder';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Cymhwyso i\'r calendr';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'canslo';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text =>
      'cadarnhau';

  @override
  String get common_errorPage_title => 'Wps, chwalodd yr ap!';

  @override
  String get common_errorPage_copied => 'Copïwyd gwybodaeth am y chwalfa';

  @override
  String get common_enable_text => 'Wedi\'i alluogi';

  @override
  String get common_dontShowAgain => 'Peidio â dangos eto';

  @override
  String get calendarPicker_clip_today => 'Heddiw';

  @override
  String get calendarPicker_clip_tomorrow => 'Yfory';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString nesaf';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'Allforio\'r holl arferion?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number arfer',
      one: '1 arfer',
      zero: 'yr arfer presennol',
    );
    return 'Allforio $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'cynnwys cofnodion';

  @override
  String get exportConfirmDialog_option_includeGroups => 'cynnwys grwpiau';

  @override
  String exportConfirmDialog_tile_includeRecords(int count) {
    return 'Cynnwys $count cofnod';
  }

  @override
  String exportConfirmDialog_tile_includeGroups(int count) {
    return 'Cynnwys $count grŵp';
  }

  @override
  String get exportConfirmDialog_cancel_buttonText => 'canslo';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'allforio';

  @override
  String get debug_logLevelTile_title => 'Lefel logiau';

  @override
  String get debug_logLevelDialog_title => 'Newid lefel logiau';

  @override
  String get debug_logLevel_debug => 'Dadfygio';

  @override
  String get debug_logLevel_info => 'Gwybodaeth';

  @override
  String get debug_logLevel_warn => 'Rhybudd';

  @override
  String get debug_logLevel_error => 'Gwall';

  @override
  String get debug_logLevel_fatal => 'Angheuol';

  @override
  String get debug_collectLogTile_title => 'Casglu logiau';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Tapio i atal casglu logiau.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Tapio i ddechrau casglu logiau.';

  @override
  String get debug_downladDebugLogs_subject => 'Lawrlwytho logiau dadfygio';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Cliriwyd y logiau dadfygio.';

  @override
  String get debug_downladDebugInfo_subject =>
      'Lawrlwytho gwybodaeth ddadfygio';

  @override
  String get debug_shareDebugZip_tooltip => 'Rhannu pecyn dadfygio';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Lawrlwytho $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Nid yw\'r log dadfygio yn bodoli.';

  @override
  String get debug_debuggerLogCard_title => 'Gwybodaeth logio';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Yn cynnwys gwybodaeth log dadfygio lleol; mae angen troi\'r switsh casglu logiau ymlaen.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Lawrlwytho';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Clirio';

  @override
  String get debug_debuggerInfoCard_title => 'Gwybodaeth ddadfygio';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Yn cynnwys gwybodaeth ddadfygio\'r ap.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Agor';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Cadw';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Casglu gwybodaeth yr ap...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Cadw',
      'exit': 'Gadael',
      'delete': 'Dileu',
      'other': 'Cadarnhau',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'Canslo';

  @override
  String get snackbar_undoText => 'DADWNEUD';

  @override
  String get snackbar_dismissText => 'CAU';

  @override
  String get contributors_tile_title => 'Cyfranwyr';

  @override
  String get userAction_tap => 'Tapio';

  @override
  String get userAction_doubleTap => 'Tapio dwbl';

  @override
  String get userAction_longTap => 'Tapio hir';

  @override
  String get channelName_habitReminder => 'Nodyn atgoffa arferion';

  @override
  String get channelName_appReminder => 'Anogwr';

  @override
  String get channelName_appDebugger => 'Dadfygiwr';

  @override
  String get channelName_appSyncing => 'Proses cysoni';

  @override
  String get channelDesc_appSyncing =>
      'Defnyddir i ddangos cynnydd cysoni a chanlyniadau nad ydynt yn fethiannau';

  @override
  String get channelName_appSyncFailed => 'Methu cysoni';

  @override
  String get channelDesc_appSyncFailed =>
      'Defnyddir i rybuddio pan fydd cysoni yn methu';

  @override
  String changelog_banner_title(String version) {
    return 'Beth sy\'n newydd yn fersiwn $version';
  }

  @override
  String get changelog_banner_action => 'CAU';

  @override
  String get changelog_banner_view => 'GWELD';

  @override
  String get changelog_dialog_title => 'Log newidiadau';

  @override
  String get changelog_view_full => 'Gweld y log newidiadau llawn';

  @override
  String get habitGroup_uncategorized => 'Dim grŵp';

  @override
  String get habitDetail_groupTile_title => 'Grŵp';

  @override
  String get habitEdit_groupTile_title => 'Grŵp';

  @override
  String get habitEdit_groupPicker_hintText => 'Chwilio am neu greu grŵp';

  @override
  String get habitEdit_groupPicker_noGroup => 'Dim grŵp';

  @override
  String habitEdit_groupPicker_createGroup(String name) {
    return 'Creu \"$name\"';
  }

  @override
  String get habitEdit_groupPicker_loading => 'Wrthi\'n llwytho grwpiau…';

  @override
  String get groupManage_appbar_title => 'Rheoli grwpiau';

  @override
  String groupManage_selectionAppbar_title(int count) {
    return '$count wedi\'u dewis';
  }

  @override
  String get groupManage_emptyState_text =>
      'Dim grwpiau eto\nTapio + i greu eich grŵp cyntaf';

  @override
  String get groupManage_deleteDialog_title => 'Dileu grŵp';

  @override
  String groupManage_deleteDialog_content(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bydd arferion yn y $count grŵp hyn yn dod yn rhai heb gategori.',
      one: 'Bydd arferion yn y grŵp hwn yn dod yn rhai heb gategori.',
    );
    return '$_temp0';
  }

  @override
  String get groupManage_deleteDialog_confirm => 'Dileu';

  @override
  String get groupManage_deleteDialog_cancel => 'Canslo';

  @override
  String get groupManage_deleted_snackbarText => 'Grŵp wedi\'i ddileu';

  @override
  String get groupManage_undo_snackbarAction => 'Dadwneud';

  @override
  String get groupManage_editDialog_title => 'Golygu grŵp';

  @override
  String get groupManage_createButton_tooltip => 'Creu grŵp';

  @override
  String get groupManage_createDialog_title => 'Creu grŵp';

  @override
  String get groupManage_nameRequired => 'Mae angen enw';

  @override
  String groupManage_nameTooLong(int max) {
    return 'Rhaid i\'r enw fod yn $max nod neu lai';
  }

  @override
  String get groupManage_name_label => 'Enw';

  @override
  String get groupManage_desc_label => 'Disgrifiad';

  @override
  String groupManage_descTooLong(int max) {
    return 'Dylai\'r disgrifiad fod yn $max nod neu lai';
  }

  @override
  String get groupManage_sortTile_text => 'Trefnu grwpiau';

  @override
  String get groupManage_sectionTitle_text => 'Grwpiau';

  @override
  String get groupManage_createDateTile_title => 'Wedi\'i greu';

  @override
  String get groupManage_modifyDateTile_title => 'Wedi\'i addasu';

  @override
  String get groupManage_icon_label => 'Eicon';

  @override
  String get groupManage_icon_none => 'Dim';

  @override
  String get groupManage_color_label => 'Lliw';

  @override
  String get groupManage_color_none => 'Dim';

  @override
  String get groupManage_reorder_tooltip => 'Aildrefnu grwpiau';

  @override
  String get groupManage_menu_edit => 'Golygu';

  @override
  String get groupManage_menu_delete => 'Dileu';

  @override
  String get groupManage_selectAll => 'Dewis popeth';

  @override
  String get groupHeader_menu_manage => 'Rheoli';

  @override
  String get groupHeader_menu_collapseAll => 'Plygu popeth';

  @override
  String get groupHeader_menu_expandAll => 'Ehangu popeth';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Creu, golygu, a dileu grwpiau arferion';

  @override
  String get habitDisplay_groupType_manual => 'Â llaw';

  @override
  String confirmDialog_confirmAndSkip_text(String action) {
    return '$action, a pheidio â gofyn eto';
  }

  @override
  String get habitDisplay_groupModifyConfirm_previewTitle => 'Rhagolwg';

  @override
  String get appSupport_title => 'Cefnogi Table Habit';

  @override
  String get appSupport_message =>
      'Mae eich cefnogaeth yn helpu i wella Table Habit a chyrraedd mwy o bobl.';

  @override
  String get appSupport_starOnGitHub => 'Rhoi seren ar GitHub';

  @override
  String get appSupport_rateOnGooglePlay => 'Graddio ar Google Play';

  @override
  String get appSupport_rateOnAppStore => 'Graddio ar yr App Store';

  @override
  String get appSupport_openOnMicrosoftStore => 'Graddio ar Microsoft Store';

  @override
  String get appSupport_favoriteOnFlathub => 'Hoffi ar Flathub';

  @override
  String get appSupport_later => 'Fy atgoffa yn nes ymlaen';

  @override
  String get appSupport_never => 'Peidio â\'m hatgoffa eto';

  @override
  String get appSupport_linkFailed =>
      'Methu cwblhau\'r weithred hon. Rhowch gynnig arall arni.';

  @override
  String get appSupport_participateTitle => 'Cyfrannu at Table Habit';

  @override
  String get appSupport_participateMessage =>
      'Archwilio\'r cod ffynhonnell, cyfrannu, neu rannu problemau a syniadau.';

  @override
  String appSupport_page(int page, int count) {
    return 'Tudalen $page o $count';
  }

  @override
  String get appSupport_saveFailed =>
      'Methwyd cadw\'r nodyn atgoffa. Rhowch gynnig arall arni.';

  @override
  String get appSetting_uiStyle_titleText => 'Arddull y rhyngwyneb';

  @override
  String get appSetting_uiStyle_automatic => 'Awtomatig';

  @override
  String get appSetting_uiStyle_material => 'Material';

  @override
  String get appSetting_uiStyle_apple => 'Apple';

  @override
  String get appSetting_appleSidebarStyle_titleText =>
      'Ymddangosiad bar ochr Apple';

  @override
  String get appSetting_appleSidebarStyle_inset => 'Mewnosodedig';

  @override
  String get appSetting_appleSidebarStyle_edge => 'Ymyl';
}
