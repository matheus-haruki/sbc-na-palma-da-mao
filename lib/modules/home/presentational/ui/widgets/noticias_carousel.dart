import 'dart:async'; // Importação necessária para o Timer
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:palma_da_mao/core/components/dot_indicator.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

// Modelo simples para organizar os dados da notícia
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
  Timer? _timer; // Variável para controlar o loop automático

  // Lista de dados mockados com as mensagens e caminhos dos Lotties vindos do AppAssets
  final List<NoticiaItem> noticias = [
    NoticiaItem(
      titulo: 'Vacina da gripe',
      lottiePath: AppAssets.vacinaAnimation,
    ),
    NoticiaItem(
      titulo: 'Segunda via do IPTU',
      lottiePath: AppAssets.iptuAnimation,
    ),
    NoticiaItem(titulo: 'Adote um amigo', lottiePath: AppAssets.dogAnimation),
  ];

  @override
  void initState() {
    super.initState();

    // Inicia o Timer que avança a página a cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < noticias.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Volta para o início (loop infinito)
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
    _timer
        ?.cancel(); // Cancela o timer para evitar vazamento de memória (Memory Leak)
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

              // Regra matemática para alternar a posição dos itens (Pares na esquerda, Ímpares na direita)
              final bool isAnimacaoEsquerda = index % 2 == 0;

              // Widget da Animação Lottie isolado
              final Widget animacaoWidget = SizedBox(
                child: Center(
                  child: Lottie.asset(noticia.lottiePath, fit: BoxFit.cover),
                ),
              );

              // Widget do Texto isolado com alinhamento dinâmico
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

              return Container(
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
                    // Intercala a ordem dos componentes na Row baseado no index
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

        // Indicador de bolinhas sincronizado com o PageView
        DotIndicator(itemCount: noticias.length, currentIndex: _currentIndex),
      ],
    );
  }
}
