import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

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
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Ajusta el porcentaje para tener más o menos espacio en el área de validación de hábitos.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Por defecto';

  @override
  String get appSetting_reminderSubgroupText => 'Recordatorio';

  @override
  String get appSetting_dailyReminder_titleText => 'Recordatorio diario';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Copia de seguridad y restauración';

  @override
  String get appSetting_export_titleText => 'Exportar';

  @override
  String get appSetting_export_subtitleText => 'Hábitos exportados en formato JSON. Este archivo se puede volver a importar.';

  @override
  String get appSetting_import_titleText => 'Importar';

  @override
  String get appSetting_import_subtitleText => 'Importar hábitos desde el archivo json.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return '¿Confirmar la importación de $count hábitos?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Nota: La importación no elimina los hábitos existentes.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'confirmar';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'cancelar';

  @override
  String appSetting_importDialog_importingTitle(int completeCount, int totalCount) {
    return 'Importado $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Importación completada $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'cerrar';

  @override
  String get appSetting_resetConfig_titleText => 'Restablecer los ajustes';

  @override
  String get appSetting_resetConfig_subtitleText => 'Restablecer todas los ajustes a los valores predeterminados.';

  @override
  String get appSetting_resetConfigDialog_titleText => '¿Restablecer los ajustes?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Restablecer todas los ajustes a los valores predeterminados, debes reiniciar la aplicación para aplicar los cambios.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'cancelar';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'confirmar';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'Restablecimiento de los ajustes fue exitoso';

  @override
  String get appSetting_otherSubgroupText => 'Otros';

  @override
  String get appSetting_developMode_titleText => 'Modo desarrollador';

  @override
  String get appSetting_clearCache_titleText => 'Limpiar la caché';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Limpiar la caché';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Después de borrar la caché, algunos valores personalizados se restaurarán a los valores predeterminados.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'cancelar';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'confirmar';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Error al borrar parcialmente la memoria caché';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Caché borrada con éxito';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Error al borrar la caché';

  @override
  String get appSetting_debugger_titleText => 'Información de depuración';

  @override
  String get appSetting_about_titleText => 'Acerca de';

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
  String appSync_syncServerType_text(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'webdav': 'WebDAV',
        'fake': 'Fake (Only For Debugger)',
        'other': 'Unknown ($name)',
      },
    );
    return 'Current: $_temp0';
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
  String get appAbout_appbarTile_titleText => 'Acerca de';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Versión: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Código fuente';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Seguimiento de errores';

  @override
  String get appAbout_contactEmailTile_titleText => 'Contáctame';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Hola, me alegro de que te hayas comunicado conmigo.\nSi estás informando de un error, indica la versión de la aplicación y describe los pasos para reproducirlo.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licencia';

  @override
  String get appAbout_licenseTile_subtitleText => 'Licencia Apache versión 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Declaración de licencias de terceros';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Donar';

  @override
  String get appAbout_donateTile_subTitleText => 'Estoy desarrollando esta aplicación como hobby. Por favor cómprame un ☕.';

  @override
  String get appAbout_donateTile_ways => '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Invítame a un café';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'CRIPTOMONEDAS';

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
  String get donateWay_firstQRGroup => 'Alipay y Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'Copiada la dirección de $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Registro por lotes';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'El día anterior';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'El día siguiente';

  @override
  String get batchCheckin_status_skip_text => 'Omitir';

  @override
  String get batchCheckin_status_ok_text => 'Terminado';

  @override
  String get batchCheckin_status_double_text => '¡Doble éxito!';

  @override
  String get batchCheckin_status_zero_text => 'Incompleto';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hábitos',
      one: 'Hábito',
    );
    return '$count $_temp0 seleccionados';
  }

  @override
  String get batchCheckin_save_button_text => 'Guardar';

  @override
  String get batchCheckin_reset_button_text => 'Restablecer';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'estado de $count hábitos',
      one: 'estado del hábito',
    );
    return 'Modificado $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title => 'Sobrescribir registros existentes';

  @override
  String get batchCheckin_save_confirmDialog_body => 'Los registros existentes se sobrescribirán. Después de guardar, se perderán los registros anteriores.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'guardar';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'cancelar';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirmar devolución';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Los cambios en el estado de la verificación solo se aplicarán después de guardarlos.';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'salir';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'cancelar';

  @override
  String get appReminder_dailyReminder_title => '🏝 ¿Sigues con tus hábitos?';

  @override
  String get appReminder_dailyReminder_body => 'Haz clic para ingresar a la aplicación y registrar tu entrada a tiempo.';

  @override
  String get common_habitColorType_cc1 => 'Lila oscuro';

  @override
  String get common_habitColorType_cc2 => 'Rojo';

  @override
  String get common_habitColorType_cc3 => 'Morado';

  @override
  String get common_habitColorType_cc4 => 'Azul';

  @override
  String get common_habitColorType_cc5 => 'Cian oscuro';

  @override
  String get common_habitColorType_cc6 => 'Verde';

  @override
  String get common_habitColorType_cc7 => 'Ámbar';

  @override
  String get common_habitColorType_cc8 => 'Naranja';

  @override
  String get common_habitColorType_cc9 => 'Lima';

  @override
  String get common_habitColorType_cc10 => 'Morado oscuro';

  @override
  String common_habitColorType_default(int index) {
    return 'Color $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Usar el del sistema';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Formato de fecha';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Año mes día';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Mes día año';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Día mes año';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separador';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Guión';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Barra oblicua';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Espacio';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Punto';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Sin separador';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Utilizar el formato de 12 horas';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Usar nombre completo';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Solicitar tabla de frecuencia';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Solicitar calendario';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'cancelar';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'confirmar';

  @override
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get common_enable_text => 'Enabled';

  @override
  String get calendarPicker_clip_today => 'Hoy';

  @override
  String get calendarPicker_clip_tomorrow => 'Mañana';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Próximo $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => '¿Exportar todos los hábitos?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number hábitos',
      one: '1 hábito',
      zero: 'hábitos',
    );
    return '¿Exportar $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'incluir registros';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'cancelar';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'exportar';

  @override
  String get debug_logLevelTile_title => 'Nivel del registro';

  @override
  String get debug_logLevelDialog_title => 'Cambiar el nivel del registro';

  @override
  String get debug_logLevel_debug => 'Depurar';

  @override
  String get debug_logLevel_info => 'Información';

  @override
  String get debug_logLevel_warn => 'Advertencia';

  @override
  String get debug_logLevel_error => 'Error';

  @override
  String get debug_logLevel_fatal => 'Fatal';

  @override
  String get debug_collectLogTile_title => 'Recopilando los registros';

  @override
  String get debug_collectLogTile_enable_subtitle => 'Haz clic para detener la recopilación de registros.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Haz clic para iniciar la recopilación de registros.';

  @override
  String get debug_downladDebugLogs_subject => 'Descargar registros de depuración';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Registros de depuración borrados.';

  @override
  String get debug_downladDebugInfo_subject => 'Descargar la información de depuración';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Descargando $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'El registro de depuración no existe.';

  @override
  String get debug_debuggerLogCard_title => 'Información del registro';

  @override
  String get debug_debuggerLogCard_subtitle => 'Para incluir información de registro de depuración local, es necesario habilitar el convertidor del recopilador de registros.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Descargar';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Limpiar';

  @override
  String get debug_debuggerInfoCard_title => 'Información de depuración';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Incluir información de depuración de la aplicación.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Abrir';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Guardar';

  @override
  String get debug_debuggerInfo_notificationTitle => 'Recopilando información de la aplicación...';

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
  String get snackbar_undoText => 'DESHACER';

  @override
  String get snackbar_dismissText => 'RECHAZAR';

  @override
  String get contributors_tile_title => 'Colaboradores';

  @override
  String get userAction_tap => 'Pulsar';

  @override
  String get userAction_doubleTap => 'Doble';

  @override
  String get userAction_longTap => 'Longitud';
}
