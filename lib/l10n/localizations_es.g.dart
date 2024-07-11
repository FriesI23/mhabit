import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get localeScriptName => 'Inglés';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Guardar';

  @override
  String get habitEdit_habitName_hintText => 'Nombre del hábito';

  @override
  String get habitEdit_colorPicker_title => 'Escoge un color';

  @override
  String get habitEdit_habitTypeDialog_title => 'Tipo de hábito';

  @override
  String get habitEdit_habitType_positiveText => 'Positivo';

  @override
  String get habitEdit_habitType_negativeText => 'Negativo';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Meta diaria, estándar $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Mínimo diario, estándar $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Reto diario debe llegar a $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Reto diario debe ser menor que $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Reto diario debe ser mayor que $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'La meta diaria debe ser inferior a $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Unidad de meta diaria';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Objetivo máximo de meta diaria';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Valor no válido, debe permanecer vacío o ser mayor o igual que $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Límite máximo diario';

  @override
  String get habitEdit_frequencySelector_title => 'Seleccionar frecuencia';

  @override
  String get habitEdit_habitFreq_daily => 'Diariamente';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'Veces por semana';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'veces al mes';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'veces en';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'días';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Diariamente';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Al menos $freq veces por semana',
      one: 'Por semana',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Al menos $freq veces al mes',
      one: 'Al mes',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Al menos $freq veces cada $days días',
      one: 'Cada $days días',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    return '$targetDays días';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Seleccionar días';

  @override
  String get habitEdit_targetDays => 'días';

  @override
  String get habitEdit_reminder_hintText => 'Recordatorio';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Cualquier día de la semana';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' cada semana';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Cualquier día del mes';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' cada mes';

  @override
  String get habitEdit_reminderQuest_hintText => 'Pregunta, ej, ¿Has hecho ejercicio hoy?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Escoge el tipo de recordatorio';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Cuándo es necesario comprobarlo';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Diariamente';

  @override
  String get habitEdit_reminder_dialogType_week => 'Semanalmente';

  @override
  String get habitEdit_reminder_dialogType_month => 'Mensualmente';

  @override
  String get habitEdit_reminder_dialogConfirm => 'confirmar';

  @override
  String get habitEdit_reminder_dialogCancel => 'cancelar';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Confirmar';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => '¿Quieres borrar este recordatorio?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'confirmar';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'cancelar';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Lun';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Mar';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Mie';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Jue';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Vie';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sáb';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Dom';

  @override
  String get habitEdit_desc_hintText => 'Memo, acepta Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Creado por: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Modificado: ';

  @override
  String get habitDisplay_fab_text => 'Nuevo hábito';

  @override
  String get habitDisplay_emptyImage_text_01 => 'Un viaje de cientos de kilómetros empieza con un único paso';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => '¿Quieres archivar los hábitos seleccionados?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'cancelar';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return '$count hábitos archivados';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => '¿Quieres desarchivar los hábitos seleccionados?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'cancelar';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return '$count hábitos desarchivados';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => '¿Quieres borrar los hábitos seleccionados?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'cancelar';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return '$count hábitos borrados';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Seleccionar todo';

  @override
  String get habitDisplay_editPopMenu_export => 'Exportar';

  @override
  String get habitDisplay_editPopMenu_delete => 'Borrar';

  @override
  String get habitDisplay_editPopMenu_clone => 'Plantilla';

  @override
  String get habitDisplay_editButton_tooltip => 'Editar';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archivar';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Desarchivar';

  @override
  String get habitDisplay_settingButton_tooltip => 'Ajustes';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'En curso';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Completados';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'En progreso';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Archivados';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Hábitos principales: Cambios en 30 días';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Tema Claro';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Tema Oscuro';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Según el sistema';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Mostrar archivados';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Mostrar completados';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Mostrar Activos';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Ajustes';

  @override
  String get habitDisplay_sort_reverseText => 'Deshacer';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Desc)';

  @override
  String get habitDisplay_sortType_manual => 'Orden propio';

  @override
  String get habitDisplay_sortType_name => 'Por nombre';

  @override
  String get habitDisplay_sortType_colorType => 'Por color';

  @override
  String get habitDisplay_sortType_progress => 'Por puntuación';

  @override
  String get habitDisplay_sortType_startT => 'Por día de comienzo';

  @override
  String get habitDisplay_sortType_status => 'Por estado';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Ordenar';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'cancelar';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Búsqueda de errores';

  @override
  String get habitDetail_editButton_tooltip => 'Editar';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Desarchivar';

  @override
  String get habitDetail_editPopMenu_archive => 'Archivar';

  @override
  String get habitDetail_editPopMenu_export => 'Exportar';

  @override
  String get habitDetail_editPopMenu_delete => 'Borrar';

  @override
  String get habitDetail_editPopMenu_clone => 'Plantilla';

  @override
  String get habitDetail_confirmDialog_confirm => 'confirmar';

  @override
  String get habitDetail_confirmDialog_cancel => 'cancelar';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => '¿Quieres archivar este hábito?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => '¿Quieres desarchivar este hábito?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => '¿Quieres borrar este hábito?';

  @override
  String get habitDetail_summary_title => 'Resumen';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'La puntuación actual es $score, y han pasado $days días desde el inicio.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Empezar en $days días. ',
      one: 'Empezar mañana.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'DEBAJO DEL OBJETIVO',
      one: 'NO COMPLETADO',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'PERFECTO',
      one: 'DEMASIADO',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Meta',
      two: 'Umbral',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Unidad: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'vacío';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Días',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'd';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Registros';

  @override
  String get habitDetail_scoreChart_title => 'Puntuación';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Día';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Semana';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Mes';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Año';

  @override
  String get habitDetail_freqChart_freqTitle => 'Frecuencia';

  @override
  String get habitDetail_freqChart_historyTitle => 'Historial';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Frencuencia e historial';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Semana';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Mes';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Año';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Presente';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Esconder gráfico de historial';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Mostrar gráfico de historial';

  @override
  String get habitDetail_descSubgroup_title => 'Memo';

  @override
  String get habitDetail_otherSubgroup_title => 'Otros';

  @override
  String get habitDetail_habitType_title => 'Tipo';

  @override
  String get habitDetail_reminderTile_title => 'Recordatorio';

  @override
  String get habitDetail_freqTile_title => 'Repetición';

  @override
  String get habitDetail_startDateTile_title => 'Fecha de inicio';

  @override
  String get habitDetail_createDateTile_title => 'Creado';

  @override
  String get habitDetail_modifyDateTile_title => 'Modificado';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'fecha';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'valor';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'Volver a hoy';

  @override
  String get habitDetail_notFoundText => 'Error al cargar el hábito';

  @override
  String get habitDetail_notFoundRetryText => 'Volver a intentar';

  @override
  String get habitDetail_changeGoal_title => 'Cambiar meta';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'Actualmente: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'realizado: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'no realizado';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Meta diaria, predeterminado: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'cancelar';

  @override
  String get habitDetail_changeGoal_saveText => 'guardar';

  @override
  String get habitDetail_skipReason_title => 'Saltar razón';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Escribe algo aquí...';

  @override
  String get habitDetail_skipReason_cancelText => 'cancelar';

  @override
  String get habitDetail_skipReason_saveText => 'guardar';

  @override
  String get appSetting_appbar_titleText => 'Ajustes';

  @override
  String get appSetting_displaySubgroupText => 'Mostrar';

  @override
  String get appSetting_operationSubgroupText => 'Operación';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Arrastrar calendario por página';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'Si la función está habilitada, la navegación por la lista del calendario se realizará arrastrándola página por página. La posición predeterminada está inactiva.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Cambiar estado del registro';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Modificar el comportamiento del clic para cambiar el estado de los registros diarios en la página principal.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Abrir registro detallado';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Modifique el comportamiento del clic para abrir la ventana emergente detallada de los registros diarios en la página principal.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Primer dia de la semana';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Mostrar el primer día de la semana';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Por defecto)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Por el sistema ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'Del sistema';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Idioma';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Seleccionar el idioma';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Formato de visualización de la fecha ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'seguir la configuración del sistema';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'El formato de fecha configurado se aplicará a la visualización de la fecha en la página de detalles del hábito.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Habilitar la interfaz de usuario compacta en la página de hábitos';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Permitir que la tabla de control de hábitos muestre más contenido, pero algunos UI y texto pueden aparecer más pequeños.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Ajuste de la zona de validación de hábitos.';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Adjust percentage for more/less space in habits check table area.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Default';

  @override
  String get appSetting_reminderSubgroupText => 'Reminder';

  @override
  String get appSetting_dailyReminder_titleText => 'Daily reminder';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Backup & restore';

  @override
  String get appSetting_export_titleText => 'Export';

  @override
  String get appSetting_export_subtitleText => 'Exported habits as JSON format, This file can be import back.';

  @override
  String get appSetting_import_titleText => 'Import';

  @override
  String get appSetting_import_subtitleText => 'Import habits from json file.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Confirm import $count habits?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Note: Import doesn\'t delete existing habits.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'confirm';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'cancel';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Imported $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Complete import $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'close';

  @override
  String get appSetting_resetConfig_titleText => 'Reset configs';

  @override
  String get appSetting_resetConfig_subtitleText => 'Reset all configs to default.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Reset configs?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Reset all configs to default, must restart application to apply.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'cancel';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'confirm';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'reset app configs succeed';

  @override
  String get appSetting_otherSubgroupText => 'Others';

  @override
  String get appSetting_developMode_titleText => 'Develop Mode';

  @override
  String get appSetting_clearCache_titleText => 'Clear Cache';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Clear Cache';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'After clearing cache, some custom values will be restored to defaults.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'cancel';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'confirm';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Partial Cache cleared failed';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Cache cleared successfully';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Cache cleared failed';

  @override
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'About';

  @override
  String get appAbout_appbarTile_titleText => 'About';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Version: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Source code';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Issue tracker';

  @override
  String get appAbout_contactEmailTile_titleText => 'Contact me';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'License';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Third Party Licensing Statement';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Donate';

  @override
  String get appAbout_donateTile_subTitleText => 'I\'m a personal developer. If you like this app, please buy me a ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Buy me a coffee';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Crypto Currencies';

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
    return 'Copied $name\'s Address';
  }

  @override
  String get batchCheckin_appbar_title => 'Batch Check-in';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Previous day';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Next day';

  @override
  String get batchCheckin_status_skip_text => 'Skip';

  @override
  String get batchCheckin_status_ok_text => 'Complete';

  @override
  String get batchCheckin_status_double_text => 'x2 Hit!';

  @override
  String get batchCheckin_status_zero_text => 'Incomplete';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habits',
      one: 'Habit',
    );
    return '$count $_temp0 selected';
  }

  @override
  String get batchCheckin_save_button_text => 'Save';

  @override
  String get batchCheckin_reset_button_text => 'Reset';

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
  String get batchCheckin_save_confirmDialog_title => 'Overwrite Existing Records';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Existing records will be overwritten After saving, previous records will be lost.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'save';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'cancel';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirm Return';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Check-in Status Changes won\'t be applied before saved';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'exit';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'cancel';

  @override
  String get appReminder_dailyReminder_title => '🏝 Did you stick to your habits today?';

  @override
  String get appReminder_dailyReminder_body => 'click to enter app and punch in on time.';

  @override
  String get common_habitColorType_cc1 => 'Deep lilac';

  @override
  String get common_habitColorType_cc2 => 'Red';

  @override
  String get common_habitColorType_cc3 => 'Purple';

  @override
  String get common_habitColorType_cc4 => 'Royal blue';

  @override
  String get common_habitColorType_cc5 => 'Dark cyan';

  @override
  String get common_habitColorType_cc6 => 'Green';

  @override
  String get common_habitColorType_cc7 => 'Amber';

  @override
  String get common_habitColorType_cc8 => 'Orange';

  @override
  String get common_habitColorType_cc9 => 'Lime green';

  @override
  String get common_habitColorType_cc10 => 'Dark orchid';

  @override
  String common_habitColorType_default(int index) {
    return 'Color $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Use system format';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Date format';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Year Month Day';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Month Day Year';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Day Month Year';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separator';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Dash';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Slash';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Space';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Dot';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'No Separator';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Use 12-hour format';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Use full name';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Apply for Freq Chart';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Apply for Calendar';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'cancel';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'confirm';

  @override
  String get calendarPicker_clip_today => 'Today';

  @override
  String get calendarPicker_clip_tomorrow => 'Tomorrow';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Next $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Export all habits?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number habits',
      one: '1 habit',
      zero: 'current habit',
    );
    return 'Export $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'include records';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'cancel';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'export';

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
  String get debug_collectLogTile_enable_subtitle => 'Tap to stop logging collection.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Tap to start logging collection.';

  @override
  String get debug_downladDebugLogs_subject => 'Downloading debugging logs';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Debugging logs Cleared.';

  @override
  String get debug_downladDebugInfo_subject => 'Downloading debugging information';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Downloading $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'Debug log doesn\'t exist.';

  @override
  String get debug_debuggerLogCard_title => 'Logging Information';

  @override
  String get debug_debuggerLogCard_subtitle => 'Includes local debugging log information, need to turn on the log collection switcher.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Download';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Clear';

  @override
  String get debug_debuggerInfoCard_title => 'Debugging Information';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Includes app\'s debugging information.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Open';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Save';

  @override
  String get debug_debuggerInfo_notificationTitle => 'Collecting App\'s Info...';

  @override
  String get snackbar_undoText => 'UNDO';

  @override
  String get snackbar_dismissText => 'DISMISS';

  @override
  String get contributors_tile_title => 'Contributors';

  @override
  String get userAction_tap => 'Tap';

  @override
  String get userAction_doubleTap => 'Double';

  @override
  String get userAction_longTap => 'Long';
}
