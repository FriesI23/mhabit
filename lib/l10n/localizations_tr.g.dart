// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class L10nTr extends L10n {
  L10nTr([String locale = 'tr']) : super(locale);

  @override
  String get localeScriptName => 'Türkçe';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Kaydet';

  @override
  String get habitEdit_habitName_hintText => 'Alışkanlık Adı ...';

  @override
  String get habitEdit_colorPicker_title => 'Renk seç';

  @override
  String get habitEdit_colorPicker_historySectionLabel => 'Recently used';

  @override
  String habitEdit_colorPicker_customSectionLabel(String tinted) {
    String _temp0 = intl.Intl.selectLogic(tinted, {
      'true': 'Custom (Tinted)',
      'false': 'Custom',
      'other': 'Custom',
    });
    return '$_temp0';
  }

  @override
  String get habitEdit_colorPicker_cancel => 'Cancel';

  @override
  String get habitEdit_colorPicker_tintToggleLabel => 'Tint to theme';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Tinted';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Not tinted';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'Tinting may shift the final color away from the one you picked.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Some colors may reduce text readability in light or dark theme.';

  @override
  String get habitEdit_habitTypeDialog_title => 'Alışkanlık türü';

  @override
  String get habitEdit_habitType_positiveText => 'Olumlu';

  @override
  String get habitEdit_habitType_negativeText => 'Olumsuz';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Günlük hedef, varsayılan $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Günlük alt sınır, varsayılan $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Günlük hedef $number\'den büyük olmalı';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Günlük hedef en fazla $number olabilir';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Günlük hedef en az $number olabilir';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'Günlük hedef en fazla $number olabilir';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Günlük hedef birimi';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'İstenilen maksimum günlük hedef';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Geçersiz değer, boş bırakılmalı ya da $dailyGoal\'den büyük veya eşit olmalı';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Maksimum günlük limit';

  @override
  String get habitEdit_frequencySelector_title => 'Sıklık seç';

  @override
  String get habitEdit_habitFreq_daily => 'Günlük';

  @override
  String get habitEdit_habitFreq_perweek_text => '%%time%% kez haftada';

  @override
  String get habitEdit_habitFreq_permonth_text => '%%time%% kez ayda';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      '%%time%% gün %%day%% günde';

  @override
  String get habitEdit_habitFreq_show_daily => 'Günlük';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Haftada en az $freq kez',
      one: 'Haftada bir',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Ayda en az $freq kez',
      one: 'Ayda bir',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Her $days günde en az $freq kez',
      one: 'Her $days günde bir',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays gün';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Hedef Günleri Seçin';

  @override
  String get habitEdit_targetDays => 'gün';

  @override
  String get habitEdit_reminder_hintText => 'Hatırlatıcı';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Haftanın her günü';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days her hafta';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Ayın her günü';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days her ay';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Soru, örn. Bugün egzersiz yaptın mı?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Hatırlatıcı tipi seç';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Tamamlanması gerektiğinde';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Günlük';

  @override
  String get habitEdit_reminder_dialogType_week => 'Haftalık';

  @override
  String get habitEdit_reminder_dialogType_month => 'Aylık';

  @override
  String get habitEdit_reminder_dialogConfirm => 'onayla';

  @override
  String get habitEdit_reminder_dialogCancel => 'iptal et';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Onayla';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Bu hatırlatıcıyı silmeyi onaylıyor musunuz';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'onayla';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'iptal et';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Pzt';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Sal';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Çar';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Per';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Cum';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Cmt';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Paz';

  @override
  String get habitEdit_desc_hintText => 'Not, Markdown desteklenir';

  @override
  String get habitEdit_create_datetime_prefix => 'Oluşturuldu: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Düzenlendi: ';

  @override
  String get habitDisplay_fab_text => 'Yeni Alışkanlık';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'Uzun bir yolculuk, ilk adımla başlar';

  @override
  String get habitDisplay_notFoundImage_text_01 =>
      'Eşleşen alışkanlık bulunamadı';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return '\"$keyword\" için eşleşen alışkanlık bulunamadı';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Seçilen Alışkanlıkları Arşivle?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'onayla';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'iptal et';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count alışkanlık arşivlendi';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Seçilen Alışkanlıkları Arşivden Çıkar?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'onayla';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'iptal et';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count alışkanlık arşivden çıkarıldı';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Seçilen Alışkanlıkları Sil?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'onayla';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'iptal et';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count alışkanlık silindi';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Alışkanlık silindi: “$name”';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alışkanlık dışa aktarıldı.',
      one: 'Alışkanlık dışa aktarıldı.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Bütün Alışkanlıklar Dışa Aktarıldı';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Hepsini Seç';

  @override
  String get habitDisplay_editPopMenu_export => 'Dışa aktar';

  @override
  String get habitDisplay_editPopMenu_delete => 'Sil';

  @override
  String get habitDisplay_editPopMenu_clone => 'Şablon';

  @override
  String get habitDisplay_editButton_tooltip => 'Düzenle';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Arşivle';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Arşivden çıkar';

  @override
  String get habitDisplay_settingButton_tooltip => 'Ayar';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Güncel';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Tamamlandı';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Sürüyor';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Arşivlendi';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'En İyi Alışkanlıklar: Son 30 Gündeki Değişiklikler';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Açık Tema';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Koyu Tema';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Sistemi İzle';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Arşivlenenleri Göster';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText =>
      'Tamamlananları Göster';

  @override
  String get habitDisplay_mainMenu_showActivedTileText =>
      'Aktif Olanları Göster';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Ayarlar';

  @override
  String get habitDisplay_sort_reverseText => 'Ters çevir';

  @override
  String get habitDisplay_sortDirection_asc => '(Yükselen)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Alçalan)';

  @override
  String get habitDisplay_sortType_manual => 'Benim sıralamam';

  @override
  String get habitDisplay_sortType_name => 'Ada göre';

  @override
  String get habitDisplay_sortType_colorType => 'Renge göre';

  @override
  String get habitDisplay_sortType_progress => 'Orana göre';

  @override
  String get habitDisplay_sortType_startT => 'Başlangıç tarihine göre';

  @override
  String get habitDisplay_sortType_status => 'Duruma göre';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sırala';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'onayla';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'iptal et';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Hata ayıkla';

  @override
  String get habitDisplay_searchBar_hintText => 'Alışkanlık ara';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Devam eden';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Şu anda aktif ve devam eden alışkanlıkları gösterir (arşivlenmemiş veya silinmemiş).';

  @override
  String get habitDisplay_searchFilter_completed => 'Tamamlandı';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle =>
      'Alışkanlık türü';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Filtreleri Göster';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Filtreleri Temizle';

  @override
  String get habitDisplay_tab_habits_label => 'Alışkanlıklar';

  @override
  String get habitDisplay_tab_today_label => 'Bugün';

  @override
  String get habitToday_appBar_title => 'Bugün';

  @override
  String get habitToday_image_desc => 'BAŞARDIN';

  @override
  String habitToday_card_subtitle_text(int days) {
    return '$days gündür devam ediyor';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Tamamla+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Geç+';

  @override
  String get habitDetail_editButton_tooltip => 'Düzenle';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Arşivden çıkar';

  @override
  String get habitDetail_editPopMenu_archive => 'Arşivle';

  @override
  String get habitDetail_editPopMenu_export => 'Dışa aktar';

  @override
  String get habitDetail_editPopMenu_delete => 'Sil';

  @override
  String get habitDetail_editPopMenu_clone => 'Şablon';

  @override
  String get habitDetail_confirmDialog_confirm => 'onayla';

  @override
  String get habitDetail_confirmDialog_cancel => 'iptal et';

  @override
  String get habitDetail_archiveConfirmDialog_titleText =>
      'Alışkanlığı Arşivle?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Alışkanlığı Arşivden Çıkar?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Alışkanlığı Sil?';

  @override
  String get habitDetail_summary_title => 'Özet';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Mevcut puan $score, başlangıçtan bu yana $days gün geçti.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gün sonra başlayacak.',
      one: 'Yarın başlıyor.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'YETERSİZ',
      one: 'TAMAMLANMADI',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'KUSURSUZ',
      one: 'FAZLASIYLA TAMAMLANDI',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Hedef',
      two: 'Eşik Değeri',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Birim: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'boş';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Günler',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'g';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Kayıtlar';

  @override
  String get habitDetail_scoreChart_title => 'Puan';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Gün';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Hafta';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Ay';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Yıl';

  @override
  String get habitDetail_freqChart_freqTitle => 'Sıklık';

  @override
  String get habitDetail_freqChart_historyTitle => 'Geçmiş';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Sıklık & Geçmiş';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Hafta';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Ay';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Yıl';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Şimdi';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Geçmiş Grafiğini Gizle';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Geçmiş Grafiğini Göster';

  @override
  String get habitDetail_descSubgroup_title => 'Not';

  @override
  String get habitDetail_otherSubgroup_title => 'Diğer';

  @override
  String get habitDetail_habitType_title => 'Tür';

  @override
  String get habitDetail_reminderTile_title => 'Hatırlatıcı';

  @override
  String get habitDetail_freqTile_title => 'Tekrar';

  @override
  String get habitDetail_startDateTile_title => 'Başlangıç Tarihi';

  @override
  String get habitDetail_createDateTile_title => 'Oluşturuldu';

  @override
  String get habitDetail_modifyDateTile_title => 'Düzenlendi';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'tarih';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'değer';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'bugüne geri dön';

  @override
  String get common_loadError_text => 'Yüklenemedi';

  @override
  String get common_loadError_retryText => 'Tekrar dene';

  @override
  String get habitDetail_notFoundText => 'Alışkanlığı yükleme başarısız oldu';

  @override
  String get habitDetail_notFoundRetryText => 'Tekrar dene';

  @override
  String get habitDetail_changeGoal_title => 'Hedefi değiştir';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'güncel: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'tamamlanan: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'tamamlanmamış';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Günlük hedef, varsayılan: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'iptal et';

  @override
  String get habitDetail_changeGoal_saveText => 'kaydet';

  @override
  String get habitDetail_skipReason_title => 'Sebebi geç';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Buraya bir şey yaz...';

  @override
  String get habitDetail_skipReason_cancelText => 'iptal et';

  @override
  String get habitDetail_skipReason_saveText => 'kaydet';

  @override
  String get appSetting_appbar_titleText => 'Ayarlar';

  @override
  String get appSetting_displaySubgroupText => 'Görünüm';

  @override
  String get appSetting_operationSubgroupText => 'Kullanım';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Takvimi sayfa sayfa kaydır';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Bu özellik etkinleştirildiğinde, ana sayfadaki uygulama çubuğu takvimi sayfa sayfa kaydırılacaktır. Varsayılan olarak kapalıdır.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Kayıt Durumunu Değiştir';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Ana sayfadaki günlük kayıtların durumunu değiştirmek için tıklama davranışını düzenleyin.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Detaylı Kaydı Aç';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Ana sayfadaki günlük kayıtların detaylı penceresini açmak için tıklama davranışını ayarlayın.';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Tema Rengi';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText => 'Tema Rengi Seç';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Duvar kağıdının ana rengini kullan (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'GTK+ temasının seçili arka plan rengini kullan';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Sistem tema rengini kullan';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Sistem vurgu veya pencere/cam rengini kullan';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Haftanın ilk günü';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Haftanın ilk gününü göster';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Varsayılan)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Sistemi İzle ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Sistemi İzle';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Dil';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Dil Seç';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Tarih gösterim biçimi ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'sistem ayarını izle';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Yapılandırılan tarih formatı, alışkanlık detay sayfasındaki tarih gösterimine uygulanacaktır.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Alışkanlıklar sayfasında Kompakt Kullanıcı Arayüzünü etkinleştir';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Alışkanlıklar kontrol tablosunun daha fazla içerik görüntülemesine izin verin, ancak bazı kullanıcı arayüzü ve metinler daha küçük görünebilir.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Alışkanlık işaretleme alanı boyut ayarı';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Alışkanlık işaretleme tablo alanında daha fazla/az alan için yüzdeyi ayarlayın.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Varsayılan';

  @override
  String get appSetting_reminderSubgroupText => 'Hatırlatıcı & Bildirim';

  @override
  String get appSetting_dailyReminder_titleText => 'Günlük hatırlatıcı';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Yedekleme & geri yükleme';

  @override
  String get appSetting_export_titleText => 'Dışa aktar';

  @override
  String get appSetting_export_subtitleText =>
      'Dışa aktarılan alışkanlıklar JSON formatındadır, bu dosya geri içe aktarılabilir.';

  @override
  String get appSetting_import_titleText => 'İçe aktar';

  @override
  String get appSetting_import_subtitleText =>
      'Alışkanlıkları JSON dosyadan içe aktar.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return '$count alışkanlıkları içe aktarmayı onayla?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Not: İçe aktarma, mevcut alışkanlıkları silmez.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'onayla';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'iptal et';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'İçe aktarıldı $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'İçe aktarılan $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'kapat';

  @override
  String get appSetting_resetConfig_titleText => 'Yapılandırmaları sıfırla';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Tüm yapılandırmaları varsayılana sıfırla.';

  @override
  String get appSetting_resetConfigDialog_titleText =>
      'Yapılandırmaları sıfırla?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Tüm yapılandırmaları varsayılana sıfırla, uygulamak için uygulama yeniden başlatılmalıdır.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'iptal et';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'onayla';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'uygulama yapılandırmalarını sıfırlama başarılı';

  @override
  String get appSetting_otherSubgroupText => 'Diğer';

  @override
  String get appSetting_developMode_titleText => 'Geliştirici Modu';

  @override
  String get appSetting_clearCache_titleText => 'Önbelleği Temizle';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Önbelleği Temizle';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Önbellek temizlendikten sonra, bazı özel değerler varsayılan değerlere geri yüklenir.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'iptal et';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'onayla';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Kısmi önbellek temizlenemedi';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Önbellek başarıyla temizlendi';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Önbellek temizlenemedi';

  @override
  String get appSetting_debugger_titleText => 'Hata Ayıklama Bilgisi';

  @override
  String get appSetting_about_titleText => 'Hakkında';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Deneysel Özellikler';

  @override
  String get appSetting_synSubgroupText => 'Eşleme';

  @override
  String get appSetting_syncOption_titleText => 'Eşleme Ayarları';

  @override
  String get appSetting_notify_titleTile => 'Bildirimler';

  @override
  String get appSetting_notify_subtitleTile => 'Bildirim tercihlerini düzenle';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Sistem bildirim ayarlarını açmak için dokun';

  @override
  String get appSync_nowTile_titleText => 'Şimdi Eşle';

  @override
  String get appSync_nowTile_titleText_syncing => 'Eşleniyor';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate => 'Son eşleme: Yok';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Son eşleme: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate => 'Son eşleme (Hata): Yok';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Son eşleme (Hata): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Eşleniyor...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Eşleniyor: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'İptal ediliyor...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Son eşleme (İptal edildi): Yok';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Son eşleme (İptal edildi): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Hata Kayıtlarını Kontrol Et';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Hata]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Tamamlandı',
      'cancelled': 'İptal edildi',
      'failed': 'Başarısız',
      'multi': 'Birden fazla durum',
      'other': 'Bilinmeyen durum',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': '$reason nedeniyle tamamlandı',
      'cancelled': '$reason nedeniyle iptal edildi',
      'failed': '$reason nedeniyle başarısız oldu',
      'multi': '$reason nedeniyle birden fazla durum oluştu',
      'other': 'Bilinmeyen durum',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Hata',
      'userAction': 'Kullanıcı müdahalesi gerekli',
      'missingHabitUuid': 'Alışkanlık UUID\'si eksik',
      'empty': 'Boş veri',
      'other': 'Bilinmeyen neden',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText => 'Yeni Konum';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Eşleme gerekli klasörleri oluşturacak ve yerel alışkanlıkları sunucuya yükleyecek. Devam edilsin mi?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText => 'Şimdi Eşle!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Eşlemeyi Onayla';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Klasör boş değil. Eşleme, sunucu ve yerel alışkanlıkları birleştirecek. Devam edilsin mi?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Birleştirmeyi Onayla';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Hatalı Eşleme Kayıtlarını Dışa Aktar';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'Kayıt bulunamadı',
      'false': 'Dışa aktarmak için dokunun',
      'other': 'yükleniyor...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Mevcut: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Test (Sadece Geliştirici İçin)',
      'other': 'Bilinmeyen ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Mobil',
      'wifi': 'Wifi',
      'other': 'Bilinmeyen',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Manuel',
      'minute5': '5 Dakika',
      'minute15': '15 Dakika',
      'minute30': '30 Dakika',
      'hour1': '1 Saat',
      'other': 'Bilinmeyen',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Senkronizasyon Sıklığı';

  @override
  String get appSync_summaryTile_title => 'Eşleme Sunucusu';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Yapılandırılmadı';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Tüm son başarısız eşleme kayıtları';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Değişiklikleri Kaydetmeyi Onayla';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Kaydetme işlemi önceki sunucu yapılandırmasının üzerine yazacaktır.';

  @override
  String get appSync_serverEditor_exitDialog_titleText =>
      'Kaydedilmemiş Değişiklikler';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Çıkıldığında kaydedilmemiş tüm değişiklikler silinir.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText => 'Silmeyi Onayla';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Silme işlemi mevcut sunucu yapılandırmasını kaldıracaktır.';

  @override
  String get appSync_serverEditor_titleText_add => 'Yeni Eşleme Sunucusu';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Eşleme Sunucusunu Değiştir';

  @override
  String get appSync_serverEditor_advance_titleText =>
      'Gelişmiş Yapılandırmalar';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Yol';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Buraya geçerli bir WebDAV yolu girin.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Yol boş olmamalı!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Kullanıcı adı';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Buraya kullanıcı adını girin, gerekli değilse boş bırakın.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Parola';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'SSL sertifikasını yok say';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Senkronizasyon Zaman Aşımı (Saniye)';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Infinite',
    );
    return 'Varsayılan: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 'sn';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Ağ Bağlantısı Zaman Aşımı (Saniye)';

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
    return 'Varsayılan: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 'sn';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Ağ bağlantısı yeniden deneme sayısı';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Retry disabled',
    );
    return 'Varsayılan: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText => 'Ağ eşleme kipi';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Hücresel ağda eşleme',
      'wifi': 'WiFi\'de eşleme',
      'other': 'Bilinmiyor',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText => 'Düşük Veri';

  @override
  String get appSync_noti_readyToSync_body => 'Eşitlemeye hazırlanıyor...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Eşitlendi ($type)',
      'failed': 'Eşitleme Başarısız ($type)',
      'other': 'Eşitleniyor ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Düşük veri kipinde eşle';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Bir veya daha fazla deneysel özellik etkinleştirilir, dikkatli kullanın.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Alışkanlık bulut eşlemesi';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Etkinleştirildikten sonra, uygulamanın eşleme seçeneği ayarlarda görünecektir';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Deneysel özellik ($syncName) devre dışı bırakılır, ancak işlev hala çalışıyor.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Tamamen devre dışı bırakmak için \'$menuName\' a erişmek ve kapatmak için uzun basın.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText => 'Alışkanlık Ara';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Etkinleştirildiğinde, Alışkanlıklar ekranının üstünde bir arama çubuğu görünecek ve alışkanlıkları aramanızı sağlayacaktır.';

  @override
  String get appAbout_appbarTile_titleText => 'Hakkında';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Versiyon: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Kaynak kodu';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Hata izleyici';

  @override
  String get appAbout_contactEmailTile_titleText => 'Bana ulaş';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Merhaba, Bana yazdığın için memnunum.\nEğer bir hata bildiriyorsan, lütfen uygulama versiyonunu belirt ve hatayı ortaya çıkaran adımları açıkla.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Lisans';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Üçüncü Taraf Lisanslama Bildirimi';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Gizlilik';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Uygulamadaki gizlilik politikasına erişin';

  @override
  String get appAbout_donateTile_titleText => 'Bağış yap';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Ben kişisel bir geliştiriciyim. Bu uygulamayı beğendiyseniz, lütfen bana bir ☕ satın alın.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Bana bir kahve ısmarla';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Kripto Paralar';

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
    return '$name\'in adresi kopyalandı';
  }

  @override
  String get batchCheckin_appbar_title => 'Toplu Giriş';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Önceki gün';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Sonraki gün';

  @override
  String get batchCheckin_status_skip_text => 'Geç';

  @override
  String get batchCheckin_status_ok_text => 'Tamamlandı';

  @override
  String get batchCheckin_status_double_text => 'x2 Başarı!';

  @override
  String get batchCheckin_status_zero_text => 'Tamamlanmadı';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alışkanlıklar',
      one: 'Alışkanlık',
    );
    return '$count $_temp0 seçildi';
  }

  @override
  String get batchCheckin_save_button_text => 'Kaydet';

  @override
  String get batchCheckin_reset_button_text => 'Sıfırla';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alışkanlığın durumu',
      one: 'Alışkanlık durumu',
    );
    return '$_temp0 güncellendi';
  }

  @override
  String get batchCheckin_save_confirmDialog_title =>
      'Mevcut Kayıtların Üzerine Yaz';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Kaydedildikten sonra mevcut kayıtların üzerine yazılacak, önceki kayıtlar kaybolacak.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'kaydet';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'iptal et';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Dönüşü Onayla';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Giriş durumu değişiklikleri kaydedilmeden uygulanmayacak';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'çıkış';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'iptal et';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Bugün alışkanlıklarınıza bağlı kaldınız mı?';

  @override
  String get appReminder_dailyReminder_body =>
      'Uygulamayı açıp zamanında giriş yapmak için tıklayın.';

  @override
  String get common_habitColorType_cc1 => 'Koyu leylak';

  @override
  String get common_habitColorType_cc2 => 'Kırmızı';

  @override
  String get common_habitColorType_cc3 => 'Mor';

  @override
  String get common_habitColorType_cc4 => 'Kraliyet mavisi';

  @override
  String get common_habitColorType_cc5 => 'Koyu camgöbeği';

  @override
  String get common_habitColorType_cc6 => 'Yeşil';

  @override
  String get common_habitColorType_cc7 => 'Kehribar';

  @override
  String get common_habitColorType_cc8 => 'Turuncu';

  @override
  String get common_habitColorType_cc9 => 'Limon yeşili';

  @override
  String get common_habitColorType_cc10 => 'Koyu orkide';

  @override
  String get common_habitColorType_custom => 'Custom';

  @override
  String common_habitColorType_default(int index) {
    return 'Renk $index';
  }

  @override
  String get common_appThemeColor_system => 'Sistem';

  @override
  String get common_appThemeColor_primary => 'Ana renk';

  @override
  String get common_appThemeColor_dynamic => 'Dinamik';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Sistem formatını kullan';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Tarih formatı';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Yıl Ay Gün';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Ay Gün Yıl';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Gün Ay Yıl';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Ayırıcı';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Tire';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Eğik çizgi';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Boşluk';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Nokta';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Ayırıcı yok';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      '12 saatlik formatı kullan';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Tam adı kullan';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Sıklık Grafiğine Uygula';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Takvime Uygula';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'iptal et';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'onayla';

  @override
  String get common_errorPage_title => 'Tüh, çöktü!';

  @override
  String get common_errorPage_copied => 'Çökme bilgileri kopyalandı';

  @override
  String get common_enable_text => 'Etkinleştirildi';

  @override
  String get calendarPicker_clip_today => 'Bugün';

  @override
  String get calendarPicker_clip_tomorrow => 'Yarın';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Sonraki $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'Bütün alışkanlıkları dışa aktar?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number alışkanlık',
      one: '1 alışkanlık',
      zero: 'mevcut alışkanlık',
    );
    return '$_temp0 dışa aktar?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'kayıtları dahil et';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'iptal et';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'dışa aktar';

  @override
  String get debug_logLevelTile_title => 'Günlük Kaydı Seviyesi';

  @override
  String get debug_logLevelDialog_title => 'Günlük Kaydı Seviyesini Değiştir';

  @override
  String get debug_logLevel_debug => 'Hata Ayıklama';

  @override
  String get debug_logLevel_info => 'Bilgi';

  @override
  String get debug_logLevel_warn => 'Uyarı';

  @override
  String get debug_logLevel_error => 'Hata';

  @override
  String get debug_logLevel_fatal => 'Kritik';

  @override
  String get debug_collectLogTile_title => 'Kayıtlar Toplanıyor';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Kayıtları toplamayı durdurmak için dokunun.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Kayıtları toplamayı başlatmak için dokunun.';

  @override
  String get debug_downladDebugLogs_subject =>
      'Hata ayıklama kayıtları indiriliyor';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Hata ayıklama kayıtları temizlendi.';

  @override
  String get debug_downladDebugInfo_subject =>
      'Hata ayıklama bilgisi indiriliyor';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return '$fileName indiriliyor';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Hata ayıklama günlüğü mevcut değil.';

  @override
  String get debug_debuggerLogCard_title => 'Günlük Bilgileri';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Yerel hata ayıklama günlüklerini içerir, günlük toplama özelliğinin açık olması gerekir.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'İndir';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Temizle';

  @override
  String get debug_debuggerInfoCard_title => 'Hata Ayıklama Bilgileri';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Uygulamanın hata ayıklama bilgilerini içerir.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Aç';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Kaydet';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Uygulama Bilgileri Toplanıyor...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Kaydet',
      'exit': 'Çıkış',
      'delete': 'Sil',
      'other': 'Onayla',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'İptal';

  @override
  String get snackbar_undoText => 'GERİ AL';

  @override
  String get snackbar_dismissText => 'KAPAT';

  @override
  String get contributors_tile_title => 'Katkıda bulunanlar';

  @override
  String get userAction_tap => 'Dokun';

  @override
  String get userAction_doubleTap => 'Çift';

  @override
  String get userAction_longTap => 'Uzun';

  @override
  String get channelName_habitReminder => 'Alışkanlık hatırlatıcısı';

  @override
  String get channelName_appReminder => 'Hatırlatma';

  @override
  String get channelName_appDebugger => 'Hata ayıklayıcı';

  @override
  String get channelName_appSyncing => 'Eşitleme Süreci';

  @override
  String get channelDesc_appSyncing =>
      'Eşitleme ilerlemesini ve başarılı sonuçları göstermek için kullanılır';

  @override
  String get channelName_appSyncFailed => 'Eşitleme Başarısız';

  @override
  String get channelDesc_appSyncFailed =>
      'Eşitleme başarısız olduğunda uyarmak için kullanılır';

  @override
  String changelog_banner_title(String version) {
    return 'What\'s New in v$version';
  }

  @override
  String get changelog_banner_action => 'CLOSE';

  @override
  String get changelog_banner_view => 'VIEW';

  @override
  String get changelog_dialog_title => 'Changelog';

  @override
  String get changelog_view_full => 'View Full Changelog';
}
