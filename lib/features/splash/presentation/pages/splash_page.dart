import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/tutorial_service.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Verificar se deve mostrar tutorial e navegar
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // Verificar se é a primeira vez que o usuário abre o app
        if (TutorialService.shouldShowTutorial()) {
          context.go(AppRoutes.tutorial);
        } else {
          context.go(AppRoutes.dashboard);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    final selectedIcon = ref.watch(themeProvider).currentIcon;
    
    // Tamanho adaptativo do logo baseado no tamanho da tela
    final logoSize = (size.shortestSide * 0.34).clamp(130.0, 240.0).toDouble();
    final topToIconSpacing = (size.height * 0.10).clamp(36.0, 92.0).toDouble();
    final iconToTitleSpacing = (size.height * 0.035).clamp(20.0, 34.0).toDouble();
    final titleToSubtitleSpacing = (size.height * 0.01).clamp(6.0, 12.0).toDouble();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(height: topToIconSpacing),
                          Container(
                            width: logoSize,
                            height: logoSize,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(logoSize * 0.15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: selectedIcon.assetPath != null
                                  ? SvgPicture.asset(
                                      selectedIcon.assetPath!,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      placeholderBuilder: (context) {
                                        return Icon(
                                          Icons.receipt_long_rounded,
                                          size: logoSize * 0.6,
                                          color: colors.primary,
                                        );
                                      },
                                    )
                                  : Icon(
                                      selectedIcon.icon ?? Icons.receipt_long_rounded,
                                      size: logoSize * 0.62,
                                      color: selectedIcon.color,
                                    ),
                            ),
                          ),
                          SizedBox(height: iconToTitleSpacing),
                          Text(
                            'Facturio',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * 0.12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: titleToSubtitleSpacing),
                          Text(
                            AppText.tr(
                              context,
                              pt: 'Sistema de Faturação',
                              en: 'Billing System',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: size.height * 0.08),
                          SizedBox(
                            width: logoSize * 0.35,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
