import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_theme.dart';
import '../services/app_icon_service.dart';
import '../services/theme_service.dart';

/// Notifier para gerenciar o estado do tema da aplicação.
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _predefinedThemeIndex = 0;
  bool _usePredefinedTheme = true;
  Color? _customPrimaryColor;
  Color? _customAccentColor;
  int _appIconIndex = 0;
  bool _useMaterialYou = false;
  double _fontSize = 1.0;
  String _appLanguage = 'pt';

  ThemeNotifier() {
    _loadPreferences();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  int get predefinedThemeIndex => _predefinedThemeIndex;
  bool get usePredefinedTheme => _usePredefinedTheme;
  Color? get customPrimaryColor => _customPrimaryColor;
  Color? get customAccentColor => _customAccentColor;
  int get appIconIndex => _appIconIndex;
  bool get useMaterialYou => _useMaterialYou;
  double get fontSize => _fontSize;
  String get appLanguage => _appLanguage;
  Locale get locale => Locale(_appLanguage);

  AppTheme get currentTheme => PredefinedThemes.getTheme(_predefinedThemeIndex);
  AppIcon get currentIcon => PredefinedIcons.getIcon(_appIconIndex);

  /// Carrega preferências do Hive.
  Future<void> _loadPreferences() async {
    _themeMode = ThemeService.getThemeMode();
    _predefinedThemeIndex = ThemeService.getPredefinedThemeIndex();
    _usePredefinedTheme = ThemeService.isUsingPredefinedTheme();
    _customPrimaryColor = ThemeService.getPrimaryColor();
    _customAccentColor = ThemeService.getAccentColor();
    _appIconIndex = ThemeService.getAppIconIndex();
    _useMaterialYou = ThemeService.isMaterialYouEnabled();
    _fontSize = ThemeService.getFontSize();
    _appLanguage = ThemeService.getAppLanguage();
    await AppIconService.syncLauncherIcon(currentIcon);
    notifyListeners();
  }

  /// Define o modo de tema.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await ThemeService.setThemeMode(mode);
    notifyListeners();
  }

  /// Define o tema predefinido por índice.
  Future<void> setPredefinedTheme(int index) async {
    _predefinedThemeIndex = index;
    _usePredefinedTheme = true;
    await ThemeService.setPredefinedThemeIndex(index);
    await ThemeService.setUsePredefinedTheme(true);
    notifyListeners();
  }

  /// Define cores personalizadas.
  Future<void> setCustomColors(Color primary, Color accent) async {
    _customPrimaryColor = primary;
    _customAccentColor = accent;
    _usePredefinedTheme = false;
    await ThemeService.setPrimaryColor(primary);
    await ThemeService.setAccentColor(accent);
    await ThemeService.setUsePredefinedTheme(false);
    notifyListeners();
  }

  /// Define o ícone da app.
  Future<void> setAppIcon(int index) async {
    _appIconIndex = index;
    await ThemeService.setAppIconIndex(index);
    await AppIconService.syncLauncherIcon(currentIcon);
    notifyListeners();
  }

  /// Ativa/desativa Material You.
  Future<void> setMaterialYou(bool enabled) async {
    _useMaterialYou = enabled;
    await ThemeService.setMaterialYouEnabled(enabled);
    notifyListeners();
  }

  /// Define o tamanho da fonte.
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await ThemeService.setFontSize(size);
    notifyListeners();
  }

  /// Define o idioma da aplicação.
  Future<void> setAppLanguage(String languageCode) async {
    _appLanguage = languageCode;
    await ThemeService.setAppLanguage(languageCode);
    notifyListeners();
  }

  /// Reseta para configurações padrão.
  Future<void> resetToDefaults() async {
    await ThemeService.resetToDefaults();
    await _loadPreferences();
  }

  /// Obtém o ThemeData para modo claro.
  ThemeData getLightTheme() {
    ColorScheme colorScheme;

    if (_usePredefinedTheme) {
      colorScheme = currentTheme.toLightColorScheme();
    } else if (_customPrimaryColor != null) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: _customPrimaryColor!,
        secondary: _customAccentColor ?? _customPrimaryColor!,
        brightness: Brightness.light,
      );
    } else {
      colorScheme = PredefinedThemes.themes[0].toLightColorScheme();
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _getScaledTextTheme(ThemeData.light().textTheme),
    );
  }

  /// Obtém o ThemeData para modo escuro.
  ThemeData getDarkTheme() {
    ColorScheme colorScheme;

    if (_usePredefinedTheme) {
      colorScheme = currentTheme.toDarkColorScheme();
    } else if (_customPrimaryColor != null) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: _customPrimaryColor!,
        secondary: _customAccentColor ?? _customPrimaryColor!,
        brightness: Brightness.dark,
      );
    } else {
      colorScheme = PredefinedThemes.themes[0].toDarkColorScheme();
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _getScaledTextTheme(ThemeData.dark().textTheme),
    );
  }

  /// Aplica escala de fonte ao TextTheme.
  TextTheme _getScaledTextTheme(TextTheme baseTheme) {
    if (_fontSize == 1.0) return baseTheme;

    return baseTheme.apply(
      fontSizeFactor: _fontSize,
      fontSizeDelta: 0,
    );
  }
}

/// Provider do tema da aplicação.
final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});
