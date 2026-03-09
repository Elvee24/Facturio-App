import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (!showText) {
      return SvgPicture.asset(
        'assets/images/logo.svg',
        width: size,
        height: size,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/logo.svg',
          width: size,
          height: size,
        ),
        const SizedBox(width: 12),
        Text(
          text ?? 'Facturio',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
