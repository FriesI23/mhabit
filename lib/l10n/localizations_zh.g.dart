import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get localeScriptName => '中文';

  @override
  String get appName => '桌上习惯';

  @override
  String get habitEdit_saveButton_text => '保存';

  @override
  String get habitEdit_habitName_hintText => '习惯名称...';

  @override
  String get habitEdit_colorPicker_title => '选择颜色';

  @override
  String get habitEdit_habitTypeDialog_title => '习惯类型';

  @override
  String get habitEdit_habitType_positiveText => '积极';

  @override
  String get habitEdit_habitType_negativeText => '消极';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return '每日目标, 默认为$number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return '每日最低限度, 默认为$number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return '每日目标须 > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return '每日目标须 ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return '每日目标必须 ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return '每日目标必须 ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => '单位';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => '期望的每日最高目标';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return '无效的值，必须为空或者 ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => '每日最高限额';

  @override
  String get habitEdit_frequencySelector_title => '频率';

  @override
  String get habitEdit_habitFreq_daily => '每日';

  @override
  String get habitEdit_habitFreq_perweek => '每周完成';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => '次';

  @override
  String get habitEdit_habitFreq_permonth => '每月完成';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => '次';

  @override
  String get habitEdit_habitFreq_predayfreq => '次';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => '天内完成';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => '每';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '1';

  @override
  String get habitEdit_habitFreq_show_daily => '每日';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '每周至少完成$freq次',
      one: '每周',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '每月至少完成$freq次',
      one: '每月',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '每$days天内至少完成$freq次',
      one: '每$days天',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays日';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => '选择目标';

  @override
  String get habitEdit_targetDays => '日';

  @override
  String get habitEdit_reminder_hintText => '提醒';

  @override
  String get habitEdit_reminder_freq_weekHelpText => '每日(按周)';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '每周';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => '';

  @override
  String get habitEdit_reminder_freq_monthHelpText => '每日(按月)';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '每月';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => '日';

  @override
  String get habitEdit_reminderQuest_hintText => '提一个问题, 比如\"今天完成作业了么?\"';

  @override
  String get habitEdit_reminder_dialogTitle => '提醒频率';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => '当需要打卡时';

  @override
  String get habitEdit_reminder_dialogType_daily => '每日';

  @override
  String get habitEdit_reminder_dialogType_week => '每周';

  @override
  String get habitEdit_reminder_dialogType_month => '每月';

  @override
  String get habitEdit_reminder_dialogConfirm => '确定';

  @override
  String get habitEdit_reminder_dialogCancel => '取消';

  @override
  String get habitEdit_reminder_cancelDialogTitle => '取消确认';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => '确认取消该提醒?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => '确定';

  @override
  String get habitEdit_reminder_cancelDialogCancel => '取消';

  @override
  String get habitEdit_reminder_weekdayText_monday => '一';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => '二';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => '三';

  @override
  String get habitEdit_reminder_weekdayText_thursday => '四';

  @override
  String get habitEdit_reminder_weekdayText_friday => '五';

  @override
  String get habitEdit_reminder_weekdayText_saturday => '六';

  @override
  String get habitEdit_reminder_weekdayText_sunday => '日';

  @override
  String get habitEdit_desc_hintText => '备忘, 支持Markdown';

  @override
  String get habitEdit_create_datetime_prefix => '创建: ';

  @override
  String get habitEdit_modify_datetime_prefix => '修改: ';

  @override
  String get habitDisplay_fab_text => '新习惯';

  @override
  String get habitDisplay_emptyImage_text_01 => '千里之行, 始于足下';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => '归档选中的习惯?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => '确定';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => '取消';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '已归档$count个习惯';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => '取消选中习惯的归档?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => '确定';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => '取消';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '已取消$count个习惯的归档';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => '删除选择的习惯?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => '确定';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => '取消';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '已删除$count个习惯';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => '全选';

  @override
  String get habitDisplay_editPopMenu_export => '导出';

  @override
  String get habitDisplay_editPopMenu_delete => '删除';

  @override
  String get habitDisplay_editPopMenu_clone => '模板';

  @override
  String get habitDisplay_editButton_tooltip => '编辑';

  @override
  String get habitDisplay_archiveButton_tooltip => '归档';

  @override
  String get habitDisplay_unarchiveButton_tooltip => '取消归档';

  @override
  String get habitDisplay_settingButton_tooltip => '设置';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => '当前';

  @override
  String get habitDisplay_statsMenu_completedTileText => '已完成';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => '进行中';

  @override
  String get habitDisplay_statsMenu_archivedTileText => '已归档';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => '热门习惯: 近30天变化';

  @override
  String get habitDisplay_mainMenu_lightTheme => '明亮主题';

  @override
  String get habitDisplay_mainMenu_darkTheme => '黑暗主题';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => '跟随系统';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => '已归档';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => '已完成';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => '进行中';

  @override
  String get habitDisplay_mainMenu_settingTileText => '设置';

  @override
  String get habitDisplay_sort_reverseText => '反向排序';

  @override
  String get habitDisplay_sortDirection_asc => '(正序)';

  @override
  String get habitDisplay_sortDirection_Desc => '(反序)';

  @override
  String get habitDisplay_sortType_manual => '自定义';

  @override
  String get habitDisplay_sortType_name => '名称';

  @override
  String get habitDisplay_sortType_colorType => '颜色';

  @override
  String get habitDisplay_sortType_progress => '完成度';

  @override
  String get habitDisplay_sortType_startT => '开始日期';

  @override
  String get habitDisplay_sortType_status => '状态';

  @override
  String get habitDisplay_sortTypeDialog_title => '排序';

  @override
  String get habitDisplay_sortTypeDialog_confirm => '确定';

  @override
  String get habitDisplay_sortTypeDialog_cancel => '取消';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️调试选项';

  @override
  String get habitDetail_editButton_tooltip => '编辑';

  @override
  String get habitDetail_editPopMenu_unarchive => '取消归档';

  @override
  String get habitDetail_editPopMenu_archive => '归档';

  @override
  String get habitDetail_editPopMenu_export => '导出';

  @override
  String get habitDetail_editPopMenu_delete => '删除';

  @override
  String get habitDetail_editPopMenu_clone => '模板';

  @override
  String get habitDetail_confirmDialog_confirm => '确定';

  @override
  String get habitDetail_confirmDialog_cancel => '取消';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => '归档该习惯？';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => '取消归档该习惯？';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => '删除该习惯？';

  @override
  String get habitDetail_summary_title => '总览';

  @override
  String habitDetail_summary_body(String score, int days) {
    return '当前分数为 $score，距开始已经过 $days 天。';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    return '距离开始还有 $days 天';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: '未达标',
      one: '未完成',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: '完美达标',
      one: '超额完成',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '每日目标',
      two: '每日限额',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return '单位：$unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => '无';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '完成天数',
      two: '达标天数',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => '';

  @override
  String get habitDetail_descRecordsNum_titleText => '记录总数';

  @override
  String get habitDetail_scoreChart_title => '分数';

  @override
  String get habitDetail_scoreChartCombine_dailyText => '日';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => '周';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => '月';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => '年';

  @override
  String get habitDetail_freqChart_freqTitle => '频率';

  @override
  String get habitDetail_freqChart_historyTitle => '历史';

  @override
  String get habitDetail_freqChart_combinedTitle => '频率和历史';

  @override
  String get habitDetail_freqChartCombine_weeklyText => '周';

  @override
  String get habitDetail_freqChartCombine_monthlyText => '月';

  @override
  String get habitDetail_freqChartCombine_yearlyText => '年';

  @override
  String get habitDetail_freqChartNaviBar_nowText => '现在';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => '隐藏历史记录';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => '显示历史记录';

  @override
  String get habitDetail_descSubgroup_title => '备忘';

  @override
  String get habitDetail_otherSubgroup_title => '其他';

  @override
  String get habitDetail_habitType_title => '类型';

  @override
  String get habitDetail_reminderTile_title => '提醒';

  @override
  String get habitDetail_freqTile_title => '重复';

  @override
  String get habitDetail_startDateTile_title => '开始日期';

  @override
  String get habitDetail_createDateTile_title => '创建日期';

  @override
  String get habitDetail_modifyDateTile_title => '修改日期';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => '日期';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => '打卡值';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => '返回今日';

  @override
  String get habitDetail_notFoundText => '读取习惯失败';

  @override
  String get habitDetail_notFoundRetryText => '重试';

  @override
  String get habitDetail_changeGoal_title => '更改目标';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return '当前: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return '完成: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => '未完成';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return '每日目标，默认值：$goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => '取消';

  @override
  String get habitDetail_changeGoal_saveText => '保存';

  @override
  String get habitDetail_skipReason_title => '跳过原因';

  @override
  String get habitDetail_skipReason_bodyHelpText => '在这里随便写点什么...';

  @override
  String get habitDetail_skipReason_cancelText => '取消';

  @override
  String get habitDetail_skipReason_saveText => '保存';

  @override
  String get appSetting_appbar_titleText => '设置';

  @override
  String get appSetting_displaySubgroupText => '显示';

  @override
  String get appSetting_operationSubgroupText => '操作';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => '按页拖动日历';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => '如果启用开关，则主页上的应用栏日历将逐页拖动。默认情况下，该开关处于禁用状态。';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => '修改记录状态';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => '修改主页面上每日记录的状态的点击行为。';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => '打开详细记录';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => '修改主页面上打开每日记录详情弹窗的点击行为。';

  @override
  String get appSetting_firstDayOfWeek_titleText => '一周的第一天';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => '选择';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => '（默认值）';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return '跟随系统（$localeName）';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => '跟随系统';

  @override
  String get appSetting_changeLanguageTile_titleText => '多语言';

  @override
  String get appSetting_changeLanguageDialog_titleText => '选择语言';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return '日期显示格式 ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => '跟随系统设置';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => '配置的日期格式将应用于习惯详情页面的日期显示。';

  @override
  String get appSetting_compactUISwitcher_titleText => '习惯页中启用紧凑型UI';

  @override
  String get appSetting_compactUISwitcher_subtitleText => '允许习惯检查表格显示更多内容，但部分用户界面和文字可能会变小。';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => '习惯打卡区域占比调整';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => '调整百分比以获取更多/更少的习惯打卡区域。';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => '默认: 0';

  @override
  String get appSetting_reminderSubgroupText => '提醒';

  @override
  String get appSetting_dailyReminder_titleText => '每日提醒';

  @override
  String get appSetting_backupAndRestoreSubgroupText => '备份和恢复';

  @override
  String get appSetting_export_titleText => '导出';

  @override
  String get appSetting_export_subtitleText => '将习惯导出为 JSON 格式，该文件可以导入。';

  @override
  String get appSetting_import_titleText => '导入';

  @override
  String get appSetting_import_subtitleText => '从 JSON 文件导入习惯。';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return '确认导入 $count 个习惯？';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => '注意：导入不会删除现有的习惯。';

  @override
  String get appSetting_importDialog_confirm_confirmText => '确认';

  @override
  String get appSetting_importDialog_confirm_cancelText => '取消';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return '已导入 $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return '完成导入 $count 个习惯';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => '关闭';

  @override
  String get appSetting_resetConfig_titleText => '重置配置';

  @override
  String get appSetting_resetConfig_subtitleText => '将所有配置重置为默认值。';

  @override
  String get appSetting_resetConfigDialog_titleText => '重置配置？';

  @override
  String get appSetting_resetConfigDialog_subtitleText => '将所有配置重置为默认值，必须重新启动应用程序才能生效。';

  @override
  String get appSetting_resetConfigDialog_cancelText => '取消';

  @override
  String get appSetting_resetConfigDialog_confirmText => '确定';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => '已重置应用设置';

  @override
  String get appSetting_otherSubgroupText => '其他';

  @override
  String get appSetting_developMode_titleText => '开发模式';

  @override
  String get appSetting_clearCache_titleText => '清理缓存';

  @override
  String get appSetting_clearCacheDialog_titleText => '清理缓存';

  @override
  String get appSetting_clearCacheDialog_subtitleText => '清除缓存后，部分自定义值将会恢复默认。';

  @override
  String get appSetting_clearCacheDialog_cancelText => '取消';

  @override
  String get appSetting_clearCacheDialog_confirmText => '确认';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => '部分缓存清理失败';

  @override
  String get appSetting_clearCache_snackBar_succText => '缓存清理成功';

  @override
  String get appSetting_clearCache_snackBar_failText => '缓存清理失败';

  @override
  String get appSetting_debugger_titleText => '调试信息';

  @override
  String get appSetting_about_titleText => '关于';

  @override
  String get appAbout_appbarTile_titleText => '关于';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return '版本：$appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'docs/CHANGELOG/zh.md';

  @override
  String get appAbout_sourceCodeTile_titleText => '源码';

  @override
  String get appAbout_issueTrackerTile_titleText => '问题/讨论';

  @override
  String get appAbout_contactEmailTile_titleText => '联系我';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, 很高兴你能够联系我。\n如果反馈BUG需要注明版本并阐述复现流程\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => '开源许可';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache许可 版本2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => '第三方许可声明';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => '捐赠';

  @override
  String get appAbout_donateTile_subTitleText => '我是一名个人开发者，如果你觉得这个应用好用，请帮我买一杯☕';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => '请我喝一杯咖啡';

  @override
  String get donateWay_alipay => '支付宝';

  @override
  String get donateWay_wechatPay => '微信';

  @override
  String get donateWay_cryptoCurrency => '加密货币';

  @override
  String get donateWay_cryptoCurrency_BTC => '比特币';

  @override
  String get donateWay_cryptoCurrency_ETH => '以太坊';

  @override
  String get donateWay_cryptoCurrency_BNB => '币安币';

  @override
  String get donateWay_cryptoCurrency_AVAX => 'AVAX';

  @override
  String get donateWay_cryptoCurrency_FTM => 'FTM';

  @override
  String get donateWay_firstQRGroup => '支付宝与微信';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return '已复制$name地址';
  }

  @override
  String get batchCheckin_appbar_title => '批量打卡';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => '前一天';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => '后一天';

  @override
  String get batchCheckin_status_skip_text => '跳过';

  @override
  String get batchCheckin_status_ok_text => '完成';

  @override
  String get batchCheckin_status_double_text => '超量完成';

  @override
  String get batchCheckin_status_zero_text => '未完成';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    return '已选择$count个习惯';
  }

  @override
  String get batchCheckin_save_button_text => '保存';

  @override
  String get batchCheckin_reset_button_text => '重置';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    return '已修改$count个习惯的状态';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => '覆盖现有记录';

  @override
  String get batchCheckin_save_confirmDialog_body => '保存后将覆盖现有记录，之前记录将丢失。';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => '保存';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => '取消';

  @override
  String get batchCheckin_close_confirmDialog_title => '确认返回';

  @override
  String get batchCheckin_close_confirmDialog_body => '未保存的打卡状态更改将不会生效。';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => '确认';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => '取消';

  @override
  String get appReminder_dailyReminder_title => '🏝 你今天坚持了自己的习惯吗？';

  @override
  String get appReminder_dailyReminder_body => '点击进入应用并按时打卡。';

  @override
  String get common_habitColorType_cc1 => '紫罗兰';

  @override
  String get common_habitColorType_cc2 => '红色';

  @override
  String get common_habitColorType_cc3 => '紫色';

  @override
  String get common_habitColorType_cc4 => '皇家蓝';

  @override
  String get common_habitColorType_cc5 => '深青';

  @override
  String get common_habitColorType_cc6 => '绿色';

  @override
  String get common_habitColorType_cc7 => '琥珀';

  @override
  String get common_habitColorType_cc8 => '橙色';

  @override
  String get common_habitColorType_cc9 => '酸橙绿';

  @override
  String get common_habitColorType_cc10 => '兰花紫';

  @override
  String common_habitColorType_default(int index) {
    return '颜色-$index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => '使用系统格式';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => '日期格式';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => '年月日';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => '月日年';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => '日月年';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => '分隔符';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => '短横线';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => '斜线';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => '空格';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => '点号';

  @override
  String get common_customDateTimeFormatPicker_empty_text => '无分隔符';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => '使用12小时制';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => '使用完整名称';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => '对频率图表生效';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => '对补卡日历生效';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => '取消';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => '确认';

  @override
  String get calendarPicker_clip_today => '今天';

  @override
  String get calendarPicker_clip_tomorrow => '明天';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return '下$dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => '导出所有习惯？';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number个习惯',
      zero: '当前习惯',
    );
    return '导出$_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => '包含习惯记录';

  @override
  String get exportConfirmDialog_cancel_buttonText => '取消';

  @override
  String get exportConfirmDialog_confirm_buttonText => '导出';

  @override
  String get debug_logLevelTile_title => '日志级别';

  @override
  String get debug_logLevelDialog_title => '更改日志级别';

  @override
  String get debug_logLevel_debug => '调试';

  @override
  String get debug_logLevel_info => '信息';

  @override
  String get debug_logLevel_warn => '警告';

  @override
  String get debug_logLevel_error => '错误';

  @override
  String get debug_logLevel_fatal => '致命';

  @override
  String get debug_collectLogTile_title => '正在收集日志';

  @override
  String get debug_collectLogTile_enable_subtitle => '单击停止日志收集。';

  @override
  String get debug_collectLogTile_disable_subtitle => '单击开始日志收集。';

  @override
  String get debug_downladDebugLogs_subject => '下载调试日志';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => '已清除调试日志。';

  @override
  String get debug_downladDebugInfo_subject => '下载调试信息';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return '下载 $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => '调试日志不存在。';

  @override
  String get debug_debuggerLogCard_title => '日志信息';

  @override
  String get debug_debuggerLogCard_subtitle => '包括本地调试日志信息，需要打开日志收集开关。';

  @override
  String get debug_debuggerLogCard_saveButton_text => '下载';

  @override
  String get debug_debuggerLogCard_clearButton_text => '清除';

  @override
  String get debug_debuggerInfoCard_title => '调试信息';

  @override
  String get debug_debuggerInfoCard_subtitle => '包括应用程序的调试信息。';

  @override
  String get debug_debuggerInfoCard_openButton_text => '打开';

  @override
  String get debug_debuggerInfoCard_saveButton_text => '保存';

  @override
  String get debug_debuggerInfo_notificationTitle => '正在收集应用信息……';

  @override
  String get snackbar_undoText => '撤回';

  @override
  String get snackbar_dismissText => '忽略';

  @override
  String get contributors_tile_title => '贡献者';

  @override
  String get userAction_tap => '单击';

  @override
  String get userAction_doubleTap => '双击';

  @override
  String get userAction_longTap => '长按';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class L10nZhHans extends L10nZh {
  L10nZhHans(): super('zh_Hans');

  @override
  String get localeScriptName => '简体中文';

  @override
  String get appName => '桌上习惯';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class L10nZhHant extends L10nZh {
  L10nZhHant(): super('zh_Hant');

  @override
  String get localeScriptName => '繁體中文';

  @override
  String get appName => '桌上習慣';

  @override
  String get habitEdit_saveButton_text => '儲存';

  @override
  String get habitEdit_habitName_hintText => '習慣名稱...';

  @override
  String get habitEdit_colorPicker_title => '選擇顏色';

  @override
  String get habitEdit_habitTypeDialog_title => '習慣類型';

  @override
  String get habitEdit_habitType_positiveText => '積極';

  @override
  String get habitEdit_habitType_negativeText => '消極';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return '每日目標，預設為$number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return '每日最低限度，預設為$number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return '每日目標須大於 $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return '每日目標須小於等於 $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return '每日目標必須大於等於 $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return '每日目標必須小於等於 $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => '單位';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => '期望的每日最高目標';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return '無效值，必須為空或大於等於 $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => '每日最高限額';

  @override
  String get habitEdit_frequencySelector_title => '頻率';

  @override
  String get habitEdit_habitFreq_daily => '每日';

  @override
  String get habitEdit_habitFreq_perweek => '每週完成';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => '次';

  @override
  String get habitEdit_habitFreq_permonth => '每月完成';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => '次';

  @override
  String get habitEdit_habitFreq_predayfreq => '次';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => '天內完成';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => '每';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '1';

  @override
  String get habitEdit_habitFreq_show_daily => '每日';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '每週至少完成$freq次',
      one: '每週',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '每月至少完成$freq次',
      one: '每月',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: '每$days天內至少完成$freq次',
      one: '每$days天',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays日';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => '選擇目標';

  @override
  String get habitEdit_targetDays => '日';

  @override
  String get habitEdit_reminder_hintText => '提醒';

  @override
  String get habitEdit_reminder_freq_weekHelpText => '每日（按週）';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '每週';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => '';

  @override
  String get habitEdit_reminder_freq_monthHelpText => '每日（按月）';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '每月';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => '日';

  @override
  String get habitEdit_reminderQuest_hintText => '提一個問題，例如「今天完成作業了嗎？」';

  @override
  String get habitEdit_reminder_dialogTitle => '提醒頻率';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => '當需要打卡時';

  @override
  String get habitEdit_reminder_dialogType_daily => '每日';

  @override
  String get habitEdit_reminder_dialogType_week => '每週';

  @override
  String get habitEdit_reminder_dialogType_month => '每月';

  @override
  String get habitEdit_reminder_dialogConfirm => '確定';

  @override
  String get habitEdit_reminder_dialogCancel => '取消';

  @override
  String get habitEdit_reminder_cancelDialogTitle => '取消確認';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => '確定取消該提醒？';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => '確定';

  @override
  String get habitEdit_reminder_cancelDialogCancel => '取消';

  @override
  String get habitEdit_reminder_weekdayText_monday => '一';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => '二';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => '三';

  @override
  String get habitEdit_reminder_weekdayText_thursday => '四';

  @override
  String get habitEdit_reminder_weekdayText_friday => '五';

  @override
  String get habitEdit_reminder_weekdayText_saturday => '六';

  @override
  String get habitEdit_reminder_weekdayText_sunday => '日';

  @override
  String get habitEdit_desc_hintText => '備忘，支持 Markdown';

  @override
  String get habitEdit_create_datetime_prefix => '創建: ';

  @override
  String get habitEdit_modify_datetime_prefix => '修改: ';

  @override
  String get habitDisplay_fab_text => '新增習慣';

  @override
  String get habitDisplay_emptyImage_text_01 => '千里之行，始於足下';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => '歸檔選中的習慣？';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => '確定';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => '取消';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '已歸檔$count個習慣';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => '取消選中習慣的歸檔？';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => '確定';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => '取消';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '已取消$count個習慣的歸檔';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => '刪除選擇的習慣？';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => '確定';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => '取消';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '已刪除$count個習慣';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => '全選';

  @override
  String get habitDisplay_editPopMenu_export => '匯出';

  @override
  String get habitDisplay_editPopMenu_delete => '刪除';

  @override
  String get habitDisplay_editPopMenu_clone => '模板';

  @override
  String get habitDisplay_editButton_tooltip => '編輯';

  @override
  String get habitDisplay_archiveButton_tooltip => '歸檔';

  @override
  String get habitDisplay_unarchiveButton_tooltip => '取消歸檔';

  @override
  String get habitDisplay_settingButton_tooltip => '設定';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => '當前';

  @override
  String get habitDisplay_statsMenu_completedTileText => '已完成';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => '進行中';

  @override
  String get habitDisplay_statsMenu_archivedTileText => '已歸檔';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => '熱門習慣：近30天變化';

  @override
  String get habitDisplay_mainMenu_lightTheme => '明亮主題';

  @override
  String get habitDisplay_mainMenu_darkTheme => '黑暗主題';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => '跟隨系統';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => '已歸檔';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => '已完成';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => '進行中';

  @override
  String get habitDisplay_mainMenu_settingTileText => '設定';

  @override
  String get habitDisplay_sort_reverseText => '反向排序';

  @override
  String get habitDisplay_sortDirection_asc => '(正序)';

  @override
  String get habitDisplay_sortDirection_Desc => '(反序)';

  @override
  String get habitDisplay_sortType_manual => '自訂';

  @override
  String get habitDisplay_sortType_name => '名稱';

  @override
  String get habitDisplay_sortType_colorType => '顏色';

  @override
  String get habitDisplay_sortType_progress => '完成度';

  @override
  String get habitDisplay_sortType_startT => '開始日期';

  @override
  String get habitDisplay_sortType_status => '狀態';

  @override
  String get habitDisplay_sortTypeDialog_title => '排序';

  @override
  String get habitDisplay_sortTypeDialog_confirm => '確定';

  @override
  String get habitDisplay_sortTypeDialog_cancel => '取消';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️調試選項';

  @override
  String get habitDetail_editButton_tooltip => '編輯';

  @override
  String get habitDetail_editPopMenu_unarchive => '取消歸檔';

  @override
  String get habitDetail_editPopMenu_archive => '歸檔';

  @override
  String get habitDetail_editPopMenu_export => '匯出';

  @override
  String get habitDetail_editPopMenu_delete => '刪除';

  @override
  String get habitDetail_editPopMenu_clone => '模板';

  @override
  String get habitDetail_confirmDialog_confirm => '確定';

  @override
  String get habitDetail_confirmDialog_cancel => '取消';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => '歸檔該習慣？';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => '取消歸檔該習慣？';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => '刪除該習慣？';

  @override
  String get habitDetail_summary_title => '總覽';

  @override
  String habitDetail_summary_body(String score, int days) {
    return '當前分數為 $score，距開始已經過 $days 天。';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    return '距開始還有 $days 天';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: '未達標',
      one: '未完成',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: '完美達標',
      one: '超額完成',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '每日目標',
      two: '每日限額',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return '單位：$unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => '無';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '完成天數',
      two: '達標天數',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => '';

  @override
  String get habitDetail_descRecordsNum_titleText => '記錄總數';

  @override
  String get habitDetail_scoreChart_title => '分數';

  @override
  String get habitDetail_scoreChartCombine_dailyText => '日';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => '周';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => '月';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => '年';

  @override
  String get habitDetail_freqChart_freqTitle => '頻率';

  @override
  String get habitDetail_freqChart_historyTitle => '歷史';

  @override
  String get habitDetail_freqChart_combinedTitle => '頻率和歷史';

  @override
  String get habitDetail_freqChartCombine_weeklyText => '周';

  @override
  String get habitDetail_freqChartCombine_monthlyText => '月';

  @override
  String get habitDetail_freqChartCombine_yearlyText => '年';

  @override
  String get habitDetail_freqChartNaviBar_nowText => '現在';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => '隱藏歷史記錄';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => '顯示歷史記錄';

  @override
  String get habitDetail_descSubgroup_title => '備忘';

  @override
  String get habitDetail_otherSubgroup_title => '其他';

  @override
  String get habitDetail_habitType_title => '類型';

  @override
  String get habitDetail_reminderTile_title => '提醒';

  @override
  String get habitDetail_freqTile_title => '重複';

  @override
  String get habitDetail_startDateTile_title => '開始日期';

  @override
  String get habitDetail_createDateTile_title => '創建日期';

  @override
  String get habitDetail_modifyDateTile_title => '修改日期';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => '日期';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => '打卡值';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => '返回今日';

  @override
  String get habitDetail_notFoundText => '讀取習慣失敗';

  @override
  String get habitDetail_notFoundRetryText => '重試';

  @override
  String get habitDetail_changeGoal_title => '更改目標';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return '當前: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return '完成: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => '未完成';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return '每日目標，默認值：$goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => '取消';

  @override
  String get habitDetail_changeGoal_saveText => '保存';

  @override
  String get habitDetail_skipReason_title => '跳過原因';

  @override
  String get habitDetail_skipReason_bodyHelpText => '在這裡隨便寫點什麼...';

  @override
  String get habitDetail_skipReason_cancelText => '取消';

  @override
  String get habitDetail_skipReason_saveText => '保存';

  @override
  String get appSetting_appbar_titleText => '設定';

  @override
  String get appSetting_displaySubgroupText => '顯示';

  @override
  String get appSetting_operationSubgroupText => '操作';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => '按頁拖動日曆';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => '如果啟用開關，則主頁上的應用欄日曆將逐頁拖動。默認情況下，該開關處於禁用狀態。';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => '修改記錄狀態';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => '修改主頁面上每日記錄的狀態的點擊行為。';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => '打開詳細記錄';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => '修改主頁面上打開每日記錄詳情彈窗的點擊行為。';

  @override
  String get appSetting_firstDayOfWeek_titleText => '一週的第一天';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => '選擇';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => '（默認值）';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return '跟隨系統（$localeName）';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => '跟隨系統';

  @override
  String get appSetting_changeLanguageTile_titleText => '多語言';

  @override
  String get appSetting_changeLanguageDialog_titleText => '選擇語言';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return '日期顯示格式 ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => '跟隨系統設置';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => '配置的日期格式將應用於習慣詳情頁面的日期顯示。';

  @override
  String get appSetting_compactUISwitcher_titleText => '習慣頁中啟用緊湊型UI';

  @override
  String get appSetting_compactUISwitcher_subtitleText => '允許習慣檢查表格顯示更多內容，但部分用戶界面和文字可能會變小。';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => '習慣打卡區域佔比調整';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => '調整百分比以獲取更多/更少的習慣打卡區域。';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => '默認: 0';

  @override
  String get appSetting_reminderSubgroupText => '提醒';

  @override
  String get appSetting_dailyReminder_titleText => '每日提醒';

  @override
  String get appSetting_backupAndRestoreSubgroupText => '備份和恢復';

  @override
  String get appSetting_export_titleText => '匯出';

  @override
  String get appSetting_export_subtitleText => '將習慣匯出為 JSON 格式，該文件可以導入。';

  @override
  String get appSetting_import_titleText => '導入';

  @override
  String get appSetting_import_subtitleText => '從 JSON 文件導入習慣。';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return '確認導入 $count 個習慣？';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => '注意：導入不會刪除現有的習慣。';

  @override
  String get appSetting_importDialog_confirm_confirmText => '確認';

  @override
  String get appSetting_importDialog_confirm_cancelText => '取消';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return '已導入 $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return '完成導入 $count 個習慣';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => '關閉';

  @override
  String get appSetting_resetConfig_titleText => '重置配置';

  @override
  String get appSetting_resetConfig_subtitleText => '將所有配置重置為默認值。';

  @override
  String get appSetting_resetConfigDialog_titleText => '重置配置？';

  @override
  String get appSetting_resetConfigDialog_subtitleText => '將所有配置重置為默認值，必須重新啟動應用程序才能生效。';

  @override
  String get appSetting_resetConfigDialog_cancelText => '取消';

  @override
  String get appSetting_resetConfigDialog_confirmText => '確定';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => '已重置應用設置';

  @override
  String get appSetting_otherSubgroupText => '其他';

  @override
  String get appSetting_developMode_titleText => '開發模式';

  @override
  String get appSetting_clearCache_titleText => '清理快取';

  @override
  String get appSetting_clearCacheDialog_titleText => '清理快取';

  @override
  String get appSetting_clearCacheDialog_subtitleText => '清除快取後，部分自定義值將會恢復默認。';

  @override
  String get appSetting_clearCacheDialog_cancelText => '取消';

  @override
  String get appSetting_clearCacheDialog_confirmText => '確認';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => '部分快取清理失敗';

  @override
  String get appSetting_clearCache_snackBar_succText => '快取清理成功';

  @override
  String get appSetting_clearCache_snackBar_failText => '快取清理失敗';

  @override
  String get appSetting_debugger_titleText => '調試信息';

  @override
  String get appSetting_about_titleText => '關於';

  @override
  String get appAbout_appbarTile_titleText => '關於';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return '版本：$appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'docs/CHANGELOG/zh.md';

  @override
  String get appAbout_sourceCodeTile_titleText => '原碼';

  @override
  String get appAbout_issueTrackerTile_titleText => '問題/討論';

  @override
  String get appAbout_contactEmailTile_titleText => '聯絡我';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, 很高興你能夠聯絡我。\n如果反饋BUG需要注明版本並闡述複現流程\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => '開源許可';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache許可 版本2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => '第三方許可聲明';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => '捐贈';

  @override
  String get appAbout_donateTile_subTitleText => '我是一名個人開發者，如果你覺得這個應用好用，請幫我買一杯☕';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => '請我喝一杯咖啡';

  @override
  String get donateWay_alipay => '支付寶';

  @override
  String get donateWay_wechatPay => '微信';

  @override
  String get donateWay_cryptoCurrency => '加密貨幣';

  @override
  String get donateWay_cryptoCurrency_BTC => '比特幣';

  @override
  String get donateWay_cryptoCurrency_ETH => '以太坊';

  @override
  String get donateWay_cryptoCurrency_BNB => '幣安幣';

  @override
  String get donateWay_cryptoCurrency_AVAX => 'AVAX';

  @override
  String get donateWay_cryptoCurrency_FTM => 'FTM';

  @override
  String get donateWay_firstQRGroup => '支付寶與微信';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return '已複製$name地址';
  }

  @override
  String get batchCheckin_appbar_title => '批量打卡';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => '前一天';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => '後一天';

  @override
  String get batchCheckin_status_skip_text => '跳過';

  @override
  String get batchCheckin_status_ok_text => '完成';

  @override
  String get batchCheckin_status_double_text => '超量完成';

  @override
  String get batchCheckin_status_zero_text => '未完成';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    return '已選擇$count個習慣';
  }

  @override
  String get batchCheckin_save_button_text => '保存';

  @override
  String get batchCheckin_reset_button_text => '重置';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    return '已修改$count個習慣的狀態';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => '覆蓋現有記錄';

  @override
  String get batchCheckin_save_confirmDialog_body => '保存後將覆蓋現有記錄，之前記錄將丟失。';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => '保存';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => '取消';

  @override
  String get batchCheckin_close_confirmDialog_title => '確認返回';

  @override
  String get batchCheckin_close_confirmDialog_body => '未保存的打卡狀態更改將不會生效。';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => '確認';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => '取消';

  @override
  String get appReminder_dailyReminder_title => '🏝 你今天堅持了自己的習慣嗎？';

  @override
  String get appReminder_dailyReminder_body => '點擊進入應用並按時打卡。';

  @override
  String get common_habitColorType_cc1 => '紫羅蘭';

  @override
  String get common_habitColorType_cc2 => '紅色';

  @override
  String get common_habitColorType_cc3 => '紫色';

  @override
  String get common_habitColorType_cc4 => '皇家藍';

  @override
  String get common_habitColorType_cc5 => '深青';

  @override
  String get common_habitColorType_cc6 => '綠色';

  @override
  String get common_habitColorType_cc7 => '琥珀';

  @override
  String get common_habitColorType_cc8 => '橙色';

  @override
  String get common_habitColorType_cc9 => '酸橙綠';

  @override
  String get common_habitColorType_cc10 => '蘭花紫';

  @override
  String common_habitColorType_default(int index) {
    return '顏色-$index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => '使用系統格式';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => '日期格式';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => '年月日';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => '月日年';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => '日月年';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => '分隔符';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => '短橫線';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => '斜線';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => '空格';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => '點號';

  @override
  String get common_customDateTimeFormatPicker_empty_text => '無分隔符';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => '使用12小時制';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => '使用完整名稱';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => '對頻率圖表生效';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => '對補卡日曆生效';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => '取消';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => '確認';

  @override
  String get calendarPicker_clip_today => '今天';

  @override
  String get calendarPicker_clip_tomorrow => '明天';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return '下$dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => '匯出所有習慣？';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number個習慣',
      zero: '當前習慣',
    );
    return '匯出$_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => '包含習慣記錄';

  @override
  String get exportConfirmDialog_cancel_buttonText => '取消';

  @override
  String get exportConfirmDialog_confirm_buttonText => '匯出';

  @override
  String get debug_logLevelTile_title => '日誌級別';

  @override
  String get debug_logLevelDialog_title => '更改日誌級別';

  @override
  String get debug_logLevel_debug => '調試';

  @override
  String get debug_logLevel_info => '信息';

  @override
  String get debug_logLevel_warn => '警告';

  @override
  String get debug_logLevel_error => '錯誤';

  @override
  String get debug_logLevel_fatal => '致命';

  @override
  String get debug_collectLogTile_title => '正在收集日誌';

  @override
  String get debug_collectLogTile_enable_subtitle => '點擊停止日誌收集。';

  @override
  String get debug_collectLogTile_disable_subtitle => '點擊開始日誌收集。';

  @override
  String get debug_downladDebugLogs_subject => '下載調試日誌';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => '已清除調試日誌。';

  @override
  String get debug_downladDebugInfo_subject => '下載調試信息';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return '下載 $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => '調試日誌不存在。';

  @override
  String get debug_debuggerLogCard_title => '日誌信息';

  @override
  String get debug_debuggerLogCard_subtitle => '包括本地調試日誌信息，需要打開日誌收集開關。';

  @override
  String get debug_debuggerLogCard_saveButton_text => '下載';

  @override
  String get debug_debuggerLogCard_clearButton_text => '清除';

  @override
  String get debug_debuggerInfoCard_title => '調試信息';

  @override
  String get debug_debuggerInfoCard_subtitle => '包括應用程序的調試信息。';

  @override
  String get debug_debuggerInfoCard_openButton_text => '打開';

  @override
  String get debug_debuggerInfoCard_saveButton_text => '保存';

  @override
  String get debug_debuggerInfo_notificationTitle => '正在收集應用信息……';

  @override
  String get snackbar_undoText => '撤回';

  @override
  String get snackbar_dismissText => '忽略';

  @override
  String get contributors_tile_title => '貢獻者';

  @override
  String get userAction_tap => '點擊';

  @override
  String get userAction_doubleTap => '雙擊';

  @override
  String get userAction_longTap => '長按';
}
