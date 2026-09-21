import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/modules/servicos/models/faq_model.dart'; // Import do modelo
import 'package:palma_da_mao/modules/servicos/mocks/iptu_duvidas_mock.dart'; // Import do mock

class IptuDuvidasPage extends StatelessWidget {
  const IptuDuvidasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Puxando os dados limpos do nosso arquivo de Mock!
    final duvidas = IptuDuvidasMock.lista;

    return AppStandardPage(
      title: 'Dúvidas sobre IPTU',
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        itemCount: duvidas.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = duvidas[index];

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
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.secondary,
                size: 20,
              ),
              onTap: () => _showRespostaBottomSheet(context, item, theme),
            ),
          );
        },
      ),
    );
  }

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
                          panEnabled:
                              true, // Permite arrastar a imagem para os lados quando estiver com zoom
                          minScale:
                              1.0, // O tamanho mínimo é o tamanho normal da imagem
                          maxScale:
                              4.0, // O usuário pode dar um zoom de até 4x o tamanho original
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              bloco.assetPath,
                              fit: BoxFit
                                  .contain, // contain é melhor que cover para documentos, pois não corta as bordas!
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
