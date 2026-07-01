import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palma_da_mao/core/components/dot_indicator.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

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
                ),  
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightBlue,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppAssets.iconeSaude,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
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
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Chevron (Seta indicativa de navegação)
                    const Icon(Icons.chevron_right, color: AppColors.white),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        DotIndicator(
          itemCount: widget.noticiasMock.length,
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}
