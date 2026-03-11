import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class AppText {
  static bool isEnglish(BuildContext context) {
    return ThemeService.getAppLanguage() == 'en';
  }

  static String tr(
    BuildContext context, {
    required String pt,
    required String en,
  }) {
    return isEnglish(context) ? en : pt;
  }
}
