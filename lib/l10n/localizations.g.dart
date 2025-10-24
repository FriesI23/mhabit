import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_ar.g.dart';
import 'localizations_cs.g.dart';
import 'localizations_de.g.dart';
import 'localizations_en.g.dart';
import 'localizations_es.g.dart';
import 'localizations_fa.g.dart';
import 'localizations_fr.g.dart';
import 'localizations_he.g.dart';
import 'localizations_it.g.dart';
import 'localizations_nb.g.dart';
import 'localizations_pl.g.dart';
import 'localizations_pt.g.dart';
import 'localizations_ru.g.dart';
import 'localizations_tr.g.dart';
import 'localizations_uk.g.dart';
import 'localizations_vi.g.dart';
import 'localizations_zh.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('it'),
    Locale('nb'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// The human-readable name of the language used for the locale.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeScriptName;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Table Habit'**
  String get appName;

  /// No description provided for @habitEdit_saveButton_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get habitEdit_saveButton_text;

  /// No description provided for @habitEdit_habitName_hintText.
  ///
  /// In en, this message translates to:
  /// **'Habit Name ...'**
  String get habitEdit_habitName_hintText;

  /// No description provided for @habitEdit_colorPicker_title.
  ///
  /// In en, this message translates to:
  /// **'Pick color'**
  String get habitEdit_colorPicker_title;

  /// No description provided for @habitEdit_habitTypeDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Habit type'**
  String get habitEdit_habitTypeDialog_title;

  /// No description provided for @habitEdit_habitType_positiveText.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get habitEdit_habitType_positiveText;

  /// No description provided for @habitEdit_habitType_negativeText.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get habitEdit_habitType_negativeText;

  /// default habit daily goal
  ///
  /// In en, this message translates to:
  /// **'Daily goal, default {number}'**
  String habitEdit_habitDailyGoal_hintText(num number);

  /// default habit daily goal for negative habit
  ///
  /// In en, this message translates to:
  /// **'Minimum daily threshold, default {number}'**
  String habitEdit_habitDailyGoal_negativeHintText(num number);

  /// minimum number for habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must > {number}'**
  String habitEdit_habitDailyGoal_errorText01(num number);

  /// maximum number for habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must ≤ {number}'**
  String habitEdit_habitDailyGoal_errorText02(num number);

  /// minimum number for negative habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must ≥ {number}'**
  String habitEdit_habitDailyGoal_negativeErrorText01(num number);

  /// maximum number for negative habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must ≤ {number}'**
  String habitEdit_habitDailyGoal_negativeErrorText02(num number);

  /// No description provided for @habitEdit_habitDailyGoalUnit_hintText.
  ///
  /// In en, this message translates to:
  /// **'Daily goal unit'**
  String get habitEdit_habitDailyGoalUnit_hintText;

  /// No description provided for @habitEdit_habitDailyGoalExtra_hintText.
  ///
  /// In en, this message translates to:
  /// **'Desired maximum daily goal'**
  String get habitEdit_habitDailyGoalExtra_hintText;

  /// No description provided for @habitEdit_habitDailyGoalExtra_errorText.
  ///
  /// In en, this message translates to:
  /// **'invalid value, must be empty or ≥ {dailyGoal}'**
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal);

  /// No description provided for @habitEdit_habitDailyGoalExtra_negativeHintText.
  ///
  /// In en, this message translates to:
  /// **'Maximum daily limit'**
  String get habitEdit_habitDailyGoalExtra_negativeHintText;

  /// No description provided for @habitEdit_frequencySelector_title.
  ///
  /// In en, this message translates to:
  /// **'Select frequency'**
  String get habitEdit_frequencySelector_title;

  /// No description provided for @habitEdit_habitFreq_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitEdit_habitFreq_daily;

  /// No description provided for @habitEdit_habitFreq_perweek.
  ///
  /// In en, this message translates to:
  /// **''**
  String get habitEdit_habitFreq_perweek;

  /// No description provided for @habitEdit_habitFreq_perweek_ex01.
  ///
  /// In en, this message translates to:
  /// **'times per week'**
  String get habitEdit_habitFreq_perweek_ex01;

  /// No description provided for @habitEdit_habitFreq_permonth.
  ///
  /// In en, this message translates to:
  /// **''**
  String get habitEdit_habitFreq_permonth;

  /// No description provided for @habitEdit_habitFreq_permonth_ex01.
  ///
  /// In en, this message translates to:
  /// **'times per month'**
  String get habitEdit_habitFreq_permonth_ex01;

  /// No description provided for @habitEdit_habitFreq_predayfreq.
  ///
  /// In en, this message translates to:
  /// **''**
  String get habitEdit_habitFreq_predayfreq;

  /// No description provided for @habitEdit_habitFreq_predayfreq_ex01.
  ///
  /// In en, this message translates to:
  /// **'times in'**
  String get habitEdit_habitFreq_predayfreq_ex01;

  /// No description provided for @habitEdit_habitFreq_predayfreq_ex02.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get habitEdit_habitFreq_predayfreq_ex02;

  /// If set to 1, the display widget list will be reversed.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get habitEdit_habitFreq_predayfreq_reverse_flag;

  /// No description provided for @habitEdit_habitFreq_show_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitEdit_habitFreq_show_daily;

  /// No description provided for @habitEdit_habitFreq_show_perweek.
  ///
  /// In en, this message translates to:
  /// **'{freq, plural, =1{Per week} other{At least {freq} times per week}}'**
  String habitEdit_habitFreq_show_perweek(int freq);

  /// No description provided for @habitEdit_habitFreq_show_permonth.
  ///
  /// In en, this message translates to:
  /// **'{freq, plural, =1{Per month} other{At least {freq} times per month}}'**
  String habitEdit_habitFreq_show_permonth(int freq);

  /// No description provided for @habitEdit_habitFreq_show_perdayfreq.
  ///
  /// In en, this message translates to:
  /// **'{freq, plural, =1{In every {days} days} other{At least {freq} times in every {days} days}}'**
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days);

  /// No description provided for @habitEdit_targetDays_title.
  ///
  /// In en, this message translates to:
  /// **'{targetDays} days'**
  String habitEdit_targetDays_title(int targetDays);

  /// No description provided for @habitEdit_targetDays_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Target Days'**
  String get habitEdit_targetDays_dialogTitle;

  /// No description provided for @habitEdit_targetDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get habitEdit_targetDays;

  /// No description provided for @habitEdit_reminder_hintText.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get habitEdit_reminder_hintText;

  /// No description provided for @habitEdit_reminder_freq_weekHelpText.
  ///
  /// In en, this message translates to:
  /// **'Any day of week'**
  String get habitEdit_reminder_freq_weekHelpText;

  /// No description provided for @habitEdit_reminder_freq_weekPrefixText.
  ///
  /// In en, this message translates to:
  /// **''**
  String get habitEdit_reminder_freq_weekPrefixText;

  /// No description provided for @habitEdit_reminder_freq_weekSubfixText.
  ///
  /// In en, this message translates to:
  /// **' in every week'**
  String get habitEdit_reminder_freq_weekSubfixText;

  /// No description provided for @habitEdit_reminder_freq_monthHelpText.
  ///
  /// In en, this message translates to:
  /// **'Any day of month'**
  String get habitEdit_reminder_freq_monthHelpText;

  /// No description provided for @habitEdit_reminder_freq_monthPrefixText.
  ///
  /// In en, this message translates to:
  /// **''**
  String get habitEdit_reminder_freq_monthPrefixText;

  /// No description provided for @habitEdit_reminder_freq_monthSubfixText.
  ///
  /// In en, this message translates to:
  /// **' in every month'**
  String get habitEdit_reminder_freq_monthSubfixText;

  /// No description provided for @habitEdit_reminderQuest_hintText.
  ///
  /// In en, this message translates to:
  /// **'Question, e.g. Did you exercise today?'**
  String get habitEdit_reminderQuest_hintText;

  /// No description provided for @habitEdit_reminder_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose reminder type'**
  String get habitEdit_reminder_dialogTitle;

  /// No description provided for @habitEdit_reminder_dialogType_whenNeeded.
  ///
  /// In en, this message translates to:
  /// **'When need to check in'**
  String get habitEdit_reminder_dialogType_whenNeeded;

  /// No description provided for @habitEdit_reminder_dialogType_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitEdit_reminder_dialogType_daily;

  /// No description provided for @habitEdit_reminder_dialogType_week.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get habitEdit_reminder_dialogType_week;

  /// No description provided for @habitEdit_reminder_dialogType_month.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get habitEdit_reminder_dialogType_month;

  /// No description provided for @habitEdit_reminder_dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitEdit_reminder_dialogConfirm;

  /// No description provided for @habitEdit_reminder_dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitEdit_reminder_dialogCancel;

  /// No description provided for @habitEdit_reminder_cancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get habitEdit_reminder_cancelDialogTitle;

  /// No description provided for @habitEdit_reminder_cancelDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm to remove this reminder'**
  String get habitEdit_reminder_cancelDialogSubtitle;

  /// No description provided for @habitEdit_reminder_cancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitEdit_reminder_cancelDialogConfirm;

  /// No description provided for @habitEdit_reminder_cancelDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitEdit_reminder_cancelDialogCancel;

  /// No description provided for @habitEdit_reminder_weekdayText_monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get habitEdit_reminder_weekdayText_monday;

  /// No description provided for @habitEdit_reminder_weekdayText_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get habitEdit_reminder_weekdayText_tuesday;

  /// No description provided for @habitEdit_reminder_weekdayText_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get habitEdit_reminder_weekdayText_wednesday;

  /// No description provided for @habitEdit_reminder_weekdayText_thursday.
  ///
  /// In en, this message translates to:
  /// **'Tur'**
  String get habitEdit_reminder_weekdayText_thursday;

  /// No description provided for @habitEdit_reminder_weekdayText_friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get habitEdit_reminder_weekdayText_friday;

  /// No description provided for @habitEdit_reminder_weekdayText_saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get habitEdit_reminder_weekdayText_saturday;

  /// No description provided for @habitEdit_reminder_weekdayText_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get habitEdit_reminder_weekdayText_sunday;

  /// No description provided for @habitEdit_desc_hintText.
  ///
  /// In en, this message translates to:
  /// **'Memo, support Markdown'**
  String get habitEdit_desc_hintText;

  /// No description provided for @habitEdit_create_datetime_prefix.
  ///
  /// In en, this message translates to:
  /// **'Created: '**
  String get habitEdit_create_datetime_prefix;

  /// No description provided for @habitEdit_modify_datetime_prefix.
  ///
  /// In en, this message translates to:
  /// **'Modified: '**
  String get habitEdit_modify_datetime_prefix;

  /// No description provided for @habitDisplay_fab_text.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get habitDisplay_fab_text;

  /// No description provided for @habitDisplay_emptyImage_text_01.
  ///
  /// In en, this message translates to:
  /// **'A journey of a thousand miles begins with a single step'**
  String get habitDisplay_emptyImage_text_01;

  /// No description provided for @habitDisplay_archiveHabitsConfirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Archive Selected Habits?'**
  String get habitDisplay_archiveHabitsConfirmDialog_title;

  /// No description provided for @habitDisplay_archiveHabitsConfirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_archiveHabitsConfirmDialog_confirm;

  /// No description provided for @habitDisplay_archiveHabitsConfirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_archiveHabitsConfirmDialog_cancel;

  /// No description provided for @habitDisplay_archiveHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Archived {count} habits'**
  String habitDisplay_archiveHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_unarchiveHabitsConfirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Selected Habits?'**
  String get habitDisplay_unarchiveHabitsConfirmDialog_title;

  /// No description provided for @habitDisplay_unarchiveHabitsConfirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm;

  /// No description provided for @habitDisplay_unarchiveHabitsConfirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel;

  /// No description provided for @habitDisplay_unarchiveHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Unarchived {count} habits'**
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_deleteHabitsConfirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Habits?'**
  String get habitDisplay_deleteHabitsConfirmDialog_title;

  /// No description provided for @habitDisplay_deleteHabitsConfirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_deleteHabitsConfirmDialog_confirm;

  /// No description provided for @habitDisplay_deleteHabitsConfirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_deleteHabitsConfirmDialog_cancel;

  /// No description provided for @habitDisplay_deleteHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} habits'**
  String habitDisplay_deleteHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_deleteSingleHabitSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Deleted habit: \"{name}\"'**
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name);

  /// No description provided for @habitDisplay_exportHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Exported habit.} other {Exported {count} habits.}}'**
  String habitDisplay_exportHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_exportAllHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Exported All Habits'**
  String get habitDisplay_exportAllHabitsSuccSnackbarText;

  /// No description provided for @habitDisplay_editPopMenu_selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get habitDisplay_editPopMenu_selectAll;

  /// No description provided for @habitDisplay_editPopMenu_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get habitDisplay_editPopMenu_export;

  /// No description provided for @habitDisplay_editPopMenu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitDisplay_editPopMenu_delete;

  /// No description provided for @habitDisplay_editPopMenu_clone.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get habitDisplay_editPopMenu_clone;

  /// No description provided for @habitDisplay_editButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get habitDisplay_editButton_tooltip;

  /// No description provided for @habitDisplay_archiveButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get habitDisplay_archiveButton_tooltip;

  /// No description provided for @habitDisplay_unarchiveButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get habitDisplay_unarchiveButton_tooltip;

  /// No description provided for @habitDisplay_settingButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get habitDisplay_settingButton_tooltip;

  /// No description provided for @habitDisplay_statsMenu_statSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get habitDisplay_statsMenu_statSubgroupText;

  /// No description provided for @habitDisplay_statsMenu_completedTileText.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get habitDisplay_statsMenu_completedTileText;

  /// No description provided for @habitDisplay_statsMenu_inProgresTileText.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get habitDisplay_statsMenu_inProgresTileText;

  /// No description provided for @habitDisplay_statsMenu_archivedTileText.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get habitDisplay_statsMenu_archivedTileText;

  /// No description provided for @habitDisplay_statsMenu_popularitySubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Top Habits: Last 30 Days Changes'**
  String get habitDisplay_statsMenu_popularitySubgroupText;

  /// No description provided for @habitDisplay_mainMenu_lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get habitDisplay_mainMenu_lightTheme;

  /// No description provided for @habitDisplay_mainMenu_darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get habitDisplay_mainMenu_darkTheme;

  /// No description provided for @habitDisplay_mainMenu_followSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get habitDisplay_mainMenu_followSystemTheme;

  /// No description provided for @habitDisplay_mainMenu_showArchivedTileText.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get habitDisplay_mainMenu_showArchivedTileText;

  /// No description provided for @habitDisplay_mainMenu_showCompletedTileText.
  ///
  /// In en, this message translates to:
  /// **'Show Completed'**
  String get habitDisplay_mainMenu_showCompletedTileText;

  /// No description provided for @habitDisplay_mainMenu_showActivedTileText.
  ///
  /// In en, this message translates to:
  /// **'Show Actived'**
  String get habitDisplay_mainMenu_showActivedTileText;

  /// No description provided for @habitDisplay_mainMenu_settingTileText.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get habitDisplay_mainMenu_settingTileText;

  /// No description provided for @habitDisplay_sort_reverseText.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get habitDisplay_sort_reverseText;

  /// No description provided for @habitDisplay_sortDirection_asc.
  ///
  /// In en, this message translates to:
  /// **'(Asc)'**
  String get habitDisplay_sortDirection_asc;

  /// No description provided for @habitDisplay_sortDirection_Desc.
  ///
  /// In en, this message translates to:
  /// **'(Desc)'**
  String get habitDisplay_sortDirection_Desc;

  /// No description provided for @habitDisplay_sortType_manual.
  ///
  /// In en, this message translates to:
  /// **'My order'**
  String get habitDisplay_sortType_manual;

  /// No description provided for @habitDisplay_sortType_name.
  ///
  /// In en, this message translates to:
  /// **'By Name'**
  String get habitDisplay_sortType_name;

  /// No description provided for @habitDisplay_sortType_colorType.
  ///
  /// In en, this message translates to:
  /// **'By Color'**
  String get habitDisplay_sortType_colorType;

  /// No description provided for @habitDisplay_sortType_progress.
  ///
  /// In en, this message translates to:
  /// **'By Rate'**
  String get habitDisplay_sortType_progress;

  /// No description provided for @habitDisplay_sortType_startT.
  ///
  /// In en, this message translates to:
  /// **'By Start Date'**
  String get habitDisplay_sortType_startT;

  /// No description provided for @habitDisplay_sortType_status.
  ///
  /// In en, this message translates to:
  /// **'By Status'**
  String get habitDisplay_sortType_status;

  /// No description provided for @habitDisplay_sortTypeDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get habitDisplay_sortTypeDialog_title;

  /// No description provided for @habitDisplay_sortTypeDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_sortTypeDialog_confirm;

  /// No description provided for @habitDisplay_sortTypeDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_sortTypeDialog_cancel;

  /// No description provided for @habitDisplay_debug_debugSubgroup_title.
  ///
  /// In en, this message translates to:
  /// **'🛠️Debug'**
  String get habitDisplay_debug_debugSubgroup_title;

  /// No description provided for @habitDisplay_searchBar_hintText.
  ///
  /// In en, this message translates to:
  /// **'Search habits'**
  String get habitDisplay_searchBar_hintText;

  /// No description provided for @habitDetail_editButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get habitDetail_editButton_tooltip;

  /// No description provided for @habitDetail_editPopMenu_unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get habitDetail_editPopMenu_unarchive;

  /// No description provided for @habitDetail_editPopMenu_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get habitDetail_editPopMenu_archive;

  /// No description provided for @habitDetail_editPopMenu_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get habitDetail_editPopMenu_export;

  /// No description provided for @habitDetail_editPopMenu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitDetail_editPopMenu_delete;

  /// No description provided for @habitDetail_editPopMenu_clone.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get habitDetail_editPopMenu_clone;

  /// No description provided for @habitDetail_confirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDetail_confirmDialog_confirm;

  /// No description provided for @habitDetail_confirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDetail_confirmDialog_cancel;

  /// No description provided for @habitDetail_archiveConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Archive Habit?'**
  String get habitDetail_archiveConfirmDialog_titleText;

  /// No description provided for @habitDetail_unarchiveConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Habit?'**
  String get habitDetail_unarchiveConfirmDialog_titleText;

  /// No description provided for @habitDetail_deleteConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit?'**
  String get habitDetail_deleteConfirmDialog_titleText;

  /// No description provided for @habitDetail_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get habitDetail_summary_title;

  /// No description provided for @habitDetail_summary_body.
  ///
  /// In en, this message translates to:
  /// **'Current grade is {score}, and it has been {days} days since the start.'**
  String habitDetail_summary_body(String score, int days);

  /// No description provided for @habitDetail_summary_preBody.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Starting tomorrow.} other{Start in {days} days.}}'**
  String habitDetail_summary_preBody(int days);

  /// No description provided for @habitDetail_heatmap_leftHelpText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, =1{INCOMPLETE} =2{SUBSTANDARD} other{}}'**
  String habitDetail_heatmap_leftHelpText(int habitType);

  /// No description provided for @habitDetail_heatmap_rightHelpText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, =1{OVERFULFIL} =2{IMPECCABLE} other{}}'**
  String habitDetail_heatmap_rightHelpText(int habitType);

  /// No description provided for @habitDetail_descDailyGoal_titleText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, =2{Threshold} other{Goal}}'**
  String habitDetail_descDailyGoal_titleText(int habitType);

  /// No description provided for @habitDetail_descDailyGoal_unitText.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String habitDetail_descDailyGoal_unitText(String unit);

  /// No description provided for @habitDetail_descDailyGoal_unitEmptyText.
  ///
  /// In en, this message translates to:
  /// **'null'**
  String get habitDetail_descDailyGoal_unitEmptyText;

  /// No description provided for @habitDetail_descTargetDays_titleText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, other{Days}}'**
  String habitDetail_descTargetDays_titleText(int habitType);

  /// No description provided for @habitDetail_descTargetDays_unitText.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get habitDetail_descTargetDays_unitText;

  /// No description provided for @habitDetail_descRecordsNum_titleText.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get habitDetail_descRecordsNum_titleText;

  /// No description provided for @habitDetail_scoreChart_title.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get habitDetail_scoreChart_title;

  /// No description provided for @habitDetail_scoreChartCombine_dailyText.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get habitDetail_scoreChartCombine_dailyText;

  /// No description provided for @habitDetail_scoreChartCombine_weeklyText.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get habitDetail_scoreChartCombine_weeklyText;

  /// No description provided for @habitDetail_scoreChartCombine_monthlyText.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get habitDetail_scoreChartCombine_monthlyText;

  /// No description provided for @habitDetail_scoreChartCombine_yearlyText.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get habitDetail_scoreChartCombine_yearlyText;

  /// No description provided for @habitDetail_freqChart_freqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get habitDetail_freqChart_freqTitle;

  /// No description provided for @habitDetail_freqChart_historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get habitDetail_freqChart_historyTitle;

  /// No description provided for @habitDetail_freqChart_combinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequency & History'**
  String get habitDetail_freqChart_combinedTitle;

  /// No description provided for @habitDetail_freqChartCombine_weeklyText.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get habitDetail_freqChartCombine_weeklyText;

  /// No description provided for @habitDetail_freqChartCombine_monthlyText.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get habitDetail_freqChartCombine_monthlyText;

  /// No description provided for @habitDetail_freqChartCombine_yearlyText.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get habitDetail_freqChartCombine_yearlyText;

  /// No description provided for @habitDetail_freqChartNaviBar_nowText.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get habitDetail_freqChartNaviBar_nowText;

  /// No description provided for @habitDetail_freqChart_expanded_hideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide History Chart'**
  String get habitDetail_freqChart_expanded_hideTooltip;

  /// No description provided for @habitDetail_freqChart_expanded_showTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show History Chart'**
  String get habitDetail_freqChart_expanded_showTooltip;

  /// No description provided for @habitDetail_descSubgroup_title.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get habitDetail_descSubgroup_title;

  /// No description provided for @habitDetail_otherSubgroup_title.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get habitDetail_otherSubgroup_title;

  /// No description provided for @habitDetail_habitType_title.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get habitDetail_habitType_title;

  /// No description provided for @habitDetail_reminderTile_title.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get habitDetail_reminderTile_title;

  /// No description provided for @habitDetail_freqTile_title.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get habitDetail_freqTile_title;

  /// No description provided for @habitDetail_startDateTile_title.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get habitDetail_startDateTile_title;

  /// No description provided for @habitDetail_createDateTile_title.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get habitDetail_createDateTile_title;

  /// No description provided for @habitDetail_modifyDateTile_title.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get habitDetail_modifyDateTile_title;

  /// No description provided for @habitDetail_editHeatmapCal_dateButtonText.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get habitDetail_editHeatmapCal_dateButtonText;

  /// No description provided for @habitDetail_editHeatmapCal_valueButtonText.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get habitDetail_editHeatmapCal_valueButtonText;

  /// No description provided for @habitDetail_editHeatmapCal_backToToday_tooltipText.
  ///
  /// In en, this message translates to:
  /// **'back to today'**
  String get habitDetail_editHeatmapCal_backToToday_tooltipText;

  /// No description provided for @habitDetail_notFoundText.
  ///
  /// In en, this message translates to:
  /// **'Load habit failed'**
  String get habitDetail_notFoundText;

  /// No description provided for @habitDetail_notFoundRetryText.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get habitDetail_notFoundRetryText;

  /// No description provided for @habitDetail_changeGoal_title.
  ///
  /// In en, this message translates to:
  /// **'Change goal'**
  String get habitDetail_changeGoal_title;

  /// No description provided for @habitDetail_changeGoal_currentChipText.
  ///
  /// In en, this message translates to:
  /// **'current: {goal}'**
  String habitDetail_changeGoal_currentChipText(String goal);

  /// No description provided for @habitDetail_changeGoal_doneChipText.
  ///
  /// In en, this message translates to:
  /// **'done: {goal}'**
  String habitDetail_changeGoal_doneChipText(String goal);

  /// No description provided for @habitDetail_changeGoal_undoneChipText.
  ///
  /// In en, this message translates to:
  /// **'undone'**
  String get habitDetail_changeGoal_undoneChipText;

  /// No description provided for @habitDetail_changeGoal_extraChipText.
  ///
  /// In en, this message translates to:
  /// **'{goal}'**
  String habitDetail_changeGoal_extraChipText(String goal);

  /// No description provided for @habitDetail_changeGoal_helpText.
  ///
  /// In en, this message translates to:
  /// **'Daily goal, default: {goal}'**
  String habitDetail_changeGoal_helpText(String goal);

  /// No description provided for @habitDetail_changeGoal_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDetail_changeGoal_cancelText;

  /// No description provided for @habitDetail_changeGoal_saveText.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get habitDetail_changeGoal_saveText;

  /// No description provided for @habitDetail_skipReason_title.
  ///
  /// In en, this message translates to:
  /// **'Skip reason'**
  String get habitDetail_skipReason_title;

  /// No description provided for @habitDetail_skipReason_bodyHelpText.
  ///
  /// In en, this message translates to:
  /// **'Write something here...'**
  String get habitDetail_skipReason_bodyHelpText;

  /// No description provided for @habitDetail_skipReason_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDetail_skipReason_cancelText;

  /// No description provided for @habitDetail_skipReason_saveText.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get habitDetail_skipReason_saveText;

  /// No description provided for @appSetting_appbar_titleText.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appSetting_appbar_titleText;

  /// No description provided for @appSetting_displaySubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get appSetting_displaySubgroupText;

  /// No description provided for @appSetting_operationSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get appSetting_operationSubgroupText;

  /// No description provided for @appSetting_dragCalendarByPageTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Drag calendar by page'**
  String get appSetting_dragCalendarByPageTile_titleText;

  /// No description provided for @appSetting_dragCalendarByPageTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'If the switch is enabled, the app bar calendar on the home page will be dragged page by page. By default, the switch is disabled.'**
  String get appSetting_dragCalendarByPageTile_subtitleText;

  /// No description provided for @appSetting_changeRecordStatusOpTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Change Record Status'**
  String get appSetting_changeRecordStatusOpTile_titleText;

  /// No description provided for @appSetting_changeRecordStatusOpTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Modify the click behavior to change the status of daily records on main page.'**
  String get appSetting_changeRecordStatusOpTile_subtitleText;

  /// No description provided for @appSetting_openRecordStatusDialogOpTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Open Detailed Record'**
  String get appSetting_openRecordStatusDialogOpTile_titleText;

  /// No description provided for @appSetting_openRecordStatusDialogOpTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Modify the click behavior to open the detailed popup for daily records on main page.'**
  String get appSetting_openRecordStatusDialogOpTile_subtitleText;

  /// No description provided for @appSetting_firstDayOfWeek_titleText.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get appSetting_firstDayOfWeek_titleText;

  /// No description provided for @appSetting_firstDayOfWeekDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Show first day of week'**
  String get appSetting_firstDayOfWeekDialog_titleText;

  /// No description provided for @appSetting_firstDayOfWeekDialog_defaultText.
  ///
  /// In en, this message translates to:
  /// **' (Default)'**
  String get appSetting_firstDayOfWeekDialog_defaultText;

  /// No description provided for @appSetting_changeLanguage_followSystem_text.
  ///
  /// In en, this message translates to:
  /// **'Follow System ({localeName})'**
  String appSetting_changeLanguage_followSystem_text(String localeName);

  /// No description provided for @appSetting_changeLanguage_followSystem_noLocale_text.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get appSetting_changeLanguage_followSystem_noLocale_text;

  /// No description provided for @appSetting_changeLanguageTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appSetting_changeLanguageTile_titleText;

  /// No description provided for @appSetting_changeLanguageDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get appSetting_changeLanguageDialog_titleText;

  /// No description provided for @appSetting_dateDisplayFormat_titleText.
  ///
  /// In en, this message translates to:
  /// **'Date display format ({formatTemplate})'**
  String appSetting_dateDisplayFormat_titleText(String formatTemplate);

  /// No description provided for @appSetting_dateDisplayFormat_titleTemplate_followSystemText.
  ///
  /// In en, this message translates to:
  /// **'follow system setting'**
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText;

  /// No description provided for @appSetting_dateDisplayFormat_subTitleText.
  ///
  /// In en, this message translates to:
  /// **'Configured date format will be applied to the date display on habit detail page.'**
  String get appSetting_dateDisplayFormat_subTitleText;

  /// No description provided for @appSetting_compactUISwitcher_titleText.
  ///
  /// In en, this message translates to:
  /// **'Enable Compact UI on habits page'**
  String get appSetting_compactUISwitcher_titleText;

  /// No description provided for @appSetting_compactUISwitcher_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Allow habits check table to display more content, but some UI and text may appear smaller.'**
  String get appSetting_compactUISwitcher_subtitleText;

  /// No description provided for @appSetting_collapsed_calendar_bararea_titleText.
  ///
  /// In en, this message translates to:
  /// **'Habits check area radio adjustment'**
  String get appSetting_collapsed_calendar_bararea_titleText;

  /// No description provided for @appSetting_collapsed_calendar_bararea_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Adjust percentage for more/less space in habits check table area.'**
  String get appSetting_collapsed_calendar_bararea_subtitleText;

  /// No description provided for @appSetting_collapsed_calendar_bararea_defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get appSetting_collapsed_calendar_bararea_defaultText;

  /// No description provided for @appSetting_reminderSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Reminder & Notification'**
  String get appSetting_reminderSubgroupText;

  /// No description provided for @appSetting_dailyReminder_titleText.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get appSetting_dailyReminder_titleText;

  /// No description provided for @appSetting_backupAndRestoreSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get appSetting_backupAndRestoreSubgroupText;

  /// No description provided for @appSetting_export_titleText.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get appSetting_export_titleText;

  /// No description provided for @appSetting_export_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Exported habits as JSON format, This file can be import back.'**
  String get appSetting_export_subtitleText;

  /// No description provided for @appSetting_import_titleText.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get appSetting_import_titleText;

  /// No description provided for @appSetting_import_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Import habits from json file.'**
  String get appSetting_import_subtitleText;

  /// No description provided for @appSetting_importDialog_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm import {count} habits?'**
  String appSetting_importDialog_confirmTitle(int count);

  /// No description provided for @appSetting_importDialog_confirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Note: Import doesn\'t delete existing habits.'**
  String get appSetting_importDialog_confirmSubtitle;

  /// No description provided for @appSetting_importDialog_confirm_confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get appSetting_importDialog_confirm_confirmText;

  /// No description provided for @appSetting_importDialog_confirm_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get appSetting_importDialog_confirm_cancelText;

  /// No description provided for @appSetting_importDialog_importingTitle.
  ///
  /// In en, this message translates to:
  /// **'Imported {completeCount}/{totalCount}'**
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount);

  /// No description provided for @appSetting_importDialog_completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete import {count}'**
  String appSetting_importDialog_completeTitle(int count);

  /// No description provided for @appSetting_importDialog_complete_closeLabel.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get appSetting_importDialog_complete_closeLabel;

  /// No description provided for @appSetting_resetConfig_titleText.
  ///
  /// In en, this message translates to:
  /// **'Reset configs'**
  String get appSetting_resetConfig_titleText;

  /// No description provided for @appSetting_resetConfig_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Reset all configs to default.'**
  String get appSetting_resetConfig_subtitleText;

  /// No description provided for @appSetting_resetConfigDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Reset configs?'**
  String get appSetting_resetConfigDialog_titleText;

  /// No description provided for @appSetting_resetConfigDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Reset all configs to default, must restart application to apply.'**
  String get appSetting_resetConfigDialog_subtitleText;

  /// No description provided for @appSetting_resetConfigDialog_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get appSetting_resetConfigDialog_cancelText;

  /// No description provided for @appSetting_resetConfigDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get appSetting_resetConfigDialog_confirmText;

  /// No description provided for @appSetting_resetConfigSuccess_snackbarText.
  ///
  /// In en, this message translates to:
  /// **'reset app configs succeed'**
  String get appSetting_resetConfigSuccess_snackbarText;

  /// No description provided for @appSetting_otherSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get appSetting_otherSubgroupText;

  /// No description provided for @appSetting_developMode_titleText.
  ///
  /// In en, this message translates to:
  /// **'Develop Mode'**
  String get appSetting_developMode_titleText;

  /// No description provided for @appSetting_clearCache_titleText.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get appSetting_clearCache_titleText;

  /// No description provided for @appSetting_clearCacheDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get appSetting_clearCacheDialog_titleText;

  /// No description provided for @appSetting_clearCacheDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'After clearing cache, some custom values will be restored to defaults.'**
  String get appSetting_clearCacheDialog_subtitleText;

  /// No description provided for @appSetting_clearCacheDialog_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get appSetting_clearCacheDialog_cancelText;

  /// No description provided for @appSetting_clearCacheDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get appSetting_clearCacheDialog_confirmText;

  /// No description provided for @appSetting_clearCache_snackBar_partSuccText.
  ///
  /// In en, this message translates to:
  /// **'Partial Cache cleared failed'**
  String get appSetting_clearCache_snackBar_partSuccText;

  /// No description provided for @appSetting_clearCache_snackBar_succText.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get appSetting_clearCache_snackBar_succText;

  /// No description provided for @appSetting_clearCache_snackBar_failText.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared failed'**
  String get appSetting_clearCache_snackBar_failText;

  /// No description provided for @appSetting_debugger_titleText.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get appSetting_debugger_titleText;

  /// No description provided for @appSetting_about_titleText.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get appSetting_about_titleText;

  /// No description provided for @appSetting_experimentalFeatureTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Experimental Features'**
  String get appSetting_experimentalFeatureTile_titleText;

  /// No description provided for @appSetting_synSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get appSetting_synSubgroupText;

  /// No description provided for @appSetting_syncOption_titleText.
  ///
  /// In en, this message translates to:
  /// **'Sync Options'**
  String get appSetting_syncOption_titleText;

  /// No description provided for @appSetting_notify_titleTile.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get appSetting_notify_titleTile;

  /// No description provided for @appSetting_notify_subtitleTile.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get appSetting_notify_subtitleTile;

  /// No description provided for @appSetting_notify_subtitleTile_android.
  ///
  /// In en, this message translates to:
  /// **'Tap to open system notification settings'**
  String get appSetting_notify_subtitleTile_android;

  /// No description provided for @appSync_nowTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get appSync_nowTile_titleText;

  /// No description provided for @appSync_nowTile_titleText_syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get appSync_nowTile_titleText_syncing;

  /// No description provided for @appSync_nowTile_dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{ymd} {jms}'**
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms);

  /// No description provided for @appSync_nowTile_text_noDate.
  ///
  /// In en, this message translates to:
  /// **'Last Sync: N/A'**
  String get appSync_nowTile_text_noDate;

  /// No description provided for @appSync_nowTile_text.
  ///
  /// In en, this message translates to:
  /// **'Last Sync: {dateStr}'**
  String appSync_nowTile_text(String dateStr);

  /// No description provided for @appSync_nowTile_errorText_noDate.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Error): N/A'**
  String get appSync_nowTile_errorText_noDate;

  /// No description provided for @appSync_nowTile_errorText.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Error): {dateStr}'**
  String appSync_nowTile_errorText(String dateStr);

  /// No description provided for @appSync_nowTile_syncingText.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get appSync_nowTile_syncingText;

  /// No description provided for @appSync_nowTile_syncingText_withPrt.
  ///
  /// In en, this message translates to:
  /// **'Syncing: {prt}'**
  String appSync_nowTile_syncingText_withPrt(num prt);

  /// No description provided for @appSync_nowTile_cancellingText.
  ///
  /// In en, this message translates to:
  /// **'Canceling...'**
  String get appSync_nowTile_cancellingText;

  /// No description provided for @appSync_nowTile_cancelText_noDate.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Cancelled): N/A'**
  String get appSync_nowTile_cancelText_noDate;

  /// No description provided for @appSync_nowTile_cancelText.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Cancelled): {dateStr}'**
  String appSync_nowTile_cancelText(String dateStr);

  /// No description provided for @appSync_failedTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Check Failure Logs'**
  String get appSync_failedTile_titleText;

  /// No description provided for @appSync_failedTile_errorText.
  ///
  /// In en, this message translates to:
  /// **'[Error]: {info}'**
  String appSync_failedTile_errorText(String info);

  /// No description provided for @appSync_failedTile_webdavMulti_counterText.
  ///
  /// In en, this message translates to:
  /// **'{reason}: {count}'**
  String appSync_failedTile_webdavMulti_counterText(String reason, int count);

  /// No description provided for @appSync_webdav_resultStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, success {Completed} cancelled {Canceled} failed {Failed} multi {Multiple statuses} other {Unknown status}}'**
  String appSync_webdav_resultStatus(String status);

  /// No description provided for @appSync_webdav_resultStatus_withReason.
  ///
  /// In en, this message translates to:
  /// **'{status, select, success {Completed due to {reason}} cancelled {Canceled due to {reason}} failed {Failed due to {reason}} multi {Multiple statuses due to {reason}} other {Unknown status}}'**
  String appSync_webdav_resultStatus_withReason(String status, String reason);

  /// No description provided for @appSync_webdav_resultReason.
  ///
  /// In en, this message translates to:
  /// **'{reason, select, error {Error} userAction {User action required} missingHabitUuid {Missing habit UUID} empty {Empty data} other {Unknown reason}}'**
  String appSync_webdav_resultReason(String reason);

  /// No description provided for @appSync_webdav_newServerConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'New Location'**
  String get appSync_webdav_newServerConfirmDialog_titleText;

  /// No description provided for @appSync_webdav_newServerConfirmDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Syncing will create necessary directories and upload local habits to the server. Continue?'**
  String get appSync_webdav_newServerConfirmDialog_subtitleText;

  /// No description provided for @appSync_webdav_newServerConfirmDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'Sync Now!'**
  String get appSync_webdav_newServerConfirmDialog_confirmText;

  /// No description provided for @appSync_webdav_oldServerConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sync'**
  String get appSync_webdav_oldServerConfirmDialog_titleText;

  /// No description provided for @appSync_webdav_oldServerConfirmDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Directory isn\'t empty. Syncing will merge server and local habits. Continue?'**
  String get appSync_webdav_oldServerConfirmDialog_subtitleText;

  /// No description provided for @appSync_webdav_oldServerConfirmDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Merge'**
  String get appSync_webdav_oldServerConfirmDialog_confirmText;

  /// No description provided for @appSync_exportAllLogsTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Export Failed Sync Logs'**
  String get appSync_exportAllLogsTile_titleText;

  /// No description provided for @appSync_exportAllLogsTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'{isEmpty, select, true {No log founded} false {Tap to export} other {loading...}}'**
  String appSync_exportAllLogsTile_subtitleText(String isEmpty);

  /// No description provided for @appSync_syncServerType_text.
  ///
  /// In en, this message translates to:
  /// **'{isCurrent, select, true {Current: } other {}}{name, select, webdav {WebDAV} fake {Fake (Only For Debugger)} other {Unknown ({name})}}'**
  String appSync_syncServerType_text(String name, String isCurrent);

  /// No description provided for @appSync_networkType_text.
  ///
  /// In en, this message translates to:
  /// **'{type, select, mobile {Mobile} wifi {Wifi} other {Unknown}}'**
  String appSync_networkType_text(String type);

  /// Localized display text for app sync interval
  ///
  /// In en, this message translates to:
  /// **'{name, select, manual {Manual} minute5 {5 Minutes} minute15 {15 Minutes} minute30 {30 Minutes} hour1 {1 Hour} other {Unknown}}'**
  String appSync_syncInterval_text(String name);

  /// No description provided for @appSync_syncIntervalTile_title.
  ///
  /// In en, this message translates to:
  /// **'Fetch Interval'**
  String get appSync_syncIntervalTile_title;

  /// No description provided for @appSync_summaryTile_title.
  ///
  /// In en, this message translates to:
  /// **'Sync Server'**
  String get appSync_summaryTile_title;

  /// No description provided for @appSync_summaryTile_subtitle_text_notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get appSync_summaryTile_subtitle_text_notConfigured;

  /// No description provided for @appSync_exportAllLogsTile_exportSubjectText.
  ///
  /// In en, this message translates to:
  /// **'All recent failed sync logs'**
  String get appSync_exportAllLogsTile_exportSubjectText;

  /// No description provided for @appSync_serverEditor_saveDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Save Changes'**
  String get appSync_serverEditor_saveDialog_titleText;

  /// No description provided for @appSync_serverEditor_saveDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Saving will overwrite previous server configuration.'**
  String get appSync_serverEditor_saveDialog_subtitleText;

  /// No description provided for @appSync_serverEditor_exitDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get appSync_serverEditor_exitDialog_titleText;

  /// No description provided for @appSync_serverEditor_exitDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Exiting will discard all unsaved changes.'**
  String get appSync_serverEditor_exitDialog_subtitleText;

  /// No description provided for @appSync_serverEditor_deleteDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get appSync_serverEditor_deleteDialog_titleText;

  /// No description provided for @appSync_serverEditor_deleteDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Deleting will remove current server config.'**
  String get appSync_serverEditor_deleteDialog_subtitleText;

  /// No description provided for @appSync_serverEditor_titleText_add.
  ///
  /// In en, this message translates to:
  /// **'New Sync Server'**
  String get appSync_serverEditor_titleText_add;

  /// No description provided for @appSync_serverEditor_titleText_modify.
  ///
  /// In en, this message translates to:
  /// **'Modify Sync Server'**
  String get appSync_serverEditor_titleText_modify;

  /// No description provided for @appSync_serverEditor_advance_titleText.
  ///
  /// In en, this message translates to:
  /// **'Advanced Configs'**
  String get appSync_serverEditor_advance_titleText;

  /// No description provided for @appSync_serverEditor_pathTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get appSync_serverEditor_pathTile_titleText;

  /// No description provided for @appSync_serverEditor_pathTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid WebDAV path here.'**
  String get appSync_serverEditor_pathTile_hintText;

  /// No description provided for @appSync_serverEditor_pathTile_errorText_emptyPath.
  ///
  /// In en, this message translates to:
  /// **'Path shouldn\'t be empty!'**
  String get appSync_serverEditor_pathTile_errorText_emptyPath;

  /// No description provided for @appSync_serverEditor_usernameTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get appSync_serverEditor_usernameTile_titleText;

  /// No description provided for @appSync_serverEditor_usernameTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Enter username here, leave empty if not required.'**
  String get appSync_serverEditor_usernameTile_hintText;

  /// No description provided for @appSync_serverEditor_passwordTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appSync_serverEditor_passwordTile_titleText;

  /// No description provided for @appSync_serverEditor_ignoreSSLTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Ignore SSL Certificate'**
  String get appSync_serverEditor_ignoreSSLTile_titleText;

  /// No description provided for @appSync_serverEditor_timeoutTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Sync Timeout Seconds'**
  String get appSync_serverEditor_timeoutTile_titleText;

  /// No description provided for @appSync_serverEditor_timeoutTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Default: {seconds, plural, =0 {Infinite} other {{seconds}{unit}}}'**
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit);

  /// No description provided for @appSync_serverEditor_timeoutTile_unitText.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get appSync_serverEditor_timeoutTile_unitText;

  /// No description provided for @appSync_serverEditor_connTimeoutTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Network Connection Timeout Seconds'**
  String get appSync_serverEditor_connTimeoutTile_titleText;

  /// No description provided for @appSync_serverEditor_connTimeoutTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Default: {seconds, plural, =0 {Infinite} other {{seconds}{unit}}}'**
  String appSync_serverEditor_connTimeoutTile_hintText(int seconds, String unit);

  /// No description provided for @appSync_serverEditor_connTimeoutTile_unitText.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get appSync_serverEditor_connTimeoutTile_unitText;

  /// No description provided for @appSync_serverEditor_connRetryCountTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Network Connection Retry Count'**
  String get appSync_serverEditor_connRetryCountTile_titleText;

  /// No description provided for @appSync_serverEditor_connRetryCountTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Default: {count, plural, =0 {Retry disabled} other {{count}}}'**
  String appSync_serverEditor_connRetryCountTile_hintText(int count);

  /// No description provided for @appSync_serverEditor_netTypeTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Network Sync Mode'**
  String get appSync_serverEditor_netTypeTile_titleText;

  /// No description provided for @appSync_serverEditor_netTypeTile_typeTooltip.
  ///
  /// In en, this message translates to:
  /// **'{type, select, mobile {Sync on Cellular Network} wifi {Sync on Wifi} other {Unknown}}'**
  String appSync_serverEditor_netTypeTile_typeTooltip(String type);

  /// No description provided for @appSync_serverEditor_netTypeTile_lowDataText.
  ///
  /// In en, this message translates to:
  /// **'LowData'**
  String get appSync_serverEditor_netTypeTile_lowDataText;

  /// No description provided for @appSync_noti_readyToSync_body.
  ///
  /// In en, this message translates to:
  /// **'Preparing to sync...'**
  String get appSync_noti_readyToSync_body;

  /// No description provided for @appSync_noti_syncing_title.
  ///
  /// In en, this message translates to:
  /// **'{synced, select, synced {Synced ({type})} failed {Sync Failed ({type})} other {Syncing ({type})}}'**
  String appSync_noti_syncing_title(String synced, String type);

  /// No description provided for @appSync_serverEditor_netTypeTile_lowDataTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync in Low Data Mode'**
  String get appSync_serverEditor_netTypeTile_lowDataTooltip;

  /// No description provided for @experimentalFeatures_warnginBanner_title.
  ///
  /// In en, this message translates to:
  /// **'One or more experimental features are enabled, Use with caution.'**
  String get experimentalFeatures_warnginBanner_title;

  /// No description provided for @experimentalFeatures_habitSyncTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Habit Cloud Sync'**
  String get experimentalFeatures_habitSyncTile_titleText;

  /// No description provided for @experimentalFeatures_habitSyncTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Once enabled, the app\'s sync option will appear in settings'**
  String get experimentalFeatures_habitSyncTile_subtitleText;

  /// No description provided for @experimentalFeatures_warnTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Experimental feature ({syncName}) is disabled, but the function is still running.'**
  String experimentalFeatures_warnTile_titleText(String syncName);

  /// No description provided for @experimentalFeatures_warnTile_forHabitSyncText.
  ///
  /// In en, this message translates to:
  /// **'To completely disable, long press to access \'{menuName}\' and turn it off.'**
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName);

  /// No description provided for @experimentalFeatures_habitSearchTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Habit Search'**
  String get experimentalFeatures_habitSearchTile_titleText;

  /// No description provided for @experimentalFeatures_habitSearchTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Once enabled, a search bar will appear at the top of the Habits screen and allowing to search habits.'**
  String get experimentalFeatures_habitSearchTile_subtitleText;

  /// No description provided for @appAbout_appbarTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get appAbout_appbarTile_titleText;

  /// No description provided for @appAbout_versionTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Version: {appVersion}'**
  String appAbout_versionTile_titleText(String appVersion);

  /// No description provided for @appAbout_versionTile_changeLogPath.
  ///
  /// In en, this message translates to:
  /// **'CHANGELOG.md'**
  String get appAbout_versionTile_changeLogPath;

  /// No description provided for @appAbout_sourceCodeTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get appAbout_sourceCodeTile_titleText;

  /// No description provided for @appAbout_issueTrackerTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Issue tracker'**
  String get appAbout_issueTrackerTile_titleText;

  /// No description provided for @appAbout_contactEmailTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Contact me'**
  String get appAbout_contactEmailTile_titleText;

  /// No description provided for @appAbout_contactEmailTile_emailBody.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------'**
  String get appAbout_contactEmailTile_emailBody;

  /// No description provided for @appAbout_licenseTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get appAbout_licenseTile_titleText;

  /// No description provided for @appAbout_licenseTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Apache License, Version 2.0'**
  String get appAbout_licenseTile_subtitleText;

  /// No description provided for @appAbout_licenseThirdPartyTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Third Party Licensing Statement'**
  String get appAbout_licenseThirdPartyTile_titleText;

  /// No description provided for @appAbout_licenseThirdPartyTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'flutter'**
  String get appAbout_licenseThirdPartyTile_subtitleText;

  /// No description provided for @appAbout_privacyTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get appAbout_privacyTile_titleText;

  /// No description provided for @appAbout_privacyTile_subTitleText.
  ///
  /// In en, this message translates to:
  /// **'Access the privacy policy in this app'**
  String get appAbout_privacyTile_subTitleText;

  /// No description provided for @appAbout_donateTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get appAbout_donateTile_titleText;

  /// No description provided for @appAbout_donateTile_subTitleText.
  ///
  /// In en, this message translates to:
  /// **'I\'m a personal developer. If you like this app, please buy me a ☕.'**
  String get appAbout_donateTile_subTitleText;

  /// Donate begin with `@` and split with `,`, available ways: paypal, buyMeACoffee, alipay, wechatPay
  ///
  /// In en, this message translates to:
  /// **'@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll'**
  String get appAbout_donateTile_ways;

  /// No description provided for @donateWay_paypal.
  ///
  /// In en, this message translates to:
  /// **'Paypal'**
  String get donateWay_paypal;

  /// No description provided for @donateWay_buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get donateWay_buyMeACoffee;

  /// No description provided for @donateWay_alipay.
  ///
  /// In en, this message translates to:
  /// **'Alipay'**
  String get donateWay_alipay;

  /// No description provided for @donateWay_wechatPay.
  ///
  /// In en, this message translates to:
  /// **'Wechat Pay'**
  String get donateWay_wechatPay;

  /// No description provided for @donateWay_cryptoCurrency.
  ///
  /// In en, this message translates to:
  /// **'Crypto Currencies'**
  String get donateWay_cryptoCurrency;

  /// No description provided for @donateWay_cryptoCurrency_BTC.
  ///
  /// In en, this message translates to:
  /// **'BTC'**
  String get donateWay_cryptoCurrency_BTC;

  /// No description provided for @donateWay_cryptoCurrency_ETH.
  ///
  /// In en, this message translates to:
  /// **'ETH'**
  String get donateWay_cryptoCurrency_ETH;

  /// No description provided for @donateWay_cryptoCurrency_BNB.
  ///
  /// In en, this message translates to:
  /// **'BNB'**
  String get donateWay_cryptoCurrency_BNB;

  /// No description provided for @donateWay_cryptoCurrency_AVAX.
  ///
  /// In en, this message translates to:
  /// **'AVAX'**
  String get donateWay_cryptoCurrency_AVAX;

  /// No description provided for @donateWay_cryptoCurrency_FTM.
  ///
  /// In en, this message translates to:
  /// **'FTM'**
  String get donateWay_cryptoCurrency_FTM;

  /// No description provided for @donateWay_firstQRGroup.
  ///
  /// In en, this message translates to:
  /// **'Alipay & Wechat Pay'**
  String get donateWay_firstQRGroup;

  /// No description provided for @appAbout_donateDialog_copiedCrypto_msg.
  ///
  /// In en, this message translates to:
  /// **'Copied {name}\'s Address'**
  String appAbout_donateDialog_copiedCrypto_msg(String name);

  /// No description provided for @batchCheckin_appbar_title.
  ///
  /// In en, this message translates to:
  /// **'Batch Check-in'**
  String get batchCheckin_appbar_title;

  /// No description provided for @batchCheckin_datePicker_prevButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get batchCheckin_datePicker_prevButton_tooltip;

  /// No description provided for @batchCheckin_datePicker_nextButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get batchCheckin_datePicker_nextButton_tooltip;

  /// No description provided for @batchCheckin_status_skip_text.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get batchCheckin_status_skip_text;

  /// No description provided for @batchCheckin_status_ok_text.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get batchCheckin_status_ok_text;

  /// No description provided for @batchCheckin_status_double_text.
  ///
  /// In en, this message translates to:
  /// **'x2 Hit!'**
  String get batchCheckin_status_double_text;

  /// No description provided for @batchCheckin_status_zero_text.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get batchCheckin_status_zero_text;

  /// No description provided for @batchCheckin_habits_groupTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Habit} other{Habits}} selected'**
  String batchCheckin_habits_groupTitle(int count);

  /// No description provided for @batchCheckin_save_button_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get batchCheckin_save_button_text;

  /// No description provided for @batchCheckin_reset_button_text.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get batchCheckin_reset_button_text;

  /// No description provided for @batchCheckin_completed_snackbar_text.
  ///
  /// In en, this message translates to:
  /// **'Modified {count, plural, =1{habit\'s status} other{status of {count} habits}}'**
  String batchCheckin_completed_snackbar_text(int count);

  /// No description provided for @batchCheckin_save_confirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Existing Records'**
  String get batchCheckin_save_confirmDialog_title;

  /// No description provided for @batchCheckin_save_confirmDialog_body.
  ///
  /// In en, this message translates to:
  /// **'Existing records will be overwritten After saving, previous records will be lost.'**
  String get batchCheckin_save_confirmDialog_body;

  /// No description provided for @batchCheckin_save_confirmDialog_confirmButton_text.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get batchCheckin_save_confirmDialog_confirmButton_text;

  /// No description provided for @batchCheckin_save_confirmDialog_cancelButton_text.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get batchCheckin_save_confirmDialog_cancelButton_text;

  /// No description provided for @batchCheckin_close_confirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Return'**
  String get batchCheckin_close_confirmDialog_title;

  /// No description provided for @batchCheckin_close_confirmDialog_body.
  ///
  /// In en, this message translates to:
  /// **'Check-in Status Changes won\'t be applied before saved'**
  String get batchCheckin_close_confirmDialog_body;

  /// No description provided for @batchCheckin_close_confirmDialog_confirmButton_text.
  ///
  /// In en, this message translates to:
  /// **'exit'**
  String get batchCheckin_close_confirmDialog_confirmButton_text;

  /// No description provided for @batchCheckin_close_confirmDialog_cancelButton_text.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get batchCheckin_close_confirmDialog_cancelButton_text;

  /// No description provided for @appReminder_dailyReminder_title.
  ///
  /// In en, this message translates to:
  /// **'🏝 Did you stick to your habits today?'**
  String get appReminder_dailyReminder_title;

  /// No description provided for @appReminder_dailyReminder_body.
  ///
  /// In en, this message translates to:
  /// **'click to enter app and punch in on time.'**
  String get appReminder_dailyReminder_body;

  /// No description provided for @common_habitColorType_cc1.
  ///
  /// In en, this message translates to:
  /// **'Deep lilac'**
  String get common_habitColorType_cc1;

  /// No description provided for @common_habitColorType_cc2.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get common_habitColorType_cc2;

  /// No description provided for @common_habitColorType_cc3.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get common_habitColorType_cc3;

  /// No description provided for @common_habitColorType_cc4.
  ///
  /// In en, this message translates to:
  /// **'Royal blue'**
  String get common_habitColorType_cc4;

  /// No description provided for @common_habitColorType_cc5.
  ///
  /// In en, this message translates to:
  /// **'Dark cyan'**
  String get common_habitColorType_cc5;

  /// No description provided for @common_habitColorType_cc6.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get common_habitColorType_cc6;

  /// No description provided for @common_habitColorType_cc7.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get common_habitColorType_cc7;

  /// No description provided for @common_habitColorType_cc8.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get common_habitColorType_cc8;

  /// No description provided for @common_habitColorType_cc9.
  ///
  /// In en, this message translates to:
  /// **'Lime green'**
  String get common_habitColorType_cc9;

  /// No description provided for @common_habitColorType_cc10.
  ///
  /// In en, this message translates to:
  /// **'Dark orchid'**
  String get common_habitColorType_cc10;

  /// unknown habit color type name
  ///
  /// In en, this message translates to:
  /// **'Color {index}'**
  String common_habitColorType_default(int index);

  /// No description provided for @common_customDateTimeFormatPicker_useSystemFormat_text.
  ///
  /// In en, this message translates to:
  /// **'Use system format'**
  String get common_customDateTimeFormatPicker_useSystemFormat_text;

  /// No description provided for @common_customDateTimeFormatPicker_fmtTileText.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get common_customDateTimeFormatPicker_fmtTileText;

  /// No description provided for @common_customDateTimeFormatPicker_ymd_text.
  ///
  /// In en, this message translates to:
  /// **'Year Month Day'**
  String get common_customDateTimeFormatPicker_ymd_text;

  /// No description provided for @common_customDateTimeFormatPicker_mdy_text.
  ///
  /// In en, this message translates to:
  /// **'Month Day Year'**
  String get common_customDateTimeFormatPicker_mdy_text;

  /// No description provided for @common_customDateTimeFormatPicker_dmy_text.
  ///
  /// In en, this message translates to:
  /// **'Day Month Year'**
  String get common_customDateTimeFormatPicker_dmy_text;

  /// No description provided for @common_customDateTimeFormatPicker_SepTileText.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get common_customDateTimeFormatPicker_SepTileText;

  /// No description provided for @common_customDateTimeFormatPicker_sepDash_text.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get common_customDateTimeFormatPicker_sepDash_text;

  /// No description provided for @common_customDateTimeFormatPicker_sepSlash_text.
  ///
  /// In en, this message translates to:
  /// **'Slash'**
  String get common_customDateTimeFormatPicker_sepSlash_text;

  /// No description provided for @common_customDateTimeFormatPicker_sepSpace_text.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get common_customDateTimeFormatPicker_sepSpace_text;

  /// No description provided for @common_customDateTimeFormatPicker_sepDot_text.
  ///
  /// In en, this message translates to:
  /// **'Dot'**
  String get common_customDateTimeFormatPicker_sepDot_text;

  /// No description provided for @common_customDateTimeFormatPicker_empty_text.
  ///
  /// In en, this message translates to:
  /// **'No Separator'**
  String get common_customDateTimeFormatPicker_empty_text;

  /// split char
  ///
  /// In en, this message translates to:
  /// **'{splitName}: \"{splitChar}\"'**
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar);

  /// No description provided for @common_customDateTimeFormatPicker_12Hour_text.
  ///
  /// In en, this message translates to:
  /// **'Use 12-hour format'**
  String get common_customDateTimeFormatPicker_12Hour_text;

  /// No description provided for @common_customDateTimeFormatPicker_monthName_text.
  ///
  /// In en, this message translates to:
  /// **'Use full name'**
  String get common_customDateTimeFormatPicker_monthName_text;

  /// No description provided for @common_customDateTimeFormatPicker_applyFreqChart_text.
  ///
  /// In en, this message translates to:
  /// **'Apply for Freq Chart'**
  String get common_customDateTimeFormatPicker_applyFreqChart_text;

  /// No description provided for @common_customDateTimeFormatPicker_applyHeapmap_text.
  ///
  /// In en, this message translates to:
  /// **'Apply for Calendar'**
  String get common_customDateTimeFormatPicker_applyHeapmap_text;

  /// No description provided for @common_customDateTimeFormatPicker_cancelButton_text.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get common_customDateTimeFormatPicker_cancelButton_text;

  /// No description provided for @common_customDateTimeFormatPicker_confirmButton_text.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get common_customDateTimeFormatPicker_confirmButton_text;

  /// No description provided for @common_errorPage_title.
  ///
  /// In en, this message translates to:
  /// **'Oops, Crashed!'**
  String get common_errorPage_title;

  /// No description provided for @common_errorPage_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied crash information'**
  String get common_errorPage_copied;

  /// No description provided for @common_enable_text.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get common_enable_text;

  /// No description provided for @calendarPicker_clip_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarPicker_clip_today;

  /// No description provided for @calendarPicker_clip_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get calendarPicker_clip_tomorrow;

  /// No description provided for @calendarPicker_clip_after7Days.
  ///
  /// In en, this message translates to:
  /// **'Next {date}'**
  String calendarPicker_clip_after7Days(DateTime date);

  /// No description provided for @exportConfirmDialog_title_exportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all habits?'**
  String get exportConfirmDialog_title_exportAll;

  /// No description provided for @exportConfirmDialog_title_exportMulti.
  ///
  /// In en, this message translates to:
  /// **'Export {number, plural, =0{current habit} =1{1 habit} other{{number} habits}}?'**
  String exportConfirmDialog_title_exportMulti(int number);

  /// No description provided for @exportConfirmDialog_option_includeRecords.
  ///
  /// In en, this message translates to:
  /// **'include records'**
  String get exportConfirmDialog_option_includeRecords;

  /// No description provided for @exportConfirmDialog_cancel_buttonText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get exportConfirmDialog_cancel_buttonText;

  /// No description provided for @exportConfirmDialog_confirm_buttonText.
  ///
  /// In en, this message translates to:
  /// **'export'**
  String get exportConfirmDialog_confirm_buttonText;

  /// No description provided for @debug_logLevelTile_title.
  ///
  /// In en, this message translates to:
  /// **'Logging Level'**
  String get debug_logLevelTile_title;

  /// No description provided for @debug_logLevelDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Change Logging Level'**
  String get debug_logLevelDialog_title;

  /// No description provided for @debug_logLevel_debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug_logLevel_debug;

  /// No description provided for @debug_logLevel_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get debug_logLevel_info;

  /// No description provided for @debug_logLevel_warn.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get debug_logLevel_warn;

  /// No description provided for @debug_logLevel_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get debug_logLevel_error;

  /// No description provided for @debug_logLevel_fatal.
  ///
  /// In en, this message translates to:
  /// **'Fatal'**
  String get debug_logLevel_fatal;

  /// No description provided for @debug_collectLogTile_title.
  ///
  /// In en, this message translates to:
  /// **'Collecting Logs'**
  String get debug_collectLogTile_title;

  /// No description provided for @debug_collectLogTile_enable_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop logging collection.'**
  String get debug_collectLogTile_enable_subtitle;

  /// No description provided for @debug_collectLogTile_disable_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to start logging collection.'**
  String get debug_collectLogTile_disable_subtitle;

  /// No description provided for @debug_downladDebugLogs_subject.
  ///
  /// In en, this message translates to:
  /// **'Downloading debugging logs'**
  String get debug_downladDebugLogs_subject;

  /// No description provided for @dbeug_clearDebugLogs_complete_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Debugging logs Cleared.'**
  String get dbeug_clearDebugLogs_complete_snackbar;

  /// No description provided for @debug_downladDebugInfo_subject.
  ///
  /// In en, this message translates to:
  /// **'Downloading debugging information'**
  String get debug_downladDebugInfo_subject;

  /// No description provided for @debug_downladDebugZip_subject.
  ///
  /// In en, this message translates to:
  /// **'Downloading {fileName}'**
  String debug_downladDebugZip_subject(String fileName);

  /// No description provided for @debug_missingDebugLogFile_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Debug log doesn\'t exist.'**
  String get debug_missingDebugLogFile_snackbar;

  /// No description provided for @debug_debuggerLogCard_title.
  ///
  /// In en, this message translates to:
  /// **'Logging Information'**
  String get debug_debuggerLogCard_title;

  /// No description provided for @debug_debuggerLogCard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes local debugging log information, need to turn on the log collection switcher.'**
  String get debug_debuggerLogCard_subtitle;

  /// No description provided for @debug_debuggerLogCard_saveButton_text.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get debug_debuggerLogCard_saveButton_text;

  /// No description provided for @debug_debuggerLogCard_clearButton_text.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get debug_debuggerLogCard_clearButton_text;

  /// No description provided for @debug_debuggerInfoCard_title.
  ///
  /// In en, this message translates to:
  /// **'Debugging Information'**
  String get debug_debuggerInfoCard_title;

  /// No description provided for @debug_debuggerInfoCard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes app\'s debugging information.'**
  String get debug_debuggerInfoCard_subtitle;

  /// No description provided for @debug_debuggerInfoCard_openButton_text.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get debug_debuggerInfoCard_openButton_text;

  /// No description provided for @debug_debuggerInfoCard_saveButton_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get debug_debuggerInfoCard_saveButton_text;

  /// No description provided for @debug_debuggerInfo_notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Collecting App\'s Info...'**
  String get debug_debuggerInfo_notificationTitle;

  /// No description provided for @confirmDialog_confirm_text.
  ///
  /// In en, this message translates to:
  /// **'{type, select, save {Save} exit {Exit} delete {Delete} other {Confirm}}'**
  String confirmDialog_confirm_text(String type);

  /// No description provided for @confirmDialog_cancel_text.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmDialog_cancel_text;

  /// No description provided for @snackbar_undoText.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get snackbar_undoText;

  /// No description provided for @snackbar_dismissText.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get snackbar_dismissText;

  /// No description provided for @contributors_tile_title.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors_tile_title;

  /// No description provided for @userAction_tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get userAction_tap;

  /// No description provided for @userAction_doubleTap.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get userAction_doubleTap;

  /// No description provided for @userAction_longTap.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get userAction_longTap;

  /// No description provided for @channelName_habitReminder.
  ///
  /// In en, this message translates to:
  /// **'Habit Reminder'**
  String get channelName_habitReminder;

  /// No description provided for @channelName_appReminder.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get channelName_appReminder;

  /// No description provided for @channelName_appDebugger.
  ///
  /// In en, this message translates to:
  /// **'Debugger'**
  String get channelName_appDebugger;

  /// No description provided for @channelName_appSyncing.
  ///
  /// In en, this message translates to:
  /// **'Sync Process'**
  String get channelName_appSyncing;

  /// No description provided for @channelDesc_appSyncing.
  ///
  /// In en, this message translates to:
  /// **'Used to show sync progress and non-failure results'**
  String get channelDesc_appSyncing;

  /// No description provided for @channelName_appSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get channelName_appSyncFailed;

  /// No description provided for @channelDesc_appSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Used to alert when sync fails'**
  String get channelDesc_appSyncFailed;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'cs', 'de', 'en', 'es', 'fa', 'fr', 'he', 'it', 'nb', 'pl', 'pt', 'ru', 'tr', 'uk', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hant': return L10nZhHant();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return L10nAr();
    case 'cs': return L10nCs();
    case 'de': return L10nDe();
    case 'en': return L10nEn();
    case 'es': return L10nEs();
    case 'fa': return L10nFa();
    case 'fr': return L10nFr();
    case 'he': return L10nHe();
    case 'it': return L10nIt();
    case 'nb': return L10nNb();
    case 'pl': return L10nPl();
    case 'pt': return L10nPt();
    case 'ru': return L10nRu();
    case 'tr': return L10nTr();
    case 'uk': return L10nUk();
    case 'vi': return L10nVi();
    case 'zh': return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
