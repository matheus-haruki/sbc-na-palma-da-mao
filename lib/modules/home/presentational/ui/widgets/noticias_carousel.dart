import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palma_da_mao/core/components/dot_indicator.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';

// Este widget é Stateful apenas para gerenciar o próprio índice (Dot Indicator)
class NoticiasCarousel extends StatefulWidget {
  // Futuramente, esta lista virá do HomeCubit
  final List<String> noticiasMock = const [
    'Campanha de Vacinação Contra a Gripe - Saiba onde se vacinar',
    'Novas vagas de emprego abertas no portal do cidadão',
    'Manutenção na rede de água: veja os bairros afetados',
  ];

  const NoticiasCarousel({super.key});

  @override
  State<NoticiasCarousel> createState() => _NoticiasCarouselState();
}

class _NoticiasCarouselState extends State<NoticiasCarousel> {
  // Controlador da página e variável para rastrear o dot ativo
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Área do Carrossel (Cards)
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            // Atualiza o índice do Dot Indicator ao arrastar
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.noticiasMock.length,
            itemBuilder: (context, index) {
              final noticia = widget.noticiasMock[index];

              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 4,
                ), // Margem leve para não colar na tela se houver overflow
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Usando a cor primária do tema em vez de hexadecimal solto
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Círculo com ícone (Design de referência)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Fundo branco com 15% de opacidade para dar contraste no azul
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.iconeSaude,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Texto da Notícia (Expanded evita overflow no texto)
                    Expanded(
                      child: Text(
                        noticia,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Chevron (Seta indicativa de navegação)
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 2. Dot Indicators (Pill-shaped)
        DotIndicator(
          itemCount: widget.noticiasMock.length,
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}
