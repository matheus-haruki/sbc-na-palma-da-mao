import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/app_browser_navigator.dart'; // Utilitário de navegação web já existente
import 'package:palma_da_mao/modules/servicos/models/faq_model.dart';
import 'package:palma_da_mao/modules/servicos/mocks/ocorrencias_animais_mock.dart';

class OcorrenciasAnimaisPage extends StatelessWidget {
  const OcorrenciasAnimaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ocorrencias = OcorrenciasAnimaisMock.ocorrencias;

    return AppStandardPage(
      title: 'Ocorrências com Animais',
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Texto Introdutório
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                OcorrenciasAnimaisMock.introducao,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),

          // 2. Lista de Ocorrências (Reaproveitando o Design de Cards)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: ocorrencias.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = ocorrencias[index];

                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      item.pergunta,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    onTap: () => _showRespostaBottomSheet(context, item, theme),
                  ),
                );
              },
            ),
          ),

          // 3. Rodapé com Links Externos (RichText)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFooterLink(
                    context,
                    theme,
                    textoBase: 'Para saber mais sobre a fauna, acesse o ',
                    textoLink: 'Atlas Socioambiental de São Bernardo do Campo.',
                    url:
                        'https://www.saobernardo.sp.gov.br/web/sma/atlas/fauna-animais-estimacao-pet-bichos-silvestres-bichos-na-cidade', // Exemplo
                  ),
                  const SizedBox(height: 16),
                  _buildFooterLink(
                    context,
                    theme,
                    textoBase: 'Conheça o ',
                    textoLink:
                        'Hospital Público Veterinário de São Bernardo do Campo.',
                    url:
                        'https://www.saobernardo.sp.gov.br/web/sbc/hospital-publico-veterinario', // Exemplo
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói parágrafos com links clicáveis nativos usando RichText
  Widget _buildFooterLink(
    BuildContext context,
    ThemeData theme, {
    required String textoBase,
    required String textoLink,
    required String url,
  }) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        children: [
          TextSpan(text: textoBase),
          TextSpan(
            text: textoLink,
            style: const TextStyle(
              color: Colors.blue, // Ou AppColors.primary dependendo do seu DS
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                AppBrowserNavigator.openWebPage(
                  context: context,
                  urlString: url,
                );
              },
          ),
        ],
      ),
    );
  }

  /// Método exatamente igual ao do IPTU, mantendo consistência de UI.
  void _showRespostaBottomSheet(
    BuildContext context,
    FaqItem item,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Text(
                      item.pergunta,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList.separated(
                    itemCount: item.conteudo.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final bloco = item.conteudo[index];

                      if (bloco is FaqText) {
                        return Text(
                          bloco.texto,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        );
                      }

                      if (bloco is FaqImage) {
                        return InteractiveViewer(
                          panEnabled: true,
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              bloco.assetPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
