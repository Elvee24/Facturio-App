import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/services/tutorial_service.dart';
import '../../data/tutorial_slides.dart';

/// Página do tutorial/onboarding interativo e responsivo.
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeTutorial() async {
    await TutorialService.completeTutorial();
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _skipTutorial() async {
    await TutorialService.skipTutorial();
    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _nextPage() {
    if (_currentPage < TutorialSlides.slides(context).length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t({required String pt, required String en}) =>
        AppText.tr(context, pt: pt, en: en);

    final slides = TutorialSlides.slides(context);
    final colors = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão de pular
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo ou título
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: colors.primary, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        'Facturio',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                      ),
                    ],
                  ),
                  // Botão de pular
                  if (!isLastPage)
                    TextButton(
                      onPressed: _skipTutorial,
                      child: Text(t(pt: 'Pular', en: 'Skip')),
                    ),
                ],
              ),
            ),

            // PageView com slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return _buildSlide(context, slide);
                },
              ),
            ),

            // Indicadores de página
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => _buildPageIndicator(index, colors),
                ),
              ),
            ),

            // Botões de navegação
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Voltar
                  if (_currentPage > 0)
                    OutlinedButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(t(pt: 'Voltar', en: 'Back')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 120),

                  // Botão Próximo/Começar
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
                    label: Text(isLastPage ? t(pt: 'Começar', en: 'Start') : t(pt: 'Próximo', en: 'Next')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, TutorialSlide slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone grande com container circular
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  slide.color,
                  slide.color.withValues(alpha: 0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Título
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: slide.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Descrição
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Lista de features (se existir)
          if (slide.features != null && slide.features!.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.tr(context, pt: 'Principais Recursos:', en: 'Key Features:'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...slide.features!.map((feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: slide.color,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, ColorScheme colors) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? colors.primary : colors.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
