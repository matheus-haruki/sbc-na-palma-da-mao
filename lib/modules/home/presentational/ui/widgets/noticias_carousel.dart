import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart'; // Import do Modular
import 'package:lottie/lottie.dart';
import 'package:palma_da_mao/core/components/dot_indicator.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/app_browser_navigator.dart'; // Import do navegador nativo

// 1. Modelo atualizado para receber a ação de clique (onTap)
class NoticiaItem {
  final String titulo;
  final String lottiePath;
  final void Function(BuildContext) onTap; // Ação específica de cada notícia

  NoticiaItem({
    required this.titulo,
    required this.lottiePath,
    required this.onTap,
  });
}

class NoticiasCarousel extends StatefulWidget {
  const NoticiasCarousel({super.key});

  @override
  State<NoticiasCarousel> createState() => _NoticiasCarouselState();
}

class _NoticiasCarouselState extends State<NoticiasCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  // 2. Lista atualizada com as navegações exatas que você solicitou
  late final List<NoticiaItem> noticias = [
    NoticiaItem(
      titulo: 'Campanha de vacinação',
      lottiePath: AppAssets.vacinaAnimation,
      onTap: (context) {
        Modular.to.pushNamed('./vacinacao');
      },
    ),
    NoticiaItem(
      titulo: 'Segunda via do IPTU',
      lottiePath: AppAssets.iptuAnimation,
      onTap: (context) {
        Modular.to.pushNamed('/iptu');
      },
    ),
    NoticiaItem(
      titulo: 'Adote um amigo',
      lottiePath: AppAssets.dogAnimation,
      onTap: (context) {
        // Navega para a tela nativa de instruções de adoção
        Modular.to.pushNamed('/main/servicos/adocao-instrucoes');
      },
    ),
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < noticias.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 115,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: noticias.length,
            itemBuilder: (context, index) {
              final noticia = noticias[index];

              final bool isAnimacaoEsquerda = index % 2 == 0;

              final Widget animacaoWidget = SizedBox(
                child: Center(
                  child: Lottie.asset(noticia.lottiePath, fit: BoxFit.cover),
                ),
              );

              final Widget textoWidget = Expanded(
                child: Text(
                  noticia.titulo,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isAnimacaoEsquerda
                      ? TextAlign.left
                      : TextAlign.right,
                ),
              );

              // 3. Adicionamos o GestureDetector para capturar o clique no Card
              return GestureDetector(
                onTap: () => noticia.onTap(context),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      center: Alignment(-1, 0.50),
                      radius: 4.45,
                      colors: [
                        AppColors.gradientBlueStart,
                        AppColors.gradientBlueEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isAnimacaoEsquerda) ...[
                        animacaoWidget,
                        const SizedBox(width: 16),
                        textoWidget,
                      ] else ...[
                        textoWidget,
                        const SizedBox(width: 16),
                        animacaoWidget,
                      ],
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.white),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        DotIndicator(itemCount: noticias.length, currentIndex: _currentIndex),
      ],
    );
  }
}
