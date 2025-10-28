// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class L10nVi extends L10n {
  L10nVi([String locale = 'vi']) : super(locale);

  @override
  String get localeScriptName => 'Tiếng Việt';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Lưu';

  @override
  String get habitEdit_habitName_hintText => 'Tên thói quen ...';

  @override
  String get habitEdit_colorPicker_title => 'Chọn màu sắc';

  @override
  String get habitEdit_habitTypeDialog_title => 'Loại thói quen';

  @override
  String get habitEdit_habitType_positiveText => 'Tích cực';

  @override
  String get habitEdit_habitType_negativeText => 'Tiêu cực';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Mục tiêu hàng ngày, mặc định $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Ngưỡng tối thiểu hàng ngày, mặc định $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'mục tiêu hàng ngày phải > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'mục tiêu hàng ngày phải ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'mục tiêu hàng ngày phải ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'mục tiêu hàng ngày phải ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Đơn vị mục tiêu hàng ngày';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Mục tiêu hàng ngày tối đa mong muốn';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'giá trị không hợp lệ, phải trống hoặc ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Giới hạn tối đa hàng ngày';

  @override
  String get habitEdit_frequencySelector_title => 'Chọn tần suất';

  @override
  String get habitEdit_habitFreq_daily => 'Hằng ngày';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'số lần mỗi tuần';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'số lần mỗi tháng';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'số lần mỗi';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'ngày';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Hằng ngày';

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
    return '$targetDays ngày';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Chọn ngày mục tiêu';

  @override
  String get habitEdit_targetDays => 'ngày';

  @override
  String get habitEdit_reminder_hintText => 'Lời nhắc nhở';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Bất kỳ ngày nào trong tuần';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' vào mỗi tuần';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Bất kỳ ngày nào trong tháng';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' vào mỗi tháng';

  @override
  String get habitEdit_reminderQuest_hintText => 'Câu hỏi, ví dụ: Hôm nay bạn có tập thể dục không?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Chọn loại lời nhắc';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Khi cần đánh dấu';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Hằng ngày';

  @override
  String get habitEdit_reminder_dialogType_week => 'Mỗi tuần';

  @override
  String get habitEdit_reminder_dialogType_month => 'Mỗi tháng';

  @override
  String get habitEdit_reminder_dialogConfirm => 'xác nhận';

  @override
  String get habitEdit_reminder_dialogCancel => 'hủy';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Xác nhận';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Bạn có xác nhận xóa lời nhắc này không';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'xác nhận';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'hủy';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'T.Hai';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'T.Ba';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'T.Tư';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'T.Năm';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'T.Sáu';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'T.Bảy';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'C.Nhật';

  @override
  String get habitEdit_desc_hintText => 'Bản ghi nhớ, hỗ trợ Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Đã tạo: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Đã sửa đổi: ';

  @override
  String get habitDisplay_fab_text => 'Thói quen mới';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Hành trình vạn dặm bắt đầu từ một bước chân';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Lưu trữ các thói quen đã chọn?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'xác nhận';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'hủy';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Đã lưu trữ $count thói quen';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Hủy lưu trữ các thói quen đã chọn?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'xác nhận';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'hủy';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Đã hủy lưu trữ $count thói quen';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Xóa các thói quen đã chọn?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'xác nhận';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'hủy';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Đã xóa $count thói quen';
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
  String get habitDisplay_editPopMenu_selectAll => 'Chọn tất cả';

  @override
  String get habitDisplay_editPopMenu_export => 'Xuất';

  @override
  String get habitDisplay_editPopMenu_delete => 'Xóa';

  @override
  String get habitDisplay_editPopMenu_clone => 'Bản mẫu';

  @override
  String get habitDisplay_editButton_tooltip => 'Biên tập';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Lưu trữ';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Hủy lưu trữ';

  @override
  String get habitDisplay_settingButton_tooltip => 'Thiết đặt';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Hiện tại';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Hoàn thành';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Trong tiến trình';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Đã lưu trữ';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Thói quen hàng đầu: Thay đổi trong 30 ngày qua';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Chủ đề sáng';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Chủ đề tối';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Theo hệ thống';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Hiển thị đã lưu trữ';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Hiển thị đã hoàn thành';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Hiển thị đã kích hoạt';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Thiết đặt';

  @override
  String get habitDisplay_sort_reverseText => 'Đảo ngược';

  @override
  String get habitDisplay_sortDirection_asc => '(Tăng)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Giảm)';

  @override
  String get habitDisplay_sortType_manual => 'Thứ tự của tôi';

  @override
  String get habitDisplay_sortType_name => 'Theo tên';

  @override
  String get habitDisplay_sortType_colorType => 'Theo màu sắc';

  @override
  String get habitDisplay_sortType_progress => 'Theo tỷ lệ';

  @override
  String get habitDisplay_sortType_startT => 'Theo ngày bắt đầu';

  @override
  String get habitDisplay_sortType_status => 'Theo trạng thái';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sắp xếp';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'xác nhận';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'hủy';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Gỡ lỗi';

  @override
  String get habitDisplay_searchBar_hintText => 'Search habits';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Ongoing';

  @override
  String get habitDisplay_searchFilter_ongoing_desc => 'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'Hoàn thành';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Loại thói quen';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Show Filters';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clear Filters';

  @override
  String get habitDetail_editButton_tooltip => 'Biên tập';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Hủy lưu trữ';

  @override
  String get habitDetail_editPopMenu_archive => 'Lưu trữ';

  @override
  String get habitDetail_editPopMenu_export => 'Xuất';

  @override
  String get habitDetail_editPopMenu_delete => 'Xóa';

  @override
  String get habitDetail_editPopMenu_clone => 'Bản mẫu';

  @override
  String get habitDetail_confirmDialog_confirm => 'xác nhận';

  @override
  String get habitDetail_confirmDialog_cancel => 'hủy';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Lưu trữ thói quen ?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Hủy lưu trữ thói quen?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Xóa thói quen?';

  @override
  String get habitDetail_summary_title => 'Bản tóm tắt';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Điểm hiện tại là $score và đã $days ngày kể từ khi bắt đầu.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Start in $days days.',
      one: 'Starting tomorrow.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'SUBSTANDARD',
      one: 'INCOMPLETE',
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
      one: 'OVERFULFIL',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Goal',
      two: 'Threshold',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Đơn vị $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'vô giá trị';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Days',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'd';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Hồ sơ';

  @override
  String get habitDetail_scoreChart_title => 'Điểm';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Ngày';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Tuần';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Tháng';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Năm';

  @override
  String get habitDetail_freqChart_freqTitle => 'Tần suất';

  @override
  String get habitDetail_freqChart_historyTitle => 'Lịch sử';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Tần suất & Lịch sử';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Tuần';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Tháng';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Năm';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Bây giờ';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Ẩn biểu đồ lịch sử';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Hiện biểu đồ lịch sử';

  @override
  String get habitDetail_descSubgroup_title => 'Bản ghi nhớ';

  @override
  String get habitDetail_otherSubgroup_title => 'Khác';

  @override
  String get habitDetail_habitType_title => 'Kiểu';

  @override
  String get habitDetail_reminderTile_title => 'Lời nhắc nhở';

  @override
  String get habitDetail_freqTile_title => 'Lặp lại';

  @override
  String get habitDetail_startDateTile_title => 'Ngày bắt đầu';

  @override
  String get habitDetail_createDateTile_title => 'Đã tạo';

  @override
  String get habitDetail_modifyDateTile_title => 'Đã sửa đổi';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'ngày';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'giá trị';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'trở lại ngày hôm nay';

  @override
  String get habitDetail_notFoundText => 'Tải thói quen thất bại';

  @override
  String get habitDetail_notFoundRetryText => 'Thử lại';

  @override
  String get habitDetail_changeGoal_title => 'Thay đổi mục tiêu';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'hiện tại: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'xong: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'hoàn tác';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Mục tiêu hàng ngày, mặc định: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'hủy';

  @override
  String get habitDetail_changeGoal_saveText => 'lưu';

  @override
  String get habitDetail_skipReason_title => 'Lý do bỏ qua';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Viết gì đó vào đây...';

  @override
  String get habitDetail_skipReason_cancelText => 'hủy';

  @override
  String get habitDetail_skipReason_saveText => 'lưu';

  @override
  String get appSetting_appbar_titleText => 'Thiết đặt';

  @override
  String get appSetting_displaySubgroupText => 'Hiển thị';

  @override
  String get appSetting_operationSubgroupText => 'Vận hành';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Kéo lịch theo trang';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Nếu nút chuyển được bật, lịch thanh ứng dụng trên trang chủ sẽ được kéo theo trang. Theo mặc định, nút chuyển bị tắt.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Thay đổi trạng thái bản ghi';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Sửa đổi hành vi nhấp chuột để thay đổi trạng thái của bản ghi hàng ngày trên trang chính.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Mở bản ghi chi tiết';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Sửa đổi hành vi nhấp chuột để mở cửa sổ bật lên chi tiết cho các bản ghi hàng ngày trên trang chính.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Ngày đầu tuần';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Hiển thị ngày đầu tuần';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Mặc định)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Theo hệ thống ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'Theo hệ thống';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Ngôn ngữ';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Chọn ngôn ngữ';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Định dạng hiển thị ngày ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'theo thiết đặt hệ thống';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Định dạng ngày đã định cấu hình sẽ được áp dụng cho hiển thị ngày trên trang chi tiết thói quen.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Bật giao diện người dùng nhỏ gọn trên trang thói quen';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Cho phép bảng kiểm tra thói quen hiển thị nhiều nội dung hơn nhưng một số giao diện người dùng và văn bản có thể trông nhỏ hơn.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Thói quen kiểm tra khu vực điều chỉnh đài phát thanh';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Điều chỉnh tỷ lệ phần trăm để có thêm/ít không gian hơn trong khu vực bảng kiểm tra thói quen.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Mặc định';

  @override
  String get appSetting_reminderSubgroupText => 'Lời nhắc nhở';

  @override
  String get appSetting_dailyReminder_titleText => 'Nhắc nhở hàng ngày';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Sao lưu & khôi phục';

  @override
  String get appSetting_export_titleText => 'Xuất';

  @override
  String get appSetting_export_subtitleText => 'Đã xuất thói quen ở định dạng JSON, Tệp này có thể được nhập lại.';

  @override
  String get appSetting_import_titleText => 'Nhập';

  @override
  String get appSetting_import_subtitleText => 'Nhập thói quen từ tệp json.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Xác nhận nhập $count thói quen?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Lưu ý: Quá trình nhập không xóa các thói quen hiện có.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'xác nhận';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'hủy';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Đã nhập $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Hoàn tất nhập $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'đóng';

  @override
  String get appSetting_resetConfig_titleText => 'Đặt lại cấu hình';

  @override
  String get appSetting_resetConfig_subtitleText => 'Đặt lại tất cả cấu hình về mặc định.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Đặt lại cấu hình?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Đặt lại tất cả cấu hình về mặc định, phải khởi động lại ứng dụng để áp dụng.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'hủy';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'xác nhận';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'đặt lại cấu hình ứng dụng thành công';

  @override
  String get appSetting_otherSubgroupText => 'Khác';

  @override
  String get appSetting_developMode_titleText => 'Chế độ phát triển';

  @override
  String get appSetting_clearCache_titleText => 'Xóa bộ nhớ đệm';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Xóa bộ nhớ đệm';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Sau khi xóa bộ nhớ đệm, một số giá trị tùy chỉnh sẽ được khôi phục về mặc định.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'hủy';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'xác nhận';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Xóa một phần bộ nhớ đệm không thành công';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Xóa bộ nhớ đệm thành công';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Xóa bộ nhớ đệm không thành công';

  @override
  String get appSetting_debugger_titleText => 'Thông tin gỡ lỗi';

  @override
  String get appSetting_about_titleText => 'Giới thiệu';

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
  String get appAbout_appbarTile_titleText => 'Giới thiệu';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Phiên bản: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Mã nguồn';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Người theo dõi vấn đề';

  @override
  String get appAbout_contactEmailTile_titleText => 'Liên hệ với tôi';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Xin chào, tôi rất vui vì bạn đã liên hệ với tôi.\nNếu bạn đang báo cáo lỗi, vui lòng cho biết phiên bản ứng dụng và mô tả các bước để tái tạo lỗi đó.\n------------- -------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Giấy phép';

  @override
  String get appAbout_licenseTile_subtitleText => 'Giấy phép Apache, Phiên bản 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Tuyên bố cấp phép của bên thứ ba';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Privacy';

  @override
  String get appAbout_privacyTile_subTitleText => 'Access the privacy policy in this app';

  @override
  String get appAbout_donateTile_titleText => 'Quyên tặng';

  @override
  String get appAbout_donateTile_subTitleText => 'Tôi là nhà phát triển cá nhân. Nếu bạn thích ứng dụng này, vui lòng mua cho tôi một ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Mua cho tôi một ly cà phê';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Tiền tệ điện tử';

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
    return 'Đã sao chép địa chỉ của $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Check-in Nhóm';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Ngày trước';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Ngày sau';

  @override
  String get batchCheckin_status_skip_text => 'Bỏ qua';

  @override
  String get batchCheckin_status_ok_text => 'Hoàn thành';

  @override
  String get batchCheckin_status_double_text => 'Đạt gấp đôi!';

  @override
  String get batchCheckin_status_zero_text => 'Chưa hoàn thành';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'thói quen',
      one: 'thói quen',
    );
    return '$count $_temp0 đã chọn';
  }

  @override
  String get batchCheckin_save_button_text => 'Lưu';

  @override
  String get batchCheckin_reset_button_text => 'Đặt lại';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'status of $count habits',
      one: 'habit\'s status',
    );
    return 'Đã sửa đổi $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'Ghi đè các bản ghi hiện có';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Các bản ghi hiện có sẽ bị ghi đè. Sau khi lưu, các bản ghi trước đó sẽ bị mất.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'Lưu';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'Hủy';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Xác nhận Quay lại';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Các thay đổi trạng thái check-in sẽ không được áp dụng trước khi được lưu.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'Thoát';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'Hủy';

  @override
  String get appReminder_dailyReminder_title => '🏝 Hôm nay bạn có giữ thói quen của mình không?';

  @override
  String get appReminder_dailyReminder_body => 'nhấp để vào ứng dụng và đăng nhập đúng giờ.';

  @override
  String get common_habitColorType_cc1 => 'Tím đậm';

  @override
  String get common_habitColorType_cc2 => 'Đỏ';

  @override
  String get common_habitColorType_cc3 => 'Tím';

  @override
  String get common_habitColorType_cc4 => 'Xanh hoàng gia';

  @override
  String get common_habitColorType_cc5 => 'Lục lam đậm';

  @override
  String get common_habitColorType_cc6 => 'Xanh lá';

  @override
  String get common_habitColorType_cc7 => 'Hổ phách';

  @override
  String get common_habitColorType_cc8 => 'Cam';

  @override
  String get common_habitColorType_cc9 => 'Xanh chanh';

  @override
  String get common_habitColorType_cc10 => 'Tím tối';

  @override
  String common_habitColorType_default(int index) {
    return 'Màu $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Sử dụng định dạng hệ thống';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Định dạng ngày tháng';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Năm Tháng Ngày';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Tháng Ngày Năm';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Ngày Tháng Năm';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Dấu phân cách';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Dấu gạch ngang';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Dấu gạch chéo';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Dấu cách';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Dấu chấm';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Không dấu phân cách';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Sử dụng định dạng 12 giờ';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Sử dụng tên đầy đủ';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Áp dụng cho biểu đồ tần suất';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Áp dụng cho Lịch';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'hủy';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'xác nhận';

  @override
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

  @override
  String get calendarPicker_clip_today => 'Hôm nay';

  @override
  String get calendarPicker_clip_tomorrow => 'Ngày mai';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString kế tiếp';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Xuất tất cả thói quen?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number habits',
      one: '1 habit',
      zero: 'current habit',
    );
    return 'Xuất $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'bao gồm hồ sơ';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'hủy';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'xuất';

  @override
  String get debug_logLevelTile_title => 'Cấp độ ghi nhật ký';

  @override
  String get debug_logLevelDialog_title => 'Thay đổi cấp độ ghi nhật ký';

  @override
  String get debug_logLevel_debug => 'Gỡ lỗi';

  @override
  String get debug_logLevel_info => 'Thông tin';

  @override
  String get debug_logLevel_warn => 'Cảnh báo';

  @override
  String get debug_logLevel_error => 'Lỗi';

  @override
  String get debug_logLevel_fatal => 'Fatal';

  @override
  String get debug_collectLogTile_title => 'Thu thập nhật ký';

  @override
  String get debug_collectLogTile_enable_subtitle => 'Nhấn để dừng thu thập nhật ký.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Nhấn để bắt đầu thu thập nhật ký.';

  @override
  String get debug_downladDebugLogs_subject => 'Đang tải xuống nhật ký gỡ lỗi';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Đã dọn nhật ký gỡ lỗi.';

  @override
  String get debug_downladDebugInfo_subject => 'Đang tải xuống thông tin gỡ lỗi';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Đang tải xuống $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Nhật ký gỡ lỗi không tồn tại.';

  @override
  String get debug_debuggerLogCard_title => 'Thông tin nhật ký';

  @override
  String get debug_debuggerLogCard_subtitle => 'Bao gồm thông tin nhật ký gỡ lỗi cục bộ, cần bật trình chuyển đổi bộ sưu tập nhật ký.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Tải xuống';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Dọn';

  @override
  String get debug_debuggerInfoCard_title => 'Thông tin gỡ lỗi';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Bao gồm thông tin gỡ lỗi của ứng dụng.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Mở';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Lưu';

  @override
  String get debug_debuggerInfo_notificationTitle => 'Đang thu thập thông tin của ứng dụng...';

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
  String get snackbar_undoText => 'HOÀN TÁC';

  @override
  String get snackbar_dismissText => 'MIỄN';

  @override
  String get contributors_tile_title => 'Cộng tác viên';

  @override
  String get userAction_tap => 'Nhấn';

  @override
  String get userAction_doubleTap => 'Đúp';

  @override
  String get userAction_longTap => 'Lâu';

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
