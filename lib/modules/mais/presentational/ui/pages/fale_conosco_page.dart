import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';

class FaleConoscoPage extends StatelessWidget {
  const FaleConoscoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> contatos = [
      {
        'setor': 'Finanças',
        'numeros': ['0800-770-3738'],
      },
      {
        'setor': 'Concursos Públicos',
        'numeros': ['2630-4000'],
      },
      {
        'setor': 'Iluminação',
        'numeros': ['0800-77-11159'],
      },
      {
        'setor': 'Depto. de Macrodrenagem',
        'numeros': ['4341-8090'],
      },
      {
        'setor': 'Defesa Civil',
        'numeros': ['199'],
      },
      {
        'setor': 'Serviço Funerário',
        'numeros': ['4330-4527'],
      },
      {
        'setor': 'GCM - Guarda Civil Municipal',
        'numeros': ['153'],
      },
      {
        'setor': 'Transporte Coletivo',
        'numeros': ['0800-77-01-988'],
      },
      {
        'setor': 'Monitoramento e Fiscalização de Trânsito',
        'numeros': ['2630-7045', '2630-7046', '2630-7047', '2630-7048'],
      },
      {
        'setor': 'Serviço de Manutenção da Cidade',
        'numeros': ['0800-7708-156'],
      },
      {
        'setor': 'Atende Bem',
        'numeros': ['(11)2630-7350'],
      },
    ];

    // Chamada limpa do componente de estrutura arredondada
    return AppStandardPage(
      title: 'Fale com a Prefeitura',
      body: ListView.separated(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        itemCount: contatos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final contato = contatos[index];
          final List<String> numeros = List<String>.from(contato['numeros']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text: '${contato['setor']}: ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (numeros.length == 1)
                      TextSpan(
                        text: numeros.first,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                  ],
                ),
              ),

              if (numeros.length > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: numeros
                        .map(
                          (numero) => Text(
                            '• $numero',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
