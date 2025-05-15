import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class L10nTr extends L10n {
  L10nTr([String locale = 'tr']) : super(locale);

  @override
  String get localeScriptName => 'İngilizce';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Kaydet';

  @override
  String get habitEdit_habitName_hintText => 'Alışkanlık Adı ...';

  @override
  String get habitEdit_colorPicker_title => 'Renk seç';

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
  String get habitEdit_habitDailyGoalExtra_hintText => 'İstenilen maksimum günlük hedef';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Geçersiz değer, boş bırakılmalı ya da $dailyGoal\'den büyük veya eşit olmalı';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Maksimum günlük limit';

  @override
  String get habitEdit_frequencySelector_title => 'Sıklık seç';

  @override
  String get habitEdit_habitFreq_daily => 'Günlük';

  @override
  String get habitEdit_habitFreq_perweek => '-';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'kez haftada';

  @override
  String get habitEdit_habitFreq_permonth => '-';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'kez ayda';

  @override
  String get habitEdit_habitFreq_predayfreq => '-';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'gün';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'günde';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

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
  String get habitEdit_reminder_freq_weekPrefixText => '-';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' her hafta';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Ayın her günü';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '-';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' her ay';

  @override
  String get habitEdit_reminderQuest_hintText => 'Soru, örn. Bugün egzersiz yaptın mı?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Hatırlatıcı tipi seç';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Tamamlanması gerektiğinde';

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
  String get habitEdit_reminder_cancelDialogSubtitle => 'Bu hatırlatıcıyı silmeyi onaylıyor musunuz';

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
  String get habitDisplay_emptyImage_text_01 => 'Uzun bir yolculuk, ilk adımla başlar';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Seçilen Alışkanlıkları Arşivle?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'onayla';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'iptal et';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count alışkanlık arşivlendi';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Seçilen Alışkanlıkları Arşivden Çıkar?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'onayla';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'iptal et';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count alışkanlık arşivden çıkarıldı';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Seçilen Alışkanlıkları Sil?';

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
    return 'Deleted habit: \"$name\"';
  }

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
  String get habitDisplay_statsMenu_popularitySubgroupText => 'En İyi Alışkanlıklar: Son 30 Gündeki Değişiklikler';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Açık Tema';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Koyu Tema';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Sistemi İzle';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Arşivlenenleri Göster';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Tamamlananları Göster';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Aktif Olanları Göster';

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
  String get habitDetail_archiveConfirmDialog_titleText => 'Alışkanlığı Arşivle?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Alışkanlığı Arşivden Çıkar?';

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
  String get habitDetail_freqChart_expanded_hideTooltip => 'Geçmiş Grafiğini Gizle';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Geçmiş Grafiğini Göster';

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
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'bugüne geri dön';

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
  String get appSetting_dragCalendarByPageTile_titleText => 'Takvimi sayfa sayfa kaydır';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Bu özellik etkinleştirildiğinde, ana sayfadaki uygulama çubuğu takvimi sayfa sayfa kaydırılacaktır. Varsayılan olarak kapalıdır.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Kayıt Durumunu Değiştir';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Ana sayfadaki günlük kayıtların durumunu değiştirmek için tıklama davranışını düzenleyin.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Detaylı Kaydı Aç';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Ana sayfadaki günlük kayıtların detaylı penceresini açmak için tıklama davranışını ayarlayın.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Haftanın ilk günü';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Haftanın ilk gününü göster';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Varsayılan)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Sistemi İzle ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'Sistemi İzle';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Dil';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Dil Seç';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Tarih gösterim biçimi ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'sistem ayarını izle';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'Yapılandırılan tarih formatı, alışkanlık detay sayfasındaki tarih gösterimine uygulanacaktır.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Alışkanlıklar sayfasında Kompakt Kullanıcı Arayüzünü etkinleştir';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Alışkanlıklar kontrol tablosunun daha fazla içerik görüntülemesine izin verin, ancak bazı kullanıcı arayüzü ve metinler daha küçük görünebilir.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Alışkanlık işaretleme alanı boyut ayarı';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Alışkanlık işaretleme tablo alanında daha fazla/az alan için yüzdeyi ayarlayın.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Varsayılan';

  @override
  String get appSetting_reminderSubgroupText => 'Hatırlatıcı';

  @override
  String get appSetting_dailyReminder_titleText => 'Günlük hatırlatıcı';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Yedekleme & geri yükleme';

  @override
  String get appSetting_export_titleText => 'Dışa aktar';

  @override
  String get appSetting_export_subtitleText => 'Dışa aktarılan alışkanlıklar JSON formatındadır, bu dosya geri içe aktarılabilir.';

  @override
  String get appSetting_import_titleText => 'İçe aktar';

  @override
  String get appSetting_import_subtitleText => 'Alışkanlıkları JSON dosyadan içe aktar.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return '$count alışkanlıkları içe aktarmayı onayla?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Not: İçe aktarma, mevcut alışkanlıkları silmez.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'onayla';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'iptal et';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
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
  String get appSetting_resetConfig_subtitleText => 'Tüm yapılandırmaları varsayılana sıfırla.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Yapılandırmaları sıfırla?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Tüm yapılandırmaları varsayılana sıfırla, uygulamak için uygulama yeniden başlatılmalıdır.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'iptal et';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'onayla';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'uygulama yapılandırmalarını sıfırlama başarılı';

  @override
  String get appSetting_otherSubgroupText => 'Diğer';

  @override
  String get appSetting_developMode_titleText => 'Geliştirici Modu';

  @override
  String get appSetting_clearCache_titleText => 'Önbelleği Temizle';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Önbelleği Temizle';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Önbellek temizlendikten sonra, bazı özel değerler varsayılan değerlere geri yüklenir.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'iptal et';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'onayla';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Kısmi önbellek temizlenemedi';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Önbellek başarıyla temizlendi';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Önbellek temizlenemedi';

  @override
  String get appSetting_debugger_titleText => 'Hata Ayıklama Bilgisi';

  @override
  String get appSetting_about_titleText => 'Hakkında';

  @override
  String get appSetting_experimentalFeatureTile_titleText => 'Experimental Features';

  @override
  String get appSetting_synSubgroupText => 'Sync';

  @override
  String get appSetting_syncOption_titleText => 'Sync Options';

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
  String get appAbout_contactEmailTile_emailBody => 'Merhaba, Bana yazdığın için memnunum.\nEğer bir hata bildiriyorsan, lütfen uygulama versiyonunu belirt ve hatayı ortaya çıkaran adımları açıkla.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Lisans';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Üçüncü Taraf Lisanslama Bildirimi';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Privacy';

  @override
  String get appAbout_privacyTile_subTitleText => 'Access the privacy policy in this app';

  @override
  String get appAbout_donateTile_titleText => 'Bağış yap';

  @override
  String get appAbout_donateTile_subTitleText => 'Ben kişisel bir geliştiriciyim. Bu uygulamayı beğendiyseniz, lütfen bana bir ☕ satın alın.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

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
  String get batchCheckin_save_confirmDialog_title => 'Mevcut Kayıtların Üzerine Yaz';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Kaydedildikten sonra mevcut kayıtların üzerine yazılacak, önceki kayıtlar kaybolacak.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'kaydet';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'iptal et';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Dönüşü Onayla';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Giriş durumu değişiklikleri kaydedilmeden uygulanmayacak';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'çıkış';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'iptal et';

  @override
  String get appReminder_dailyReminder_title => '🏝 Bugün alışkanlıklarınıza bağlı kaldınız mı?';

  @override
  String get appReminder_dailyReminder_body => 'Uygulamayı açıp zamanında giriş yapmak için tıklayın.';

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
  String common_habitColorType_default(int index) {
    return 'Renk $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Sistem formatını kullan';

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
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => '12 saatlik formatı kullan';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Tam adı kullan';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Sıklık Grafiğine Uygula';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Takvime Uygula';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'iptal et';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'onayla';

  @override
  String get common_errorPage_title => 'Tüh, çöktü!';

  @override
  String get common_errorPage_copied => 'Çökme bilgileri kopyalandı';

  @override
  String get common_enable_text => 'Enabled';

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
  String get exportConfirmDialog_title_exportAll => 'Bütün alışkanlıkları dışa aktar?';

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
  String get debug_collectLogTile_enable_subtitle => 'Kayıtları toplamayı durdurmak için dokunun.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Kayıtları toplamayı başlatmak için dokunun.';

  @override
  String get debug_downladDebugLogs_subject => 'Hata ayıklama kayıtları indiriliyor';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Hata ayıklama kayıtları temizlendi.';

  @override
  String get debug_downladDebugInfo_subject => 'Hata ayıklama bilgisi indiriliyor';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return '$fileName indiriliyor';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Hata ayıklama günlüğü mevcut değil.';

  @override
  String get debug_debuggerLogCard_title => 'Günlük Bilgileri';

  @override
  String get debug_debuggerLogCard_subtitle => 'Yerel hata ayıklama günlüklerini içerir, günlük toplama özelliğinin açık olması gerekir.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'İndir';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Temizle';

  @override
  String get debug_debuggerInfoCard_title => 'Hata Ayıklama Bilgileri';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Uygulamanın hata ayıklama bilgilerini içerir.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Aç';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Kaydet';

  @override
  String get debug_debuggerInfo_notificationTitle => 'Uygulama Bilgileri Toplanıyor...';

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
}
