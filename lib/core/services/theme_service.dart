import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Serviço para gerenciar preferências de tema e personalização da app.
class ThemeService {
  static const String _boxName = 'theme_prefs';
  static late Box _box;

  // Chaves de armazenamento
  static const String _themeMode = 'theme_mode';
  static const String _primaryColor = 'primary_color';
  static const String _accentColor = 'accent_color';
  static const String _usePredefinedTheme = 'use_predefined_theme';
  static const String _predefinedThemeIndex = 'predefined_theme_index';
  static const String _appIcon = 'app_icon';
  static const String _useMaterialYou = 'use_material_you';
  static const String _fontSize = 'font_size';
  static const String _appLanguage = 'app_language';

  /// Inicializa o serviço de tema.
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ==================== THEME MODE ====================

  /// Obtém o modo de tema atual (light, dark ou system).
  static ThemeMode getThemeMode() {
    final modeIndex = _box.get(_themeMode, defaultValue: 0);
    return ThemeMode.values[modeIndex];
  }

  /// Define o modo de tema.
  static Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(_themeMode, mode.index);
  }

  // ==================== CORES ====================

  /// Obtém a cor primária personalizada (se definida).
  static Color? getPrimaryColor() {
    final colorValue = _box.get(_primaryColor);
    return colorValue != null ? Color(colorValue) : null;
  }

  /// Define a cor primária personalizada.
  static Future<void> setPrimaryColor(Color color) async {
    await _box.put(_primaryColor, color.toARGB32());
  }

  /// Obtém a cor de destaque personalizada (se definida).
  static Color? getAccentColor() {
    final colorValue = _box.get(_accentColor);
    return colorValue != null ? Color(colorValue) : null;
  }

  /// Define a cor de destaque personalizada.
  static Future<void> setAccentColor(Color color) async {
    await _box.put(_accentColor, color.toARGB32());
  }

  // ==================== TEMAS PREDEFINIDOS ====================

  /// Verifica se está usando tema predefinido.
  static bool isUsingPredefinedTheme() {
    return _box.get(_usePredefinedTheme, defaultValue: true);
  }

  /// Define se deve usar tema predefinido.
  static Future<void> setUsePredefinedTheme(bool use) async {
    await _box.put(_usePredefinedTheme, use);
  }

  /// Obtém o índice do tema predefinido selecionado.
  static int getPredefinedThemeIndex() {
    return _box.get(_predefinedThemeIndex, defaultValue: 0);
  }

  /// Define o índice do tema predefinido.
  static Future<void> setPredefinedThemeIndex(int index) async {
    await _box.put(_predefinedThemeIndex, index);
  }

  // ==================== ÍCONE DA APP ====================

  /// Obtém o índice do ícone selecionado.
  static int getAppIconIndex() {
    return _box.get(_appIcon, defaultValue: 0);
  }

  /// Define o índice do ícone da app.
  static Future<void> setAppIconIndex(int index) async {
    await _box.put(_appIcon, index);
  }

  // ==================== MATERIAL YOU ====================

  /// Verifica se Material You está ativo.
  static bool isMaterialYouEnabled() {
    return _box.get(_useMaterialYou, defaultValue: false);
  }

  /// Define se deve usar Material You.
  static Future<void> setMaterialYouEnabled(bool enabled) async {
    await _box.put(_useMaterialYou, enabled);
  }

  // ==================== TAMANHO DE FONTE ====================

  /// Obtém o tamanho de fonte (escala).
  static double getFontSize() {
    return _box.get(_fontSize, defaultValue: 1.0);
  }

  /// Define o tamanho de fonte (escala).
  static Future<void> setFontSize(double size) async {
    await _box.put(_fontSize, size);
  }

  // ==================== IDIOMA ====================

  /// Obtém o idioma da aplicação (ex.: 'pt', 'en').
  static String getAppLanguage() {
    return _box.get(_appLanguage, defaultValue: 'pt');
  }

  /// Define o idioma da aplicação.
  static Future<void> setAppLanguage(String languageCode) async {
    await _box.put(_appLanguage, languageCode);
  }

  // ==================== RESET ====================

  /// Reseta todas as preferências para os valores padrão.
  static Future<void> resetToDefaults() async {
    await _box.clear();
  }
}
