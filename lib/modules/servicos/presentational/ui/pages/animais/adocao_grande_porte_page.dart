import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class AdocaoGrandePortePage extends StatelessWidget {
  const AdocaoGrandePortePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: AppStandardPage(
        title: 'Animais de Grande Porte',
        body: Column(
          children: [
            // Barra de Abas (Tabs) para separar as espécies de forma limpa
            Material(
              color: Colors.white,
              elevation: 1,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'BOVINOS'),
                  Tab(text: 'EQUINOS'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildConteudoBovinos(theme),
                  _buildConteudoEquinos(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Conteúdo específico da aba de Bovinos
  Widget _buildConteudoBovinos(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecaoTitulo(theme, 'Exigências iniciais para a adoção:'),
          _buildItemLista(theme, 'Cópia do RG, CPF e comprovante de residência;'),
          _buildItemLista(theme, 'Cópia autenticada da escritura da propriedade de destino do animal em área rural e ITR (Imposto Territorial Rural) atualizado.'),
          _buildItemLista(theme, 'Cópia da Guia de Transporte Animal (GTA). A propriedade deve ser cadastrada junto à Coordenadoria de Defesa Agropecuária (CDA) do respectivo estado. O cadastro será exigido para emissão do GTA.'),
          
          const SizedBox(height: 24),
          _buildSecaoTitulo(theme, 'Exigências do Ministério da Agricultura para emissão de GTA:'),
          _buildItemLista(theme, 'Exames de tuberculose e brucelose, realizado por um médico veterinário cadastrado no CDA;'),
          _buildItemLista(theme, 'Vacinação do animal contra Febre Aftosa.'),
          _buildItemLista(theme, 'Atestado de Saúde de que a propriedade está isenta de doença infecto contagiosa há mais de 30 dias (fornecido pelo CCZ).'),
          _buildItemLista(theme, 'Assinatura de Termo de Responsabilidade e Propriedade (Termo emitido pela CCZ em duas vias, contendo dados dos animais). Será assinado pelo interessado ou seu procurador, com firma reconhecida, no dia da retirada do animal.'),
          
          const SizedBox(height: 24),
          _buildSecaoTitulo(theme, 'Transporte Adequado:'),
          _buildItemText(theme, 'Veículo apropriado para o transporte de animais de grande porte/carga viva, que deverá ser providenciado pelo proprietário.'),
          
          const SizedBox(height: 24),
          _buildCardInformacoesGerais(theme),
          const SizedBox(height: 24),
          _buildCardLocalAdocao(theme),
        ],
      ),
    );
  }

  /// Conteúdo específico da aba de Equinos
  Widget _buildConteudoEquinos(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecaoTitulo(theme, 'Exigências iniciais para a adoção:'),
          _buildItemLista(theme, 'Cópia do RG, CPF e comprovante de residência;'),
          _buildItemLista(theme, 'Cópia autenticada da escritura da propriedade de destino do animal em área rural e ITR (Imposto Territorial Rural) atualizado.'),
          _buildItemLista(theme, 'Cópia da Guia de transporte animal (GTA). A propriedade deve ser cadastrada junto à Coordenadoria de Defesa Agropecuária (CDA) do respectivo estado. O cadastro será exigido para emissão do GTA.'),
          
          const SizedBox(height: 24),
          _buildSecaoTitulo(theme, 'Exigências do Ministério da Agricultura para emissão de GTA:'),
          _buildItemLista(theme, 'Exames de Mormo e AIE (Anemia Infecciosa Equina), realizado por um médico veterinário cadastrado no CDA (válidos por 60 dias).'),
          _buildItemLista(theme, 'Vacinação do animal contra Influenza.'),
          _buildItemLista(theme, 'Atestado de Saúde de que a propriedade está isenta de doença infecto contagiosa há mais de 30 dias (fornecido pelo CCZ).'),
          _buildItemLista(theme, 'Assinatura de Termo de responsabilidade e propriedade (Termo emitido pela CCZ em duas vias contendo dados dos animais). Será assinado pelo interessado ou seu procurador, com firma reconhecida, no dia da retirada do animal.'),
          
          const SizedBox(height: 24),
          _buildSecaoTitulo(theme, 'Transporte Adequado:'),
          _buildItemText(theme, 'Veículo apropriado para o transporte de animais de grande porte/carga viva, que deverá ser providenciado pelo proprietário.'),
          
          const SizedBox(height: 24),
          _buildCardInformacoesGerais(theme),
          
          const SizedBox(height: 24),
          _buildSecaoTitulo(theme, 'Legislação aplicável:'),
          _buildItemLegislacao(theme, 'Art. 333 - Decreto Estadual 12.342/78', '"Novas instalações de estábulos, cocheiras, granjas avícolas e estabelecimentos congêneres, só serão permitidas na zona rural".'),
          _buildItemLegislacao(theme, 'Art. 338 - Decreto Estadual 12.342/78', '"Novas instalações de estábulos, cocheiras, granjas avícolas e estabelecimentos congêneres devem ficar à distância mínima de 50 (cinquenta) metros dos limites dos terrenos vizinhos e das faixas de domínio das estradas".'),
          _buildItemLegislacao(theme, 'Art. 339 - Decreto Estadual 12.342/78', '"Os estábulos, cocheiras, granjas avícolas e estabelecimentos congêneres, não beneficiados pelos sistemas públicos de água e esgoto, ficam obrigados a adotar medidas a serem aprovadas pelas autoridades sanitárias no que concerne à provisão de água e à disposição dos resíduos sólidos e líquidos".'),
          
          const SizedBox(height: 24),
          _buildCardLocalAdocao(theme),
        ],
      ),
    );
  }

  Widget _buildSecaoTitulo(ThemeData theme, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        titulo,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildItemText(ThemeData theme, String texto) {
    return Text(
      texto,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  Widget _buildItemLista(ThemeData theme, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('- ', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
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

  Widget _buildItemLegislacao(ThemeData theme, String artigo, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artigo,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            texto,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInformacoesGerais(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INFORMAÇÕES GERAIS',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informamos que todos os custos referentes às guias, exames, vacinação, transporte, entre outros, são de inteira responsabilidade do proprietário ou adotante do animal.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade900,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLocalAdocao(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Local de Adoção e Embarque',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Divisão de Veterinária e Controle de Zoonoses\nEndereço: Rua Dr. Rudge Ramos, nº 1.740 - Rudge Ramos\nTelefone: (11) 4365-3349 / 4367-3306 / 4368-8153',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
          const Divider(height: 20),
          Text(
            'Atendimento e Embarque de Carga Viva:\nDe 2ª a 6ª feiras, das 9h às 16h.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}