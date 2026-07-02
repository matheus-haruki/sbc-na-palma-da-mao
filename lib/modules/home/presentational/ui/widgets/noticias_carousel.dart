import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Importação do Lottie
import 'package:palma_da_mao/core/components/dot_indicator.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
// Lembre-se de importar o AppAssets se for usá-lo para os caminhos

// 1. Criamos um modelo simples para organizar os dados da notícia
class NoticiaItem {
  final String titulo;
  final String lottiePath;

  NoticiaItem({required this.titulo, required this.lottiePath});
}

class NoticiasCarousel extends StatefulWidget {
  const NoticiasCarousel({super.key});

  @override
  State<NoticiasCarousel> createState() => _NoticiasCarouselState();
}

class _NoticiasCarouselState extends State<NoticiasCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 2. Nossa nova lista de dados mockados com as mensagens e caminhos dos Lotties
  final List<NoticiaItem> noticias = [
    NoticiaItem(
      titulo: 'Vacina da gripe',
      lottiePath: AppAssets
          .vacinaAnimation, // Ajuste para a variável do seu AppAssets se preferir
    ),
    NoticiaItem(
      titulo: 'Segunda via do IPTU',
      lottiePath: AppAssets.iptuAnimation,
    ),
    NoticiaItem(titulo: 'Adote um amigo', lottiePath: AppAssets.dogAnimation),
  ];

  @override
  void dispose() {
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

              // Widget do Texto isolado
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
                  // Alinha o texto dependendo de que lado ele está
                  textAlign: isAnimacaoEsquerda
                      ? TextAlign.left
                      : TextAlign.right,
                ),
              );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(-1, 0.50),
                    radius: 4.45,
                    colors: [const Color(0xFF1F3A5F), const Color(0xFF3C91D0)],
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
