// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class L10nPl extends L10n {
  L10nPl([String locale = 'pl']) : super(locale);

  @override
  String get localeScriptName => 'Polski';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Zapisz';

  @override
  String get habitEdit_habitName_hintText => 'Nazwa Nawyku ...';

  @override
  String get habitEdit_colorPicker_title => 'Wybierz kolor';

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
  String get habitEdit_habitTypeDialog_title => 'Typ nawyku';

  @override
  String get habitEdit_habitType_positiveText => 'Pozytywny';

  @override
  String get habitEdit_habitType_negativeText => 'Negatywny';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Podstawowy cel nawyku (domyślnie: $number)';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Podstawowy cel negatywnego nawyku (domyślnie: $number)';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Dzienne minimum musi być większe niż $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Dzienne maksimum nie może być większe niż $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Dzienne minimum nie może być mniejsze niż $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'Dzienne maksimum nie może być większe niż $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText =>
      'Jednostka celu dziennego';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Docelowe dzienne maksimum';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Nieprawidłowa wartość — pole musi być puste lub większe bądź równe $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Maksymalny dzienny limit';

  @override
  String get habitEdit_frequencySelector_title => 'Wybierz częstotliwość';

  @override
  String get habitEdit_habitFreq_daily => 'Codziennie';

  @override
  String get habitEdit_habitFreq_perweek_text =>
      'Tygodniowo %%time%% razy w tygodniu';

  @override
  String get habitEdit_habitFreq_permonth_text =>
      'Miesięcznie %%time%% razy w miesiącu';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      'W określonym okresie %%time%% razy w ciągu %%day%% dni';

  @override
  String get habitEdit_habitFreq_show_daily => 'Codziennie';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Przynajmniej $freq razy w tygodniu',
      one: 'Raz w tygodniu',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Przynajmniej $freq razy w miesiącu',
      one: 'Raz w miesiącu',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Przynajmniej $freq razy co $days dni',
      one: 'Co $days dni',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    String _temp0 = intl.Intl.pluralLogic(
      targetDays,
      locale: localeName,
      other: '$targetDays dni',
      one: '1 dzień',
    );
    return '$_temp0';
  }

  @override
  String get habitEdit_targetDays_dialogTitle =>
      'Wybierz liczbę dni docelowych';

  @override
  String get habitEdit_targetDays => 'dni';

  @override
  String get habitEdit_reminder_hintText => 'Przypomnienie';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Dowolny dzień tygodnia';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days w każdym tygodniu';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Dowolny dzień miesiąca';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days w każdym miesiącu';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Pytanie, np. Czy ćwiczyłeś dzisiaj?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Wybierz typ przypomnienia';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Kiedy trzeba sprawdzić';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Codziennie';

  @override
  String get habitEdit_reminder_dialogType_week => 'W tygodniu';

  @override
  String get habitEdit_reminder_dialogType_month => 'W miesiącu';

  @override
  String get habitEdit_reminder_dialogConfirm => 'potwierdź';

  @override
  String get habitEdit_reminder_dialogCancel => 'anuluj';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Potwierdzenie';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Czy na pewno chcesz usunąć to przypomnienie?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'potwierdź';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'anuluj';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Pn';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Wt';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Śr';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Czw';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Pt';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sb';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Nd';

  @override
  String get habitEdit_desc_hintText => 'Notatka, obsługuje Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Utworzono: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Zmodyfikowano: ';

  @override
  String get habitDisplay_fab_text => 'Nowy nawyk';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'Podróż tysiąca mil zaczyna się od jednego kroku';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'No matching habits found';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'No matching habits for \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Zarchiwizować wybrane nawyki?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'anuluj';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Zarchiwizowano $count nawyków';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Przywrócić wybrane nawyki?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'anuluj';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Przywrócono $count nawyków';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Usunąć wybrane nawyki?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'anuluj';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Usunięto $count nawyków';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Usunięto nawyk: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wyeksportowano $count nawyków.',
      one: 'Wyeksportowano nawyk.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Wyeksportowano wszystkie nawyki';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Zaznacz wszystkie';

  @override
  String get habitDisplay_editPopMenu_export => 'Eksportuj';

  @override
  String get habitDisplay_editPopMenu_delete => 'Usuń';

  @override
  String get habitDisplay_editPopMenu_clone => 'Szablon';

  @override
  String get habitDisplay_editButton_tooltip => 'Edytuj';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archiwizuj';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Przywróć';

  @override
  String get habitDisplay_settingButton_tooltip => 'Ustawienia';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Bieżące';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Ukończone';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'W trakcie';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Zarchiwizowane';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Najpopularniejsze nawyki: zmiany w ostatnich 30 dniach';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Jasny Motyw';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Ciemny motyw';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Systemowy motyw';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Pokaż zarchiwizowane';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Pokaż ukończone';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Pokaż aktywne';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Ustawienia';

  @override
  String get habitDisplay_sort_reverseText => 'Odwróć';

  @override
  String get habitDisplay_sortDirection_asc => '(Rosnąco)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Malejąco)';

  @override
  String get habitDisplay_sortType_manual => 'Moja kolejność';

  @override
  String get habitDisplay_sortType_name => 'Według nazwy';

  @override
  String get habitDisplay_sortType_colorType => 'Według koloru';

  @override
  String get habitDisplay_sortType_progress => 'Według postępu';

  @override
  String get habitDisplay_sortType_startT => 'Według daty rozpoczęcia';

  @override
  String get habitDisplay_sortType_status => 'Według statusu';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sortuj';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'anuluj';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Debug';

  @override
  String get habitDisplay_searchBar_hintText => 'Szukaj nawyków';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Ongoing';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'Ukończone';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Typ nawyku';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Show Filters';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clear Filters';

  @override
  String get habitDisplay_tab_habits_label => 'Habits';

  @override
  String get habitDisplay_tab_today_label => 'Dzisiaj';

  @override
  String get habitToday_appBar_title => 'Dzisiaj';

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
  String get habitDetail_editButton_tooltip => 'Edytuj';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Przywróć';

  @override
  String get habitDetail_editPopMenu_archive => 'Archiwizuj';

  @override
  String get habitDetail_editPopMenu_export => 'Eksportuj';

  @override
  String get habitDetail_editPopMenu_delete => 'Usuń';

  @override
  String get habitDetail_editPopMenu_clone => 'Szablon';

  @override
  String get habitDetail_confirmDialog_confirm => 'potwierdź';

  @override
  String get habitDetail_confirmDialog_cancel => 'anuluj';

  @override
  String get habitDetail_archiveConfirmDialog_titleText =>
      'Archiwizować nawyk?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Przywrócić nawyk?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Usunąć nawyk?';

  @override
  String get habitDetail_summary_title => 'Podsumowanie';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Bieżąca ocena to $score, a od rozpoczęcia minęło $days dni.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Rozpocznie się za $days dni.',
      one: 'Zaczyna się jutro.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'PONIŻEJ STANDARDU',
      one: 'NIEKOMPLETNY',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'BEZBŁĘDNY',
      one: 'PRZEKROCZONY',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Cel',
      two: 'Próg',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Jednostka: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'brak';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Dni',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'dni';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Rekordy';

  @override
  String get habitDetail_scoreChart_title => 'Wynik';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Dzień';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Tydzień';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Miesiąc';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChart_freqTitle => 'Częstotliwość';

  @override
  String get habitDetail_freqChart_historyTitle => 'Historia';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Częstotliwość & Historia';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Tydzień';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Miesiąc';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Teraz';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Ukryj wykres historii';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Pokaż wykres historii';

  @override
  String get habitDetail_descSubgroup_title => 'Notatka';

  @override
  String get habitDetail_otherSubgroup_title => 'Inne';

  @override
  String get habitDetail_habitType_title => 'Typ';

  @override
  String get habitDetail_reminderTile_title => 'Przypomnienie';

  @override
  String get habitDetail_freqTile_title => 'Powtarzanie';

  @override
  String get habitDetail_startDateTile_title => 'Data rozpoczęcia';

  @override
  String get habitDetail_createDateTile_title => 'Utworzono';

  @override
  String get habitDetail_modifyDateTile_title => 'Zmodyfikowano';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'Data';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'Wartość';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'Powrót do dziś';

  @override
  String get common_loadError_text => 'Failed to load';

  @override
  String get common_loadError_retryText => 'Spróbuj ponownie';

  @override
  String get habitDetail_notFoundText => 'Nie udało się załadować nawyku';

  @override
  String get habitDetail_notFoundRetryText => 'Spróbuj ponownie';

  @override
  String get habitDetail_changeGoal_title => 'Zmień cel';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'bieżący: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'zrealizowany: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'niezrealizowany';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Cel dzienny, domyślnie: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'anuluj';

  @override
  String get habitDetail_changeGoal_saveText => 'zapisz';

  @override
  String get habitDetail_skipReason_title => 'Powód pominięcia';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Napisz coś tutaj...';

  @override
  String get habitDetail_skipReason_cancelText => 'anuluj';

  @override
  String get habitDetail_skipReason_saveText => 'zapisz';

  @override
  String get appSetting_appbar_titleText => 'Ustawienia';

  @override
  String get appSetting_displaySubgroupText => 'Wyświetlanie';

  @override
  String get appSetting_operationSubgroupText => 'Działanie';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Przeciąganie kalendarza po stronach';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Jeśli włączone, kalendarz w pasku aplikacji na stronie głównej będzie przewijany strona po stronie. Domyślnie wyłączone.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Zmień status rekordu';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Zmienia działanie kliknięcia w celu modyfikacji statusu dziennych rekordów na stronie głównej.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Otwórz szczegóły rekordu';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Zmienia działanie kliknięcia w celu otwarcia szczegółowego okna dziennych rekordów na stronie głównej.';

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
  String get appSetting_firstDayOfWeek_titleText => 'Pierwszy dzień tygodnia';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Wybierz pierwszy dzień tygodnia';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Domyślny)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Podążaj za systemem ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Podążaj za systemem';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Język';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Wybierz język';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Format daty ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'Podążaj za ustawieniami systemu';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Skonfigurowany format daty zostanie zastosowany na stronie szczegółów nawyku.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Włącz kompaktowy interfejs na stronie nawyków';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Pozwala tabeli kontroli nawyków wyświetlać więcej treści, ale niektóre elementy i tekst mogą być mniejsze.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Dostosowanie obszaru kalendarza na stronie nawyków';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Dostosuj procentową wielkość obszaru tabeli kontroli nawyków.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Domyślny';

  @override
  String get appSetting_reminderSubgroupText => 'Przypomnienia i powiadomienia';

  @override
  String get appSetting_dailyReminder_titleText => 'Codzienne przypomnienie';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Kopia zapasowa i przywracanie';

  @override
  String get appSetting_export_titleText => 'Eksportuj';

  @override
  String get appSetting_export_subtitleText =>
      'Eksportuje nawyki w formacie JSON. Plik można ponownie zaimportować.';

  @override
  String get appSetting_import_titleText => 'Importuj';

  @override
  String get appSetting_import_subtitleText => 'Importuj nawyki z pliku JSON.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Potwierdź import $count nawyków?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Uwaga: Import nie usuwa istniejących nawyków.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'potwierdź';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'anuluj';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'Importowano $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Import $count zakończony';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'zamknij';

  @override
  String get appSetting_resetConfig_titleText => 'Resetuj ustawienia';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Przywróć wszystkie ustawienia do domyślnych.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Resetować ustawienia?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Przywrócenie wszystkich ustawień do domyślnych wymaga ponownego uruchomienia aplikacji.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'anuluj';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'potwierdź';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'Ustawienia aplikacji zostały zresetowane';

  @override
  String get appSetting_otherSubgroupText => 'Inne';

  @override
  String get appSetting_developMode_titleText => 'Tryb deweloperski';

  @override
  String get appSetting_clearCache_titleText => 'Wyczyść pamięć podręczną';

  @override
  String get appSetting_clearCacheDialog_titleText =>
      'Wyczyść pamięć podręczną';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Po wyczyszczeniu pamięci podręcznej niektóre wartości zostaną przywrócone do domyślnych.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'anuluj';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'potwierdź';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Częściowe czyszczenie pamięci podręcznej nie powiodło się';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Pamięć podręczna wyczyszczona pomyślnie';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Czyszczenie pamięci podręcznej nie powiodło się';

  @override
  String get appSetting_debugger_titleText => 'Informacje debugowania';

  @override
  String get appSetting_about_titleText => 'O aplikacji';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Funkcje eksperymentalne';

  @override
  String get appSetting_synSubgroupText => 'Synchronizacja';

  @override
  String get appSetting_syncOption_titleText => 'Opcje synchronizacji';

  @override
  String get appSetting_notify_titleTile => 'Powiadomienia';

  @override
  String get appSetting_notify_subtitleTile =>
      'Zarządzaj preferencjami powiadomień';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Stuknij, aby otworzyć ustawienia powiadomień systemowych';

  @override
  String get appSync_nowTile_titleText => 'Synchronizuj teraz';

  @override
  String get appSync_nowTile_titleText_syncing => 'Synchronizacja';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate =>
      'Ostatnia synchronizacja: brak danych';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Ostatnia synchronizacja: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Ostatnia synchronizacja (Błąd): brak danych';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Ostatnia synchronizacja (Błąd): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Trwa synchronizacja...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Trwa synchronizacja: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Anulowanie...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Ostatnia synchronizacja (Anulowano): brak danych';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Ostatnia synchronizacja (Anulowano): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Sprawdź logi błędów';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Błąd]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Zakończono',
      'cancelled': 'Anulowano',
      'failed': 'Nie powiodło się',
      'multi': 'Wiele statusów',
      'other': 'Nieznany status',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Zakończono: $reason',
      'cancelled': 'Anulowano: $reason',
      'failed': 'Nie powiodło się: $reason',
      'multi': 'Wiele statusów: $reason',
      'other': 'Nieznany status',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Błąd',
      'userAction': 'Wymagana akcja użytkownika',
      'missingHabitUuid': 'Brak UUID nawyku',
      'empty': 'Puste dane',
      'other': 'Nieznany powód',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText =>
      'Nowa lokalizacja';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Synchronizacja utworzy potrzebne katalogi i wgra lokalne nawyki na serwer. Kontynuować?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Synchronizuj teraz!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Potwierdź synchronizację';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Katalog nie jest pusty. Synchronizacja połączy dane serwera i lokalne. Kontynuować?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Potwierdź scalanie';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Eksportuj nieudane logi synchronizacji';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'Brak logów',
      'false': 'Dotknij, aby wyeksportować',
      'other': 'Ładowanie...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Bieżący: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Fałszywy (tylko dla debugera)',
      'other': 'Nieznany ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Sieć komórkowa',
      'wifi': 'Wifi',
      'other': 'Nieznana',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Ręcznie',
      'minute5': '5 Minutes',
      'minute15': '15 minut',
      'minute30': '30 minut',
      'hour1': '1 godzina',
      'other': 'Nieznany',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Interwał pobierania';

  @override
  String get appSync_summaryTile_title => 'Serwer synchronizacji';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Nie skonfigurowano';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Wszystkie ostatnie nieudane logi synchronizacji';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Potwierdź zapis zmian';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Zapisanie nadpisze poprzednią konfigurację serwera.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'Niezapisane zmiany';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Wyjście spowoduje utratę wszystkich niezapisanych zmian.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText =>
      'Potwierdź usunięcie';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Usunięcie spowoduje skasowanie bieżącej konfiguracji serwera.';

  @override
  String get appSync_serverEditor_titleText_add => 'Nowy serwer synchronizacji';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Edytuj serwer synchronizacji';

  @override
  String get appSync_serverEditor_advance_titleText =>
      'Zaawansowane ustawienia';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Ścieżka';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Wprowadź tutaj prawidłową ścieżkę WebDAV.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Ścieżka nie może być pusta!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Nazwa użytkownika';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Wprowadź nazwę użytkownika, pozostaw puste jeśli nie jest wymagana.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Hasło';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Ignoruj certyfikat SSL';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Limit czasu synchronizacji (sekundy)';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Nieskończony',
    );
    return 'Domyślnie: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Limit czasu połączenia sieciowego (sekundy)';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Nieskończony',
    );
    return 'Domyślnie: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Liczba prób ponownego połączenia';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Ponowne próby wyłączone',
    );
    return 'Domyślnie: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Tryb synchronizacji sieci';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Synchronizacja przez sieć komórkową',
      'wifi': 'Synchronizacja przez Wifi',
      'other': 'Nieznany',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText =>
      'Tryb niskiego transferu';

  @override
  String get appSync_noti_readyToSync_body =>
      'Przygotowanie do synchronizacji...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Zsynchronizowano ($type)',
      'failed': 'Błąd synchronizacji ($type)',
      'other': 'Synchronizacja ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Synchronizuj w trybie niskiego transferu';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Jedna lub więcej funkcji eksperymentalnych jest włączona. Używaj z ostrożnością.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Chmurowa synchronizacja nawyków';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Po włączeniu opcja synchronizacji pojawi się w ustawieniach';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Funkcja eksperymentalna ($syncName) jest wyłączona, ale nadal działa.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Aby całkowicie wyłączyć, przytrzymaj, aby otworzyć \'$menuName\' i wyłącz ją.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText =>
      'Wyszukiwanie nawyków';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Po włączeniu pasek wyszukiwania pojawi się u góry ekranu Nawyków, umożliwiając wyszukiwanie nawyków.';

  @override
  String get appAbout_appbarTile_titleText => 'Informacje';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Wersja: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Kod źródłowy';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Śledzenie problemów';

  @override
  String get appAbout_contactEmailTile_titleText => 'Skontaktuj się ze mną';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Cześć, cieszę się, że się ze mną skontaktowałeś.\nJeśli zgłaszasz błąd, podaj wersję aplikacji i opisz kroki do jego odtworzenia.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licencja';

  @override
  String get appAbout_licenseTile_subtitleText => 'Licencja Apache, wersja 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Oświadczenie licencyjne oprogramowania firm trzecich';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Prywatność';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Dostęp do polityki prywatności w aplikacji';

  @override
  String get appAbout_donateTile_titleText => 'Wesprzyj';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Jestem indywidualnym deweloperem. Jeśli podoba Ci się aplikacja, kup mi ☕.';

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
  String get donateWay_cryptoCurrency => 'Kryptowaluty';

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
    return 'Skopiowano adres $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Zbiorcze Zaznaczanie';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Poprzedni dzień';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Następny dzień';

  @override
  String get batchCheckin_status_skip_text => 'Pomiń';

  @override
  String get batchCheckin_status_ok_text => 'Ukończone';

  @override
  String get batchCheckin_status_double_text => 'x2 Trafienie!';

  @override
  String get batchCheckin_status_zero_text => 'Nieukończone';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nawyki',
      one: 'Nawyk',
    );
    return '$count $_temp0 selected';
  }

  @override
  String get batchCheckin_save_button_text => 'Zapisz';

  @override
  String get batchCheckin_reset_button_text => 'Resetuj';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'status $count nawyków',
      one: 'status nawyku',
    );
    return 'Zmodyfikowano $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title =>
      'Nadpisz istniejące rekordy';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Istniejące rekordy zostaną nadpisane. Po zapisaniu poprzednie rekordy zostaną utracone.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'zapisz';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'anuluj';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Potwierdź powrót';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Zmiany statusu zaznaczenia nie zostaną zapisane, jeśli nie zapiszesz';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'wyjdź';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'anuluj';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Czy udało Ci się dziś trzymać nawyków?';

  @override
  String get appReminder_dailyReminder_body =>
      'kliknij, aby wejść do aplikacji i odznaczyć nawyki na czas.';

  @override
  String get common_habitColorType_cc1 => 'Głęboki liliowy';

  @override
  String get common_habitColorType_cc2 => 'Czerwony';

  @override
  String get common_habitColorType_cc3 => 'Fioletowy';

  @override
  String get common_habitColorType_cc4 => 'Królewski niebieski';

  @override
  String get common_habitColorType_cc5 => 'Ciemny cyjan';

  @override
  String get common_habitColorType_cc6 => 'Zielony';

  @override
  String get common_habitColorType_cc7 => 'Bursztynowy';

  @override
  String get common_habitColorType_cc8 => 'Pomarańczowy';

  @override
  String get common_habitColorType_cc9 => 'Limonkowy';

  @override
  String get common_habitColorType_cc10 => 'Czarna orchidea';

  @override
  String get common_habitColorType_custom => 'Custom';

  @override
  String common_habitColorType_default(int index) {
    return 'Kolor $index';
  }

  @override
  String get common_appThemeColor_system => 'System';

  @override
  String get common_appThemeColor_primary => 'Primary';

  @override
  String get common_appThemeColor_dynamic => 'Dynamic';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Użyj formatu systemowego';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Format daty';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Rok Miesiąc Dzień';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Miesiąc Dzień Rok';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Dzień Miesiąc Rok';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separator';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Kreska';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Ukośnik';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Spacja';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Kropka';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Brak separatora';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Użyj formatu 12-godzinnego';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Użyj pełnej nazwy miesiąca';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Zastosuj w wykresie częstotliwości';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Zastosuj w kalendarzu';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'anuluj';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text =>
      'potwierdź';

  @override
  String get common_errorPage_title => 'Ups, awaria!';

  @override
  String get common_errorPage_copied => 'Skopiowano informacje o awarii';

  @override
  String get common_enable_text => 'Włączone';

  @override
  String get calendarPicker_clip_today => 'Dzisiaj';

  @override
  String get calendarPicker_clip_tomorrow => 'Jutro';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Następny $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'Wyeksportować wszystkie nawyki?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number nawyków',
      one: '1 nawyk',
      zero: 'bieżący nawyk',
    );
    return 'Wyeksportować $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'dołącz rekordy';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'anuluj';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'eksportuj';

  @override
  String get debug_logLevelTile_title => 'Poziom logowania';

  @override
  String get debug_logLevelDialog_title => 'Zmień poziom logowania';

  @override
  String get debug_logLevel_debug => 'Debug';

  @override
  String get debug_logLevel_info => 'Informacja';

  @override
  String get debug_logLevel_warn => 'Ostrzeżenie';

  @override
  String get debug_logLevel_error => 'Błąd';

  @override
  String get debug_logLevel_fatal => 'Krytyczny';

  @override
  String get debug_collectLogTile_title => 'Zbieranie logów';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Dotknij, aby zatrzymać zbieranie logów.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Dotknij, aby rozpocząć zbieranie logów.';

  @override
  String get debug_downladDebugLogs_subject => 'Pobieranie logów debugowania';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Logi debugowania wyczyszczone.';

  @override
  String get debug_downladDebugInfo_subject =>
      'Pobieranie informacji debugowania';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Pobieranie  $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Log debugowania nie istnieje.';

  @override
  String get debug_debuggerLogCard_title => 'Informacje logowania';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Zawiera lokalne informacje logowania, wymaga włączenia przełącznika zbierania logów.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Pobierz';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Wyczyść';

  @override
  String get debug_debuggerInfoCard_title => 'Informacje debugowania';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Zawiera informacje debugowania aplikacji.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Otwórz';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Zapisz';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Zbieranie informacji aplikacji...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Zapisz',
      'exit': 'Wyjdź',
      'delete': 'Usuń',
      'other': 'Potwierdź',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'Anuluj';

  @override
  String get snackbar_undoText => 'COFNIJ';

  @override
  String get snackbar_dismissText => 'ZAMKNIJ';

  @override
  String get contributors_tile_title => 'Współtwórcy';

  @override
  String get userAction_tap => 'Dotknij';

  @override
  String get userAction_doubleTap => 'Podwójne';

  @override
  String get userAction_longTap => 'Przytrzymaj';

  @override
  String get channelName_habitReminder => 'Przypomnienie o nawyku';

  @override
  String get channelName_appReminder => 'Powiadomienie';

  @override
  String get channelName_appDebugger => 'Debuger';

  @override
  String get channelName_appSyncing => 'Proces synchronizacji';

  @override
  String get channelDesc_appSyncing =>
      'Używane do wyświetlania postępu synchronizacji i wyników bez błędów';

  @override
  String get channelName_appSyncFailed => 'Synchronizacja nie powiodła się';

  @override
  String get channelDesc_appSyncFailed =>
      'Używane do powiadamiania o niepowodzeniu synchronizacji';

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
