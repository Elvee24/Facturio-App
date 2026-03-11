import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/i18n/app_text.dart';
import '../../../../core/models/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/app_icon_service.dart';
import '../../../../core/utils/ui_helpers.dart';

/// Página de personalização visual da aplicação.
class PersonalizacaoPage extends ConsumerStatefulWidget {
  const PersonalizacaoPage({super.key});

  @override
  ConsumerState<PersonalizacaoPage> createState() => _PersonalizacaoPageState();
}

class _PersonalizacaoPageState extends ConsumerState<PersonalizacaoPage> {
  String _t(
    BuildContext context, {
    required String pt,
    required String en,
  }) {
    return AppText.tr(context, pt: pt, en: en);
  }

  String _iconSyncMessage(BuildContext context, AppIconSyncResult result) {
    switch (result.status) {
      case AppIconSyncStatus.synced:
        return _t(
          context,
          pt: AppIconService.supportsNativeMobileIcon
              ? 'Ícone aplicado na aplicação com sucesso.'
              : 'Ícone aplicado ao launcher com sucesso.',
          en: AppIconService.supportsNativeMobileIcon
              ? 'Icon applied to the app successfully.'
              : 'Icon applied to launcher successfully.',
        );
      case AppIconSyncStatus.alreadySynced:
        return _t(
          context,
          pt: AppIconService.supportsNativeMobileIcon
              ? 'A aplicação já está a usar este ícone.'
              : 'O launcher já está sincronizado com este ícone.',
          en: AppIconService.supportsNativeMobileIcon
              ? 'The app is already using this icon.'
              : 'The launcher is already synced with this icon.',
        );
      case AppIconSyncStatus.launcherNotFound:
        return _t(
          context,
          pt: 'Launcher não encontrado. Reinstala a app com ./install.sh --user.',
          en: 'Launcher not found. Reinstall the app with ./install.sh --user.',
        );
      case AppIconSyncStatus.unsupportedPlatform:
        return _t(
          context,
          pt: 'A alteração do ícone não está disponível nesta plataforma.',
          en: 'Icon switching is not available on this platform.',
        );
      case AppIconSyncStatus.invalidIcon:
      case AppIconSyncStatus.failed:
        return _t(
          context,
          pt: AppIconService.supportsNativeMobileIcon
              ? 'Não foi possível atualizar o ícone da aplicação.'
              : 'Não foi possível atualizar o launcher.',
          en: AppIconService.supportsNativeMobileIcon
              ? 'Could not update the application icon.'
              : 'Could not update the launcher.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Personalização', en: 'Customization')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: _t(context, pt: 'Repor predefinições', en: 'Reset to defaults'),
            onPressed: () => _showResetDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Modo de tema (claro/escuro)
          _buildThemeModeSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Temas predefinidos
          _buildPredefinedThemesSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Cores personalizadas
          _buildCustomColorsSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Ícone da app
          _buildAppIconSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Tamanho da fonte
          _buildFontSizeSection(context, themeNotifier, colors),
          const SizedBox(height: 24),

          // Opções avançadas
          _buildAdvancedSection(context, themeNotifier, colors),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Idioma da Aplicação', en: 'Application Language'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                context,
                pt: 'Escolha o idioma da interface (PT ou EN).',
                en: 'Choose the interface language (PT or EN).',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'pt',
                  label: Text('Português (PT)'),
                  icon: Icon(Icons.flag),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text('English (EN)'),
                  icon: Icon(Icons.language),
                ),
              ],
              selected: {themeNotifier.appLanguage},
              onSelectionChanged: (selected) async {
                final language = selected.first;
                await themeNotifier.setAppLanguage(language);
                if (!context.mounted) return;
                UiHelpers.mostrarSnackBar(
                  context,
                  mensagem: language == 'en'
                      ? 'Language changed to English.'
                      : 'Idioma alterado para Português.',
                  tipo: TipoSnackBar.sucesso,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de seleção de modo de tema.
  Widget _buildThemeModeSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.brightness_6, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Modo de Exibição', en: 'Display Mode'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(_t(context, pt: 'Claro', en: 'Light')),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(_t(context, pt: 'Escuro', en: 'Dark')),
                  icon: const Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(_t(context, pt: 'Sistema', en: 'System')),
                  icon: const Icon(Icons.brightness_auto),
                ),
              ],
              selected: {themeNotifier.themeMode},
              onSelectionChanged: (Set<ThemeMode> selected) {
                themeNotifier.setThemeMode(selected.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de temas predefinidos.
  Widget _buildPredefinedThemesSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Temas Predefinidos', en: 'Preset Themes'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                context,
                pt: 'Escolha um dos nossos temas profissionais',
                en: 'Choose one of our professional themes',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: PredefinedThemes.themes.length,
                itemBuilder: (context, index) {
                  final theme = PredefinedThemes.themes[index];
                  final isSelected = themeNotifier.usePredefinedTheme &&
                      themeNotifier.predefinedThemeIndex == index;

                  return GestureDetector(
                    onTap: () => themeNotifier.setPredefinedTheme(index),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outline.withValues(alpha: 0.3),
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor,
                                  theme.secondaryColor,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              theme.icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              theme.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : null,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de cores personalizadas.
  Widget _buildCustomColorsSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.color_lens, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Cores Personalizadas', en: 'Custom Colors'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                context,
                pt: 'Crie o seu próprio tema com cores exclusivas',
                en: 'Create your own theme with custom colors',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildColorPicker(
                    context,
                    _t(context, pt: 'Cor Primária', en: 'Primary Color'),
                    themeNotifier.customPrimaryColor ?? colors.primary,
                    (color) {
                      final accent = themeNotifier.customAccentColor ?? color;
                      themeNotifier.setCustomColors(color, accent);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildColorPicker(
                    context,
                    _t(context, pt: 'Cor Secundária', en: 'Secondary Color'),
                    themeNotifier.customAccentColor ?? colors.secondary,
                    (color) {
                      final primary =
                          themeNotifier.customPrimaryColor ?? colors.primary;
                      themeNotifier.setCustomColors(primary, color);
                    },
                  ),
                ),
              ],
            ),
            if (!themeNotifier.usePredefinedTheme) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _t(context, pt: 'Tema personalizado ativo', en: 'Custom theme active'),
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construtor de seletor de cor.
  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    return InkWell(
      onTap: () => _showColorPickerDialog(
        context,
        label,
        currentColor,
        onColorSelected,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: currentColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra diálogo de seleção de cor.
  void _showColorPickerDialog(
    BuildContext context,
    String title,
    Color currentColor,
    Function(Color) onColorSelected,
  ) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              onColorSelected(pickerColor);
              Navigator.pop(context);
            },
            child: Text(_t(context, pt: 'Selecionar', en: 'Select')),
          ),
        ],
      ),
    );
  }

  /// Seção de ícone da app.
  Widget _buildAppIconSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    final isMobileIconSync = AppIconService.supportsNativeMobileIcon;
    final supportsManualSync = AppIconService.supportsManualSync;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apps, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Ícone da Aplicação', en: 'Application Icon'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _t(context, pt: 'Personalize o visual do ícone', en: 'Customize the icon appearance'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _t(context, pt: 'Pré-visualização atual', en: 'Current preview'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: themeNotifier.currentIcon.color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: themeNotifier.currentIcon.assetPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: SvgPicture.asset(
                              themeNotifier.currentIcon.assetPath!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            themeNotifier.currentIcon.icon,
                            color: Colors.white,
                            size: 42,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    themeNotifier.currentIcon.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    themeNotifier.currentIcon.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                PredefinedIcons.icons.length,
                (index) {
                  final appIcon = PredefinedIcons.icons[index];
                  final isSelected = themeNotifier.appIconIndex == index;
                  final isOfficial = index == 0;

                  return InkWell(
                    onTap: () => themeNotifier.setAppIcon(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          width: 88,
                          height: 108,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primaryContainer.withValues(alpha: 0.45)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outline.withValues(alpha: 0.3),
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: appIcon.color,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: appIcon.color.withValues(alpha: 0.25),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: appIcon.assetPath != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: SvgPicture.asset(
                                          appIcon.assetPath!,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Icon(
                                        appIcon.icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  appIcon.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : null,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOfficial || isSelected)
                          Positioned(
                            top: -8,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow.withValues(alpha: 0.14),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                isSelected
                                ? _t(context, pt: 'Ativo', en: 'Active')
                                : _t(context, pt: 'Recomendado', en: 'Recommended'),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (supportsManualSync) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final result = await AppIconService.syncLauncherIcon(
                      themeNotifier.currentIcon,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_iconSyncMessage(context, result)),
                        backgroundColor: result.isSuccess
                            ? Colors.green.shade700
                            : Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                  icon: Icon(
                    isMobileIconSync
                        ? Icons.phone_android_outlined
                        : Icons.desktop_windows_outlined,
                  ),
                  label: Text(
                    _t(
                      context,
                      pt: isMobileIconSync
                          ? 'Aplicar no telemóvel agora'
                          : 'Aplicar ao launcher agora',
                      en: isMobileIconSync
                          ? 'Apply on phone now'
                          : 'Apply to launcher now',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                  context,
                  pt: isMobileIconSync
                      ? 'A seleção é guardada automaticamente. Use este botão se o ecrã inicial ainda mostrar o ícone anterior.'
                      : 'A aplicação tenta atualizar o launcher automaticamente. Use este botão se o menu do sistema ainda mostrar o ícone antigo.',
                  en: isMobileIconSync
                      ? 'The selection is saved automatically. Use this button if the home screen still shows the previous icon.'
                      : 'The app tries to update the launcher automatically. Use this button if the system menu still shows the old icon.',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Seção de tamanho de fonte.
  Widget _buildFontSizeSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Tamanho do Texto', en: 'Text Size'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _t(
                context,
                pt: 'Ajuste o tamanho para melhor legibilidade',
                en: 'Adjust the text size for better readability',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.text_decrease, color: colors.onSurfaceVariant),
                Expanded(
                  child: Slider(
                    value: themeNotifier.fontSize,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: '${(themeNotifier.fontSize * 100).toInt()}%',
                    onChanged: (value) => themeNotifier.setFontSize(value),
                  ),
                ),
                Icon(Icons.text_increase, color: colors.onSurfaceVariant),
              ],
            ),
            Center(
              child: Text(
                _t(
                  context,
                  pt: 'Exemplo de texto com ${(themeNotifier.fontSize * 100).toInt()}% de tamanho',
                  en: 'Sample text at ${(themeNotifier.fontSize * 100).toInt()}% size',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção de opções avançadas.
  Widget _buildAdvancedSection(
    BuildContext context,
    ThemeNotifier themeNotifier,
    ColorScheme colors,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  _t(context, pt: 'Opções Avançadas', en: 'Advanced Options'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(_t(context, pt: 'Material You (Experimental)', en: 'Material You (Experimental)')),
              subtitle: Text(_t(
                context,
                pt: 'Tema dinâmico do sistema (Android 12+)',
                en: 'Dynamic system theme (Android 12+)',
              )),
              value: themeNotifier.useMaterialYou,
              onChanged: (value) => themeNotifier.setMaterialYou(value),
              secondary: const Icon(Icons.auto_awesome),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra diálogo de confirmação para reset.
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t(context, pt: 'Repor Personalização', en: 'Reset Customization')),
        content: Text(
          _t(
            context,
            pt: 'Tem a certeza de que deseja repor todas as definições de personalização para os valores padrão?',
            en: 'Are you sure you want to reset all customization settings to their default values?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(themeProvider).resetToDefaults();
              if (context.mounted) {
                Navigator.pop(context);
                UiHelpers.mostrarSnackBar(
                  context,
                  mensagem: _t(
                    context,
                    pt: 'Personalização reposta com sucesso!',
                    en: 'Customization reset successfully!',
                  ),
                );
              }
            },
            child: Text(_t(context, pt: 'Repor', en: 'Reset')),
          ),
        ],
      ),
    );
  }
}
