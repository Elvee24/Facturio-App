import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/providers/theme_provider.dart';

class AppLogo extends ConsumerWidget {
  final double size;
  final bool showText;
  final String? text;

  const AppLogo({
    super.key,
    this.size = 32,
    this.showText = false,
    this.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIcon = ref.watch(themeProvider).currentIcon;

    Widget iconWidget() {
      if (selectedIcon.assetPath != null) {
        return SvgPicture.asset(
          selectedIcon.assetPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        );
      }

      return Icon(
        selectedIcon.icon ?? Icons.receipt_long,
        size: size,
        color: selectedIcon.color,
      );
    }

    if (!showText) {
      return Center(
        child: iconWidget(),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget(),
          const SizedBox(height: 10),
          Text(
            text ?? 'Facturio',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
