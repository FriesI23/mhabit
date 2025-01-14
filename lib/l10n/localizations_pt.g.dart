import 'package:intl/intl.dart' as intl;

import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get localeScriptName => 'Português Brasileiro';

  @override
  String get appName => 'Table Habit';

  @override
  String get habitEdit_saveButton_text => 'Guardar';

  @override
  String get habitEdit_habitName_hintText => 'Nome do hábito ...';

  @override
  String get habitEdit_colorPicker_title => 'Escolher cor';

  @override
  String get habitEdit_habitTypeDialog_title => 'Tipo de hábito';

  @override
  String get habitEdit_habitType_positiveText => 'Positivo';

  @override
  String get habitEdit_habitType_negativeText => 'Negativo';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Objetivo diário, padrão $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Mínimo limite diário, padrão $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Objetivo diário deve ser > $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Objetivo diário deve ser ≤ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Objetivo diário deve ser ≥ $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'Objetivo diário deve ser ≤ $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText => 'Unidade do objetivo diário';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText => 'Máximo desejado do objetivo diário';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Valor inválido, deve estar vazio ou ≥ $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText => 'Limite máximo diário';

  @override
  String get habitEdit_frequencySelector_title => 'Selecionar frequência';

  @override
  String get habitEdit_habitFreq_daily => 'Diariamente';

  @override
  String get habitEdit_habitFreq_perweek => '';

  @override
  String get habitEdit_habitFreq_perweek_ex01 => 'Vezes por semana';

  @override
  String get habitEdit_habitFreq_permonth => '';

  @override
  String get habitEdit_habitFreq_permonth_ex01 => 'Vezes por mês';

  @override
  String get habitEdit_habitFreq_predayfreq => '';

  @override
  String get habitEdit_habitFreq_predayfreq_ex01 => 'times in';

  @override
  String get habitEdit_habitFreq_predayfreq_ex02 => 'Dias';

  @override
  String get habitEdit_habitFreq_predayfreq_reverse_flag => '0';

  @override
  String get habitEdit_habitFreq_show_daily => 'Diariamente';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Pelo menos $freq vezes por semana',
      one: 'Por semana',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Pelo menos$freq vezes por mês',
      one: 'Por mês',
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
    return '$targetDays dias';
  }

  @override
  String get habitEdit_targetDays_dialogTitle => 'Selecionar dias alvo';

  @override
  String get habitEdit_targetDays => 'dias';

  @override
  String get habitEdit_reminder_hintText => 'Lembrete';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Qualquer dia da semana';

  @override
  String get habitEdit_reminder_freq_weekPrefixText => '';

  @override
  String get habitEdit_reminder_freq_weekSubfixText => ' em cada semana';

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Qualquer dia do mês';

  @override
  String get habitEdit_reminder_freq_monthPrefixText => '';

  @override
  String get habitEdit_reminder_freq_monthSubfixText => ' em cada mês';

  @override
  String get habitEdit_reminderQuest_hintText => 'Questão, p.e. Fizeste exercício hoje?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Escolher tipo de lembrete';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded => 'Verificar quando necessário';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Diariamente';

  @override
  String get habitEdit_reminder_dialogType_week => 'Por semana';

  @override
  String get habitEdit_reminder_dialogType_month => 'Por mês';

  @override
  String get habitEdit_reminder_dialogConfirm => 'Confirmar';

  @override
  String get habitEdit_reminder_dialogCancel => 'Cancelar';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Confirmar';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle => 'Confirma que quer remover este lembrete?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'Confirmar';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'Cancelar';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'SEG';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'TER';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'QUA';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'QUI';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'SEX';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'SÁB';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'DOM';

  @override
  String get habitEdit_desc_hintText => 'Memo, support Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Criado: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Alterado: ';

  @override
  String get habitDisplay_fab_text => 'Novo hábito';

  @override
  String get habitDisplay_emptyImage_text_01 => 'A journey of a thousand miles begins with a single step';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title => 'Arquivar hábitos selecionados?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'cancelar';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Arquivados $count hábitos';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title => 'Desarquivar hábitos selecionados?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'cancelar';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Desarquivar $count hábitos';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title => 'Apagar os hábitos selecionados?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'cancelar';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Apagados $count hábitos';
  }

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Selecionar todos';

  @override
  String get habitDisplay_editPopMenu_export => 'Exportar';

  @override
  String get habitDisplay_editPopMenu_delete => 'Apagar';

  @override
  String get habitDisplay_editPopMenu_clone => 'Template';

  @override
  String get habitDisplay_editButton_tooltip => 'Editar';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Arquivar';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Desarquivar';

  @override
  String get habitDisplay_settingButton_tooltip => 'Definição';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Atual';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Completo';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'Em progresso';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Arquivado';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText => 'Top Hábitos: Mudanças dos últimos 30 dias';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Tema claro';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Tema escuro';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Seguir o sistema';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText => 'Mostrar arquivados';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Mostrar completados';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Mostrar activos';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Definições';

  @override
  String get habitDisplay_sort_reverseText => 'Inverter';

  @override
  String get habitDisplay_sortDirection_asc => '(Asc)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Desc)';

  @override
  String get habitDisplay_sortType_manual => 'Pela minha ordem';

  @override
  String get habitDisplay_sortType_name => 'Por nome';

  @override
  String get habitDisplay_sortType_colorType => 'Por cor';

  @override
  String get habitDisplay_sortType_progress => 'Por classificação';

  @override
  String get habitDisplay_sortType_startT => 'Por data de início';

  @override
  String get habitDisplay_sortType_status => 'Por Status';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Ordenar';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'confirmar';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'cancelar';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Depuração';

  @override
  String get habitDetail_editButton_tooltip => 'Editar';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Desarquivar';

  @override
  String get habitDetail_editPopMenu_archive => 'Arquivar';

  @override
  String get habitDetail_editPopMenu_export => 'Exportar';

  @override
  String get habitDetail_editPopMenu_delete => 'Apagar';

  @override
  String get habitDetail_editPopMenu_clone => 'Template';

  @override
  String get habitDetail_confirmDialog_confirm => 'confirmar';

  @override
  String get habitDetail_confirmDialog_cancel => 'cancelar';

  @override
  String get habitDetail_archiveConfirmDialog_titleText => 'Arquivar hábito?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText => 'Desarquivar hábito?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Apagar hábito?';

  @override
  String get habitDetail_summary_title => 'Sumário';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'A nota atual é $score, e já passaram $days dias desde o começo.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Começa em $days dias.',
      one: 'A começar amanhã.',
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
    return 'Unidade: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'null';

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
  String get habitDetail_descRecordsNum_titleText => 'Registos';

  @override
  String get habitDetail_scoreChart_title => 'Pontuação';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Dia';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Semana';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Mês';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Ano';

  @override
  String get habitDetail_freqChart_freqTitle => 'Frequência';

  @override
  String get habitDetail_freqChart_historyTitle => 'Histórico';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Frequência e histórico';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Semana';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Mês';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Ano';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Agora';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip => 'Ocultar gráfico do histórico';

  @override
  String get habitDetail_freqChart_expanded_showTooltip => 'Mostrar gráfico do histórico';

  @override
  String get habitDetail_descSubgroup_title => 'Memo';

  @override
  String get habitDetail_otherSubgroup_title => 'Outro';

  @override
  String get habitDetail_habitType_title => 'Tipo';

  @override
  String get habitDetail_reminderTile_title => 'Lembrete';

  @override
  String get habitDetail_freqTile_title => 'Repetir';

  @override
  String get habitDetail_startDateTile_title => 'Data de início';

  @override
  String get habitDetail_createDateTile_title => 'Criado';

  @override
  String get habitDetail_modifyDateTile_title => 'Alterado';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'data';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'valor';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText => 'Voltar para hoje';

  @override
  String get habitDetail_notFoundText => 'O carregamento do hábito falhou';

  @override
  String get habitDetail_notFoundRetryText => 'Tente outra vez';

  @override
  String get habitDetail_changeGoal_title => 'Alterar objetivo';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'Atual: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'feito: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'Desfazer';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Objetivo diário, padrão: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'cancelar';

  @override
  String get habitDetail_changeGoal_saveText => 'guardar';

  @override
  String get habitDetail_skipReason_title => 'Saltar razão';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Escreva aqui qualquer coisa...';

  @override
  String get habitDetail_skipReason_cancelText => 'cancelar';

  @override
  String get habitDetail_skipReason_saveText => 'guardar';

  @override
  String get appSetting_appbar_titleText => 'Definições';

  @override
  String get appSetting_displaySubgroupText => 'Exibir';

  @override
  String get appSetting_operationSubgroupText => 'Operação';

  @override
  String get appSetting_dragCalendarByPageTile_titleText => 'Arrastar o calendário por página';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText => 'If the switch is enabled, the app bar calendar on the home page will be dragged page by page. By default, the switch is disabled.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText => 'Change Record Status';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText => 'Modificar o comportamento do clique para alterar o status dos registos diários da página principal.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText => 'Abrir registo detalhado';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText => 'Modifique o comportamento do clique para abrir um popup detalhado em relação aos registos diários na página principal.';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Primeiro dia da semana';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText => 'Mostrar primeiro dia da semana';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' . (Padrão)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Seguir o sistema ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text => 'Seguir o sistema';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Idioma';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Selecionar idioma';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Formato de apresentação da data ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText => 'seguir definições do sistema';

  @override
  String get appSetting_dateDisplayFormat_subTitleText => 'A data configurada será aplicada na data visível da página de detalhes dos hábitos.';

  @override
  String get appSetting_compactUISwitcher_titleText => 'Habilitar o modo compacto na página de hábitos';

  @override
  String get appSetting_compactUISwitcher_subtitleText => 'Habilitar que o gráfico de verificação de hábitos mostre mais conteúdo, contudo, algumas interfaces e textos ficarão mais pequenos.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText => 'Habits check area radio adjustment';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText => 'Ajustar a percentagem para mais/menos espaço na área de verificação de hábitos.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Padrão';

  @override
  String get appSetting_reminderSubgroupText => 'Lembrete';

  @override
  String get appSetting_dailyReminder_titleText => 'Lembrete diário';

  @override
  String get appSetting_backupAndRestoreSubgroupText => 'Backup e restauro';

  @override
  String get appSetting_export_titleText => 'Exportar';

  @override
  String get appSetting_export_subtitleText => 'Exportar hábitos em formato JSON. Este hábito pode ser importado de volta.';

  @override
  String get appSetting_import_titleText => 'Importar';

  @override
  String get appSetting_import_subtitleText => 'Importar hábitos de um ficheiro JSON.';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Confirmar importação de $count hábitos?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle => 'Nota: A importação não apaga hábitos já existentes.';

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
    return 'Completar importação $count';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'fechar';

  @override
  String get appSetting_resetConfig_titleText => 'Repor configurações';

  @override
  String get appSetting_resetConfig_subtitleText => 'Repor todas as configurações de padrão.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Repor configurações?';

  @override
  String get appSetting_resetConfigDialog_subtitleText => 'Repondo todas as configurações de padrão, será necessário reiniciar a aplicação para que estas sejam aplicadas.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'cancelar';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'confirmar';

  @override
  String get appSetting_resetConfigSuccess_snackbarText => 'As configurações da app foram repostas com sucesso.';

  @override
  String get appSetting_otherSubgroupText => 'Outros';

  @override
  String get appSetting_developMode_titleText => 'Develop Mode';

  @override
  String get appSetting_clearCache_titleText => 'Limpar cache';

  @override
  String get appSetting_clearCacheDialog_titleText => 'Limpar cache';

  @override
  String get appSetting_clearCacheDialog_subtitleText => 'Após a limpeza do cache, alguns valores serão restaurados para valores padrão.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'cancelar';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'confirmar';

  @override
  String get appSetting_clearCache_snackBar_partSuccText => 'Limpeza parcial do cache falhou';

  @override
  String get appSetting_clearCache_snackBar_succText => 'Cache foi limpo com sucesso';

  @override
  String get appSetting_clearCache_snackBar_failText => 'Limpeza do cache falhou';

  @override
  String get appSetting_debugger_titleText => 'Debug Info';

  @override
  String get appSetting_about_titleText => 'Sobre';

  @override
  String get appAbout_appbarTile_titleText => 'Sobre';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Versão: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Código fonte';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Issue tracker';

  @override
  String get appAbout_contactEmailTile_titleText => 'Contacte-me';

  @override
  String get appAbout_contactEmailTile_emailBody => 'Olá, ainda bem que me contactou.\nSe quer reportar um erro, por favor indique a versão da app e descreva os passos de modo a que possa reproduzi-la.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licença';

  @override
  String get appAbout_licenseTile_subtitleText => 'Apache License, Version 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText => 'Third Party Licensing Statement';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_donateTile_titleText => 'Doar';

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
  String get donateWay_cryptoCurrency => 'CryptoCurrencies';

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
  String get batchCheckin_datePicker_prevButton_tooltip => 'Dia anterior';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Próximo dia';

  @override
  String get batchCheckin_status_skip_text => 'Saltar';

  @override
  String get batchCheckin_status_ok_text => 'Completar';

  @override
  String get batchCheckin_status_double_text => 'x2 Hit!';

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
    return '$count $_temp0 selecionado';
  }

  @override
  String get batchCheckin_save_button_text => 'Guardar';

  @override
  String get batchCheckin_reset_button_text => 'Repor';

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
  String get batchCheckin_save_confirmDialog_body => 'Os registos existentes serão substituídos. Depois de guardar, os registos anteriores serão perdidos.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'guardar';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'cancelar';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Confirm Return';

  @override
  String get batchCheckin_close_confirmDialog_body => 'Check-in Status Changes won\'t be applied before saved';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'sair';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'cancelar';

  @override
  String get appReminder_dailyReminder_title => '🏝 Manteve os seus hábitos hoje?';

  @override
  String get appReminder_dailyReminder_body => 'click to enter app and punch in on time.';

  @override
  String get common_habitColorType_cc1 => 'Deep lilac';

  @override
  String get common_habitColorType_cc2 => 'Vermelho';

  @override
  String get common_habitColorType_cc3 => 'Roxo';

  @override
  String get common_habitColorType_cc4 => 'Azul escuro';

  @override
  String get common_habitColorType_cc5 => 'Verde escuro';

  @override
  String get common_habitColorType_cc6 => 'Verde';

  @override
  String get common_habitColorType_cc7 => 'Cor amber';

  @override
  String get common_habitColorType_cc8 => 'Laranja';

  @override
  String get common_habitColorType_cc9 => 'Verde lima';

  @override
  String get common_habitColorType_cc10 => 'Dark orchid';

  @override
  String common_habitColorType_default(int index) {
    return 'Cor $index';
  }

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text => 'Usar formato do sistema';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Formato de data';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Ano Mês Dia';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Mês Dia Ano';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Dia Mês Ano';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separador';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Travessão/Traço';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Barra';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Espaço';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Ponto';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Sem separador';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(String splitName, String splitChar) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text => 'Usar formato de 12 horas';

  @override
  String get common_customDateTimeFormatPicker_monthName_text => 'Usar nome completo';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text => 'Aplicar para o gráfico de frequência';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text => 'Aplicar para o calendário';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'cancelar';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text => 'confirmar';

  @override
  String get common_errorPage_title => 'Oops, Crashed!';

  @override
  String get common_errorPage_copied => 'Copied crash information';

  @override
  String get calendarPicker_clip_today => 'Hoje';

  @override
  String get calendarPicker_clip_tomorrow => 'Amanhã';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Próximo $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll => 'Exportar todos os hábitos?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number hábitos',
      one: '1 hábito',
      zero: 'hábit atual',
    );
    return 'Exportar $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'Incluir registos';

  @override
  String get exportConfirmDialog_cancel_buttonText => 'cancelar';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'exportar';

  @override
  String get debug_logLevelTile_title => 'Logging Level';

  @override
  String get debug_logLevelDialog_title => 'Change Logging Level';

  @override
  String get debug_logLevel_debug => 'Depuração';

  @override
  String get debug_logLevel_info => 'Info';

  @override
  String get debug_logLevel_warn => 'Aviso';

  @override
  String get debug_logLevel_error => 'Erro';

  @override
  String get debug_logLevel_fatal => 'Fatal';

  @override
  String get debug_collectLogTile_title => 'Collecting Logs';

  @override
  String get debug_collectLogTile_enable_subtitle => 'Tap to stop logging collection.';

  @override
  String get debug_collectLogTile_disable_subtitle => 'Tap to start logging collection.';

  @override
  String get debug_downladDebugLogs_subject => 'A descarregar registos de depuração';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar => 'Registos de depuração limpos.';

  @override
  String get debug_downladDebugInfo_subject => 'A descarregar informações de depuração';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'A descarregar $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar => 'O registo de depuração não existe.';

  @override
  String get debug_debuggerLogCard_title => 'Logging Information';

  @override
  String get debug_debuggerLogCard_subtitle => 'Inclui informações de registo de depuração local. É necessário ativar a recolha de registos.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Descarregar';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Limpar';

  @override
  String get debug_debuggerInfoCard_title => 'Informação de depuração';

  @override
  String get debug_debuggerInfoCard_subtitle => 'Inclui informação de depuração da app.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Abrir';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Guardar';

  @override
  String get debug_debuggerInfo_notificationTitle => 'A recolher informações da app...';

  @override
  String get snackbar_undoText => 'Desfazer';

  @override
  String get snackbar_dismissText => 'DISPENSAR';

  @override
  String get contributors_tile_title => 'Contribuidores';

  @override
  String get userAction_tap => 'Clicar';

  @override
  String get userAction_doubleTap => 'Duplo';

  @override
  String get userAction_longTap => 'Longo';
}
