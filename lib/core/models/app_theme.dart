import 'package:flutter/material.dart';

/// Modelo de tema predefinido com cores e informações.
class AppTheme {
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  const AppTheme({
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });

  /// Cria um ColorScheme para modo claro.
  ColorScheme toLightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.light,
    );
  }

  /// Cria um ColorScheme para modo escuro.
  ColorScheme toDarkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.dark,
    );
  }
}

/// Temas predefinidos disponíveis na aplicação.
class PredefinedThemes {
  static const List<AppTheme> themes = [
    AppTheme(
      name: 'Azul Profissional',
      description: 'Tema padrão azul elegante e profissional',
      primaryColor: Color(0xFF1976D2),
      secondaryColor: Color(0xFF42A5F5),
      icon: Icons.business,
    ),
    AppTheme(
      name: 'Verde Natureza',
      description: 'Tons de verde suaves e relaxantes',
      primaryColor: Color(0xFF388E3C),
      secondaryColor: Color(0xFF66BB6A),
      icon: Icons.eco,
    ),
    AppTheme(
      name: 'Roxo Criativo',
      description: 'Roxo vibrante e moderno',
      primaryColor: Color(0xFF7B1FA2),
      secondaryColor: Color(0xFFBA68C8),
      icon: Icons.palette,
    ),
    AppTheme(
      name: 'Laranja Energia',
      description: 'Laranja energético e dinâmico',
      primaryColor: Color(0xFFE64A19),
      secondaryColor: Color(0xFFFF7043),
      icon: Icons.flash_on,
    ),
    AppTheme(
      name: 'Teal Moderno',
      description: 'Teal contemporâneo e sofisticado',
      primaryColor: Color(0xFF00796B),
      secondaryColor: Color(0xFF4DB6AC),
      icon: Icons.waves,
    ),
    AppTheme(
      name: 'Rosa Elegante',
      description: 'Rosa suave e elegante',
      primaryColor: Color(0xFFC2185B),
      secondaryColor: Color(0xFFF06292),
      icon: Icons.favorite,
    ),
    AppTheme(
      name: 'Índigo Tecnológico',
      description: 'Índigo tech e inovador',
      primaryColor: Color(0xFF303F9F),
      secondaryColor: Color(0xFF5C6BC0),
      icon: Icons.computer,
    ),
    AppTheme(
      name: 'Âmbar Quente',
      description: 'Âmbar acolhedor e caloroso',
      primaryColor: Color(0xFFF57C00),
      secondaryColor: Color(0xFFFFB74D),
      icon: Icons.wb_sunny,
    ),
    AppTheme(
      name: 'Ciano Fresco',
      description: 'Ciano fresco e limpo',
      primaryColor: Color(0xFF0097A7),
      secondaryColor: Color(0xFF4DD0E1),
      icon: Icons.water_drop,
    ),
    AppTheme(
      name: 'Vermelho Intenso',
      description: 'Vermelho intenso e impactante',
      primaryColor: Color(0xFFD32F2F),
      secondaryColor: Color(0xFFE57373),
      icon: Icons.whatshot,
    ),
  ];

  /// Obtém um tema por índice.
  static AppTheme getTheme(int index) {
    if (index >= 0 && index < themes.length) {
      return themes[index];
    }
    return themes[0]; // Padrão
  }
}

/// Ícones disponíveis para a aplicação.
class AppIcon {
  final String key;
  final String name;
  final String description;
  final IconData? icon;
  final String? assetPath;
  final Color color;

  const AppIcon({
    required this.key,
    required this.name,
    required this.description,
    this.icon,
    this.assetPath,
    required this.color,
  });
}

/// Ícones predefinidos da aplicação.
class PredefinedIcons {
  static const List<AppIcon> icons = [
    AppIcon(
      key: 'official',
      name: 'Oficial',
      description: 'Ícone oficial do Facturio',
      assetPath: 'assets/icons/app_icon.svg',
      icon: Icons.receipt_long,
      color: Color(0xFF1976D2),
    ),
    AppIcon(
      key: 'calculator',
      name: 'Calculadora',
      description: 'Ícone com calculadora',
      assetPath: 'assets/icons/app_icon_calculator.svg',
      icon: Icons.calculate,
      color: Color(0xFF388E3C),
    ),
    AppIcon(
      key: 'money',
      name: 'Dinheiro',
      description: 'Ícone com cifrão',
      assetPath: 'assets/icons/app_icon_money.svg',
      icon: Icons.attach_money,
      color: Color(0xFFF57C00),
    ),
    AppIcon(
      key: 'documents',
      name: 'Documentos',
      description: 'Ícone com documentos',
      assetPath: 'assets/icons/app_icon_documents.svg',
      icon: Icons.description,
      color: Color(0xFF7B1FA2),
    ),
    AppIcon(
      key: 'chart',
      name: 'Gráfico',
      description: 'Ícone com gráfico',
      assetPath: 'assets/icons/app_icon_chart.svg',
      icon: Icons.trending_up,
      color: Color(0xFF0097A7),
    ),
    AppIcon(
      key: 'business',
      name: 'Negócios',
      description: 'Ícone corporativo',
      assetPath: 'assets/icons/app_icon_business.svg',
      icon: Icons.business_center,
      color: Color(0xFF303F9F),
    ),
  ];

  /// Obtém um ícone por índice.
  static AppIcon getIcon(int index) {
    if (index >= 0 && index < icons.length) {
      return icons[index];
    }
    return icons[0]; // Padrão
  }
}
