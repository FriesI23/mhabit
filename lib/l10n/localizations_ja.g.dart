// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get localeScriptName => '日本語';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => '保存';

  @override
  String get habitEdit_habitName_hintText => '習慣の名称...';

  @override
  String get habitEdit_colorPicker_title => '色を選択';

  @override
  String get habitEdit_habitTypeDialog_title => '習慣のタイプ';

  @override
  String get habitEdit_habitType_positiveText => '良い習慣';

  @override
  String get habitEdit_habitType_negativeText => '悪い習慣';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return '1日の目標、デフォルト: $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return '1日の最小目標、デフォルト: $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return '1日の目標は $number より大きい必要があります';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return '1日の目標は $number 以下である必要があります';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return '1日の目標は $number 以上である必要があります';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return '1日の目標は $number 以下である必要があります';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => '単位';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => '1日の最大目標（任意）';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return '有効な値です。空欄または $dailyGoal 以上である必要があります';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => '1日の上限目標';

  @override
  String get habitEdit_frequencySelector_title => '頻度を選択';

  @override
  String get habitEdit_habitFreq_daily => '毎日';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => '回／週';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => '回／月';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => '回';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => '日あたり';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => '毎日';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '週に最低$freq回',
      one: '毎週',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '月に最低$freq回',
      one: '毎月',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '$days日ごとに最低$freq回',
      one: '$days日ごとに',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays 日';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => '目標日数を選択';

  @override
  String get habitEdit_targetDays => '日';

  @override
  String get habitEdit_reminder_hintText => 'リマインダー';

  @override
  String get habitEdit_reminder_freq_weekHelpText => '特定の曜日に繰り返し';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' 毎週';

  @override
  String get habitEdit_reminder_freq_monthHelpText => '特定の日に繰り返し';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' 毎月';

  @override
  String get habitEdit_reminderQuest_hintText => '質問例: 今日は運動しましたか。';

  @override
  String get habitEdit_reminder_dialogTitle => 'リマインダーのタイプを選択';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'チェックインが必要な時';

  @override
  String get habitEdit_reminder_dialogType_daily => '毎日';

  @override
  String get habitEdit_reminder_dialogType_week => '毎週';

  @override
  String get habitEdit_reminder_dialogType_month => '毎月';

  @override
  String get habitEdit_reminder_dialogConfirm => '確認';

  @override
  String get habitEdit_reminder_dialogCancel => 'キャンセル';

  @override
  String get habitEdit_reminder_cancelDialogTitle => '確認';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'このリマインダーを削除してもよろしいですか';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => '確認';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'キャンセル';

  @override
  String get habitEdit_reminder_weekdayText_monday => '月';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => '火';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => '水';

  @override
  String get habitEdit_reminder_weekdayText_thursday => '木';

  @override
  String get habitEdit_reminder_weekdayText_friday => '金';

  @override
  String get habitEdit_reminder_weekdayText_saturday => '土';

  @override
  String get habitEdit_reminder_weekdayText_sunday => '日';

  @override
  String get habitEdit_desc_hintText => 'メモ、Markdownをサポート';

  @override
  String get habitEdit_create_datetime_prefix => '作成日: ';

  @override
  String get habitEdit_modify_datetime_prefix => '修正日: ';

  @override
  String get habitDisplay_fab_text => '新しい習慣';

  @override
  String get habitDisplay_emptyImage_text_01 => '千里の道も一歩から始まる';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'No matching habits found';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'No matching habits for \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      '選択した習慣をアーカイブしますか。';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => '確認';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'キャンセル';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '習慣を $count 件アーカイブしました';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      '選択した習慣のアーカイブを解除しますか。';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => '確認';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'キャンセル';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '習慣を $count 件アーカイブ解除しました';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => '選択した習慣を削除しますか。';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => '確認';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'キャンセル';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '習慣を $count 件削除しました';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return '習慣「$name」を削除しました';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '習慣を $count 件エクスポートしました',
      one: '習慣をエクスポートしました',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText => '全ての習慣をエクスポートしました';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'すべて選択';

  @override
  String get habitDisplay_editPopMenu_export => 'エクスポート';

  @override
  String get habitDisplay_editPopMenu_delete => '削除';

  @override
  String get habitDisplay_editPopMenu_clone => 'テンプレート';

  @override
  String get habitDisplay_editButton_tooltip => '編集';

  @override
  String get habitDisplay_archiveButton_tooltip => 'アーカイブ';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'アーカイブ解除';

  @override
  String get habitDisplay_settingButton_tooltip => '設定';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => '現在';

  @override
  String get habitDisplay_statsMenu_completedTileText => '完了';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => '進行中';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'アーカイブ済み';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'トップ習慣: 過去30日間の変化';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'ライトテーマ';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'ダークテーマ';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'システムに従う';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'アーカイブを表示';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => '完了済みを表示';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => '進行中を表示';

  @override
  String get habitDisplay_mainMenu_settingTileText => '設定';

  @override
  String get habitDisplay_sort_reverseText => '反転';

  @override
  String get habitDisplay_sortDirection_asc => '(昇順)';

  @override
  String get habitDisplay_sortDirection_Desc => '(降順)';

  @override
  String get habitDisplay_sortType_manual => '自分の順序';

  @override
  String get habitDisplay_sortType_name => '名前順';

  @override
  String get habitDisplay_sortType_colorType => '色順';

  @override
  String get habitDisplay_sortType_progress => '達成率順';

  @override
  String get habitDisplay_sortType_startT => '開始日順';

  @override
  String get habitDisplay_sortType_status => 'ステータス順';

  @override
  String get habitDisplay_sortTypeDialog_title => '並べ替え';

  @override
  String get habitDisplay_sortTypeDialog_confirm => '確認';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'キャンセル';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️デバッグ';

  @override
  String get habitDisplay_searchBar_hintText => '習慣を検索';

  @override
  String get habitDisplay_searchFilter_ongoing => '進行中';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      '現在アクティブで進行中の習慣を表示します（アーカイブ済みや削除済みを除く）。';

  @override
  String get habitDisplay_searchFilter_completed => '完了';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => '習慣のタイプ';

  @override
  String get habitDisplay_searchFilter_tooltips => 'フィルターを表示';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'フィルターをクリア';

  @override
  String get habitDisplay_tab_habits_label => 'Habits';

  @override
  String get habitDisplay_tab_today_label => '今日';

  @override
  String get habitToday_appBar_title => '今日';

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
  String get habitDetail_editButton_tooltip => '編集';

  @override
  String get habitDetail_editPopMenu_unarchive => 'アーカイブ解除';

  @override
  String get habitDetail_editPopMenu_archive => 'アーカイブ';

  @override
  String get habitDetail_editPopMenu_export => 'エクスポート';

  @override
  String get habitDetail_editPopMenu_delete => '削除';

  @override
  String get habitDetail_editPopMenu_clone => 'テンプレート';

  @override
  String get habitDetail_confirmDialog_confirm => '確認';

  @override
  String get habitDetail_confirmDialog_cancel => 'キャンセル';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => '習慣をアーカイブしますか。';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => '習慣のアーカイブを解除しますか。';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => '習慣を削除しますか。';

  @override
  String get habitDetail_summary_title => '概要';

  @override
  String habitDetail_summary_body(String score, int days) {
    return '現在のスコアは $score で、開始から $days 日が経過しました。';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 日後に開始します',
      one: '明日開始します',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: '不十分',
      one: '未完了',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: '完璧',
      one: '達成',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '目標',
      two: '閾値',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return '単位: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'なし';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '日数',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => '日';

  @override
  String get habitDetail_descRecordsNum_titleText => '記録数';

  @override
  String get habitDetail_scoreChart_title => 'スコア';

  @override
  String get habitDetail_scoreChartCombine_dailyText => '日';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => '週';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => '月';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => '年';

  @override
  String get habitDetail_freqChart_freqTitle => '頻度';

  @override
  String get habitDetail_freqChart_historyTitle => '履歴';

  @override
  String get habitDetail_freqChart_combinedTitle => '頻度と履歴';

  @override
  String get habitDetail_freqChartCombine_weeklyText => '週';

  @override
  String get habitDetail_freqChartCombine_monthlyText => '月';

  @override
  String get habitDetail_freqChartCombine_yearlyText => '年';

  @override
  String get habitDetail_freqChartNaviBar_nowText => '現在';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => '履歴チャートを隠す';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => '履歴チャートを表示';

  @override
  String get habitDetail_descSubgroup_title => 'メモ';

  @override
  String get habitDetail_otherSubgroup_title => 'その他';

  @override
  String get habitDetail_habitType_title => 'タイプ';

  @override
  String get habitDetail_reminderTile_title => 'リマインダー';

  @override
  String get habitDetail_freqTile_title => '繰り返し';

  @override
  String get habitDetail_startDateTile_title => '開始日';

  @override
  String get habitDetail_createDateTile_title => '作成日';

  @override
  String get habitDetail_modifyDateTile_title => '修正日';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => '日付';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => '値';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => '今日に戻る';

  @override
  String get habitDetail_notFoundText => '習慣の読み込みに失敗しました';

  @override
  String get habitDetail_notFoundRetryText => '再試行';

  @override
  String get habitDetail_changeGoal_title => '目標を変更';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return '現在: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return '完了: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => '未完了';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return '1日の目標、デフォルト: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'キャンセル';

  @override
  String get habitDetail_changeGoal_saveText => '保存';

  @override
  String get habitDetail_skipReason_title => 'スキップの理由';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'ここに何か書いてください...';

  @override
  String get habitDetail_skipReason_cancelText => 'キャンセル';

  @override
  String get habitDetail_skipReason_saveText => '保存';

  @override
  String get appSetting_appbar_titleText => '設定';

  @override
  String get appSetting_displaySubgroupText => '表示';

  @override
  String get appSetting_operationSubgroupText => '操作';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'カレンダーをページごとにドラッグ';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'スイッチを有効にすると、ホーム画面のアプリバーのカレンダーがページごとにドラッグされます。デフォルトでは無効です。';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => '記録ステータスの変更';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'メインページでの毎日の記録ステータスを変更するクリック動作を変更します。';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => '詳細記録を開く';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'メインページで毎日の記録の詳細ポップアップを開くクリック動作を変更します。';

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
  String get appSetting_firstDayOfWeek_titleText => '週の開始日';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => '週の開始日を表示';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (デフォルト)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'システムに従う ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'システムに従う';

  @override
  String get appSetting_changeLanguageTile_titleText => '言語';

  @override
  String get appSetting_changeLanguageDialog_titleText => '言語を選択';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return '日付表示形式 ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'システム設定に従う';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      '設定された日付形式は、習慣詳細ページの日付表示に適用されます。';

  @override
  String get appSetting_compactUISwitcher_titleText => '習慣ページでコンパクト表示を有効にする';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      '習慣チェックテーブルにより多くのコンテンツを表示できるようにしますが、一部のUIやテキストが小さく表示される場合があります。';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => '習慣チェック領域の表示比率';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      '習慣チェック領域の表示サイズを調整します。';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'デフォルト';

  @override
  String get appSetting_reminderSubgroupText => 'リマインダーと通知';

  @override
  String get appSetting_dailyReminder_titleText => 'デイリーリマインダー';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'バックアップと復元';

  @override
  String get appSetting_export_titleText => 'エクスポート';

  @override
  String get appSetting_export_subtitleText =>
      '習慣をJSON形式でエクスポートします。このファイルはインポート可能です。';

  @override
  String get appSetting_import_titleText => 'インポート';

  @override
  String get appSetting_import_subtitleText => 'JSONファイルから習慣をインポートします。';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return '$count 個の習慣をインポートしますか。';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      '注: インポートは既存の習慣を削除しません。';

  @override
  String get appSetting_importDialog_confirm_confirmText => '確認';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'キャンセル';

  @override
  String appSetting_importDialog_importingTitle(
      int completeCount, int totalCount) {
    return '$completeCount/$totalCount をインポートしました';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return '$count 個のインポートを完了しました';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => '閉じる';

  @override
  String get appSetting_resetConfig_titleText => '設定をリセット';

  @override
  String get appSetting_resetConfig_subtitleText => 'すべての設定をデフォルトにリセットします。';

  @override
  String get appSetting_resetConfigDialog_titleText => '設定をリセットしますか。';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'すべての設定をデフォルトにリセットします。適用するにはアプリを再起動する必要があります。';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'キャンセル';

  @override
  String get appSetting_resetConfigDialog_confirmText => '確認';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'アプリ設定のリセットに成功しました';

  @override
  String get appSetting_otherSubgroupText => 'その他';

  @override
  String get appSetting_developMode_titleText => '開発モード';

  @override
  String get appSetting_clearCache_titleText => 'キャッシュをクリア';

  @override
  String get appSetting_clearCacheDialog_titleText => 'キャッシュをクリア';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'キャッシュをクリアすると、一部のカスタム値はデフォルトに戻ります。';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'キャンセル';

  @override
  String get appSetting_clearCacheDialog_confirmText => '確認';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      '部分的なキャッシュのクリアに失敗しました';

  @override
  String get appSetting_clearCache_snackBar_succText => 'キャッシュのクリアに成功しました';

  @override
  String get appSetting_clearCache_snackBar_failText => 'キャッシュのクリアに失敗しました';

  @override
  String get appSetting_debugger_titleText => 'デバッグ情報';

  @override
  String get appSetting_about_titleText => 'アプリについて';

  @override
  String get appSetting_experimentalFeatureTile_titleText => '実験的な機能';

  @override
  String get appSetting_synSubgroupText => '同期';

  @override
  String get appSetting_syncOption_titleText => '同期オプション';

  @override
  String get appSetting_notify_titleTile => '通知';

  @override
  String get appSetting_notify_subtitleTile => '通知設定を管理';

  @override
  String get appSetting_notify_subtitleTile_android => 'タップしてシステムの通知設定を開く';

  @override
  String get appSync_nowTile_titleText => '今すぐ同期';

  @override
  String get appSync_nowTile_titleText_syncing => '同期中';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => '最終同期: なし';

  @override
  String appSync_nowTile_text(String dateStr) {
    return '最終同期: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate => '最終同期 (エラー): なし';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return '最終同期 (エラー): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => '同期中...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 2);
    final String prtString = prtNumberFormat.format(prt);

    return '同期中: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'キャンセル中...';

  @override
  String get appSync_nowTile_cancelText_noDate => '最終同期 (キャンセル): なし';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return '最終同期 (キャンセル): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => '失敗ログを確認';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[エラー]: $info';
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
        'success': '完了',
        'cancelled': 'キャンセル',
        'failed': '失敗',
        'multi': '複数のステータス',
        'other': '不明なステータス',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'success': '完了: $reason',
        'cancelled': 'キャンセル: $reason',
        'failed': '失敗: $reason',
        'multi': '複数のステータス: $reason',
        'other': '不明なステータス',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(
      reason,
      {
        'error': 'エラー',
        'userAction': 'ユーザー操作が必要',
        'missingHabitUuid': '習慣のUUIDが欠落',
        'empty': '空のデータ',
        'other': '不明な理由',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => '新しい保存先';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      '同期には必要なディレクトリの作成と、サーバーへのローカル習慣データのアップロードが必要です。続行しますか。';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText => '今すぐ同期！';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText => '同期の確認';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'ディレクトリが空ではありません。同期するとサーバーとローカルの習慣がマージされます。続行しますか。';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText => 'マージを確認';

  @override
  String get appSync_exportAllLogsTile_titleText => '失敗した同期ログをエクスポート';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(
      isEmpty,
      {
        'true': 'ログが見つかりません',
        'false': 'タップしてエクスポート',
        'other': '読み込み中...',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(
      isCurrent,
      {
        'true': '現在: ',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      name,
      {
        'webdav': 'WebDAV',
        'fake': 'Fake (デバッグ用のみ)',
        'other': '不明 ($name)',
      },
    );
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'mobile': 'モバイル通信',
        'wifi': 'Wi-Fi',
        'other': '不明',
      },
    );
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'manual': '手動',
        'minute5': '5分',
        'minute15': '15分',
        'minute30': '30分',
        'hour1': '1時間',
        'other': '不明',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => '取得間隔';

  @override
  String get appSync_summaryTile_title => '同期サーバー';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured => '未設定';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText => '最近のすべての失敗した同期ログ';

  @override
  String get appSync_serverEditor_saveDialog_titleText => '変更を保存';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      '保存すると、以前のサーバー設定が上書きされます。';

  @override
  String get appSync_serverEditor_exitDialog_titleText => '未保存の変更';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      '終了すると、未保存の変更はすべて破棄されます。';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => '削除を確認';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      '削除すると、現在のサーバー設定が削除されます。';

  @override
  String get appSync_serverEditor_titleText_add => '新しい同期サーバー';

  @override
  String get appSync_serverEditor_titleText_modify => '同期サーバーを修正';

  @override
  String get appSync_serverEditor_advance_titleText => '詳細設定';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'パス';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      '有効なWebDAVパスをここに入力してください。';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'パスを空にすることはできません！';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'ユーザー名';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'ユーザー名を入力してください（不要な場合は空欄）。';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'パスワード';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText => 'SSL証明書を無視';

  @override
  String get appSync_serverEditor_timeoutTile_titleText => '同期タイムアウト（秒）';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: '無制限',
    );
    return 'デフォルト: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => '秒';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'ネットワーク接続タイムアウト（秒）';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
      int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: '無制限',
    );
    return 'デフォルト: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => '秒';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'ネットワーク接続再試行回数';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: '再試行しない',
    );
    return 'デフォルト: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText => 'ネットワーク同期モード';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'mobile': 'モバイル通信で同期',
        'wifi': 'Wi-Fiで同期',
        'other': '不明',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => '省データモード';

  @override
  String get appSync_noti_readyToSync_body => '同期の準備中...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(
      synced,
      {
        'synced': '同期完了 ($type)',
        'failed': '同期失敗 ($type)',
        'other': '同期中 ($type)',
      },
    );
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip => '省データモードでの同期';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      '1つ以上の実験的な機能が有効になっています。注意して使用してください。';

  @override
  String get experimentalFeatures_habitSyncTile_titleText => '習慣クラウド同期';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      '有効にすると、設定にアプリの同期オプションが表示されます';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return '実験的な機能 ($syncName) は無効ですが、機能はまだ実行中です。';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return '完全に無効にするには、長押しして \'$menuName\' にアクセスし、オフにしてください。';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => '習慣検索';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      '有効にすると、習慣画面の上部に検索バーが表示され、習慣を検索できるようになります。';

  @override
  String get appAbout_appbarTile_titleText => 'アプリについて';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'バージョン: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'ソースコード';

  @override
  String get appAbout_issueTrackerTile_titleText => '課題追跡 (Issue Tracker)';

  @override
  String get appAbout_contactEmailTile_titleText => 'お問い合わせ';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'ご連絡ありがとうございます。\nバグを報告する場合は、アプリのバージョンを示し、再現手順を説明してください。\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'ライセンス';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'サードパーティライセンス声明';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'プライバシー';

  @override
  String get appAbout_privacyTile_subTitleText => 'このアプリのプライバシーポリシーにアクセスする';

  @override
  String get appAbout_donateTile_titleText => '寄付';

  @override
  String get appAbout_donateTile_subTitleText =>
      '私は個人の開発者です。もしこのアプリを気に入っていただけたら、コーヒーを一杯ご馳走してください ☕';

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
  String get donateWay_cryptoCurrency => '暗号通貨';

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
    return '$name のアドレスをコピーしました';
  }

  @override
  String get batchCheckin_appbar_title => '一括チェックイン';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => '前の日';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => '次の日';

  @override
  String get batchCheckin_status_skip_text => 'スキップ';

  @override
  String get batchCheckin_status_ok_text => '完了';

  @override
  String get batchCheckin_status_double_text => 'x2 達成!';

  @override
  String get batchCheckin_status_zero_text => '未完了';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '個の習慣',
      one: '個の習慣',
    );
    return '$count $_temp0 を選択中';
  }

  @override
  String get batchCheckin_save_button_text => '保存';

  @override
  String get batchCheckin_reset_button_text => 'リセット';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個の習慣のステータス',
      one: '習慣のステータス',
    );
    return '$_temp0を修正しました';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => '既存の記録を上書き';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      '既存の記録は上書きされます。保存後、以前の記録は失われます。';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => '保存';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'キャンセル';

  @override
  String get batchCheckin_close_confirmDialog_title => '戻る確認';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'チェックインステータスの変更は保存されずに破棄されます。';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => '終了';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'キャンセル';

  @override
  String get appReminder_dailyReminder_title => '🏝 今日の習慣を守りましたか。';

  @override
  String get appReminder_dailyReminder_body => 'クリックしてアプリに入り、時間通りに記録しましょう。';

  @override
  String get common_habitColorType_cc1 => 'ディーライラック';

  @override
  String get common_habitColorType_cc2 => 'レッド';

  @override
  String get common_habitColorType_cc3 => 'パープル';

  @override
  String get common_habitColorType_cc4 => 'ロイヤルブルー';

  @override
  String get common_habitColorType_cc5 => 'ダークシアン';

  @override
  String get common_habitColorType_cc6 => 'グリーン';

  @override
  String get common_habitColorType_cc7 => 'アンバー';

  @override
  String get common_habitColorType_cc8 => 'オレンジ';

  @override
  String get common_habitColorType_cc9 => 'ライムグリーン';

  @override
  String get common_habitColorType_cc10 => 'ダークオーキッド';

  @override
  String common_habitColorType_default(int index) {
    return '色 $index';
  }

  @override
  String get common_appThemeColor_system => 'System';

  @override
  String get common_appThemeColor_primary => 'Primary';

  @override
  String get common_appThemeColor_dynamic => 'Dynamic';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'システム形式を使用';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => '日付形式';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => '年 月 日';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => '月 日 年';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => '日 月 年';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => '区切り文字';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'ダッシュ (-)';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'スラッシュ (/)';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'スペース';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'ドット (.)';

  @override
  String get common_customDateTimeFormatPicker_empty_text => '区切り文字なし';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
      String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => '12時間制を使用';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => '月名を使用';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      '頻度チャートに適用';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'カレンダーに適用';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'キャンセル';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => '確認';

  @override
  String get common_errorPage_title => 'おっと、クラッシュしました！';

  @override
  String get common_errorPage_copied => 'クラッシュ情報をコピーしました';

  @override
  String get common_enable_text => '有効';

  @override
  String get calendarPicker_clip_today => '今日';

  @override
  String get calendarPicker_clip_tomorrow => '明日';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return '次の$dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'すべての習慣をエクスポートしますか。';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number個の習慣',
      one: '1個の習慣',
      zero: '現在の習慣',
    );
    return '$_temp0をエクスポートしますか。';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => '記録を含める';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'キャンセル';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'エクスポート';

  @override
  String get debug_logLevelTile_title => 'ログレベル';

  @override
  String get debug_logLevelDialog_title => 'ログレベルを変更';

  @override
  String get debug_logLevel_debug => 'デバッグ';

  @override
  String get debug_logLevel_info => '情報';

  @override
  String get debug_logLevel_warn => '警告';

  @override
  String get debug_logLevel_error => 'エラー';

  @override
  String get debug_logLevel_fatal => '致命的';

  @override
  String get debug_collectLogTile_title => 'ログを収集中';

  @override
  String get debug_collectLogTile_enable_subtitle => 'タップしてログ収集を停止。';

  @override
  String get debug_collectLogTile_disable_subtitle => 'タップしてログ収集を開始。';

  @override
  String get debug_downladDebugLogs_subject => 'デバッグログをダウンロード中';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'デバッグログを消去しました。';

  @override
  String get debug_downladDebugInfo_subject => 'デバッグ情報をダウンロード中';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return '$fileName をダウンロード中';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'デバッグログが存在しません。';

  @override
  String get debug_debuggerLogCard_title => 'ログ情報';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'ローカルデバッグログ情報が含まれます。ログ収集スイッチをオンにする必要があります。';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'ダウンロード';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'クリア';

  @override
  String get debug_debuggerInfoCard_title => 'デバッグ情報';

  @override
  String get debug_debuggerInfoCard_subtitle => 'アプリのデバッグ情報が含まれます。';

  @override
  String get debug_debuggerInfoCard_openButton_text => '開く';

  @override
  String get debug_debuggerInfoCard_saveButton_text => '保存';

  @override
  String get debug_debuggerInfo_notificationTitle => 'アプリ情報を収集中...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'save': '保存',
        'exit': '終了',
        'delete': '削除',
        'other': '確認',
      },
    );
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'キャンセル';

  @override
  String get snackbar_undoText => '元に戻す';

  @override
  String get snackbar_dismissText => '閉じる';

  @override
  String get contributors_tile_title => '貢献者';

  @override
  String get userAction_tap => 'タップ';

  @override
  String get userAction_doubleTap => 'ダブルタップ';

  @override
  String get userAction_longTap => 'ロングタップ';

  @override
  String get channelName_habitReminder => '習慣リマインダー';

  @override
  String get channelName_appReminder => 'アプリリマインダー';

  @override
  String get channelName_appDebugger => 'デバッガー';

  @override
  String get channelName_appSyncing => '同期プロセス';

  @override
  String get channelDesc_appSyncing => '同期の進行状況と成功した結果を表示するために使用されます';

  @override
  String get channelName_appSyncFailed => '同期失敗';

  @override
  String get channelDesc_appSyncFailed => '同期に失敗したときに警告するために使用されます';
}
