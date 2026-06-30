import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';

class FaleConoscoPage extends StatelessWidget {
  const FaleConoscoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> contatos = [
      {'setor': 'Finanças', 'numero': '0800-770-3738'},
      {'setor': 'Concursos Públicos', 'numero': '2630-4000'},
      {'setor': 'Iluminação', 'numero': '0800-77-11159'},
      {'setor': 'Depto. de Macrodrenagem', 'numero': '4341-8090'},
      {'setor': 'Defesa Civil', 'numero': '199'},
      {'setor': 'Serviço Funerário', 'numero': '4330-4527'},
      {'setor': 'GCM - Guarda Civil Municipal', 'numero': '153'},
      {'setor': 'Transporte Coletivo', 'numero': '0800-77-01-988'},
      {'setor': 'Atende Bem', 'numero': '(11)2630-7350'},
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
          
          return RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary, 
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '${contato['setor']}: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: contato['numero'],
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}