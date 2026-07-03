import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class AdocaoInstrucoesPage extends StatelessWidget {
  const AdocaoInstrucoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppStandardPage(
      title: 'Instruções para Adoção',
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Título e Introdução
            Text(
              'Adoção Permanente',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Para adotar um animal é necessário comparecer pessoalmente ao CCZ (Centro de Controle de Zoonoses):',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // 2. Card de Informações de Contato (Destaque visual)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    theme,
                    icone: Icons.location_on_outlined,
                    titulo: 'Centro de Controle de Zoonoses',
                    valor: 'Rua Dr. Rudge Ramos, nº 1740 - R. Ramos',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    theme,
                    icone: Icons.phone_outlined,
                    titulo: 'Telefones',
                    valor: '4365-3349, 4367-3306 e 4368-8153',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    theme,
                    icone: Icons.access_time,
                    titulo: 'Atendimento',
                    valor: 'De 2ª a 6ª feiras, das 9h00 às 16h00',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. Requisitos
            Text(
              'Requisitos:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(theme, 'Ser maior de idade;'),
            _buildBulletPoint(theme, 'Ter documento com foto;'),
            _buildBulletPoint(theme, 'Comprovante de residência;'),
            _buildBulletPoint(theme, 'Assinar um termo de responsabilidade;'),
            _buildBulletPoint(
              theme,
              'Trazer caixa de transporte no caso de adoção de gatos;',
            ),
            _buildBulletPoint(theme, 'Coleira e guia para adoção de cães.'),
            const SizedBox(height: 24),

            // 4. Rodapé de Destaque
            InkWell(
              onTap: () {
                // Navega para a nova tela de animais de grande porte
                Modular.to.pushNamed('/main/servicos/grande-porte');
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGray, // Fundo suave
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(color: AppColors.secondary, width: 4), // Borda lateral
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'A adoção é gratuita!\n\nAnimais de Grande Porte (Toque para ver os requisitos).',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),const SizedBox(height: 40), // Respiro final
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para desenhar o texto com uma "bolinha" do lado (Bullet point)
  Widget _buildBulletPoint(ThemeData theme, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Método auxiliar para desenhar as linhas do card de contato com ícones
  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 20, color: AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
