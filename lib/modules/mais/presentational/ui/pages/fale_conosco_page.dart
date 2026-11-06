import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/services/phone_service.dart';

class ContatoTelefone {
  final String setor;
  final List<String> numeros;
  final bool isEmergencia;

  const ContatoTelefone({
    required this.setor,
    required this.numeros,
    this.isEmergencia = false,
  });
}

class FaleConoscoPage extends StatelessWidget {
  const FaleConoscoPage({super.key});

  static const List<ContatoTelefone> _emergencias = [
    ContatoTelefone(
      setor: 'Defesa Civil',
      numeros: ['199'],
      isEmergencia: true,
    ),
    ContatoTelefone(
      setor: 'GCM – Guarda Civil Municipal',
      numeros: ['153'],
      isEmergencia: true,
    ),
  ];

  static const List<ContatoTelefone> _outrosServicos = [
    ContatoTelefone(
      setor: 'Finanças',
      numeros: ['0800-770-3738'],
    ),
    ContatoTelefone(
      setor: 'Concursos Públicos',
      numeros: ['(11) 2630-4000'],
    ),
    ContatoTelefone(
      setor: 'Iluminação',
      numeros: ['0800-771-1159'],
    ),
    ContatoTelefone(
      setor: 'Depto. de Macrodrenagem',
      numeros: ['(11) 4341-8090'],
    ),
    ContatoTelefone(
      setor: 'Serviço Funerário',
      numeros: ['(11) 4330-4527'],
    ),
    ContatoTelefone(
      setor: 'Transporte Coletivo',
      numeros: ['0800-770-1988'],
    ),
    ContatoTelefone(
      setor: 'Monitoramento e Fiscalização de Trânsito',
      numeros: [
        '(11) 2630-7045',
        '(11) 2630-7046',
        '(11) 2630-7047',
        '(11) 2630-7048',
      ],
    ),
    ContatoTelefone(
      setor: 'Serviço de Manutenção da Cidade',
      numeros: ['0800-7708-156'],
    ),
    ContatoTelefone(
      setor: 'Atende Bem',
      numeros: ['(11) 2630-7350'],
    ),
  ];

  void _fazerLigacao(BuildContext context, String numero) {
    HapticFeedback.lightImpact();
    PhoneService.call(numero);
  }

  void _copiarNumero(BuildContext context, String numero) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: numero));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Número copiado: $numero'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppStandardPage(
      title: 'Fale com a Prefeitura',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Frase de instrução
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toque em um contato para ligar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Seção Emergências
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC3545),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Emergências',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC3545),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._emergencias.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCardSimples(context, item),
              )),

          const SizedBox(height: 16),

          // 3. Seção Outros Serviços
          Text(
            'Outros serviços',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._outrosServicos.map((item) {
            final isMultiplo = item.numeros.length > 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isMultiplo
                  ? _buildCardMultiplo(context, item)
                  : _buildCardSimples(context, item),
            );
          }),
        ],
      ),
    );
  }

  /// Card para contatos com número único
  Widget _buildCardSimples(BuildContext context, ContatoTelefone contato) {
    final theme = Theme.of(context);
    final isEmergencia = contato.isEmergencia;
    final numero = contato.numeros.first;
    final Color numberColor =
        isEmergencia ? const Color(0xFFDC3545) : AppColors.secondary;
    final Color borderColor =
        isEmergencia ? const Color(0xFFFFCDD2) : Colors.grey.shade200;

    return Semantics(
      button: true,
      label:
          'Ligar para ${contato.setor}, $numero. Pressione e segure para copiar.',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _fazerLigacao(context, numero),
            onLongPress: () => _copiarNumero(context, numero),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      contato.setor,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      numero,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: numberColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Card para contatos com múltiplos números (Trânsito)
  Widget _buildCardMultiplo(BuildContext context, ContatoTelefone contato) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              contato.setor,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
          ...contato.numeros.map((numero) {
            final isLast = numero == contato.numeros.last;

            return Column(
              children: [
                Semantics(
                  button: true,
                  label:
                      'Ligar para ${contato.setor}, $numero. Pressione e segure para copiar.',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _fazerLigacao(context, numero),
                      onLongPress: () => _copiarNumero(context, numero),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            numero,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF8F9FA)),
              ],
            );
          }),
        ],
      ),
    );
  }
}
