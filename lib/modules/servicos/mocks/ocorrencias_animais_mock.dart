import 'package:palma_da_mao/modules/servicos/models/faq_model.dart';

class OcorrenciasAnimaisMock {
  static const String introducao =
      'Os animais domésticos, como cães e gatos, estão cada vez mais presentes nos lares de São Bernardo do Campo. Além disso, o município também abriga uma grande variedade de animais silvestres: aves em geral, capivaras, saruês, saguis, serpentes, entre outros. Eles estão presentes não somente em áreas com vegetação mais preservada, mas também em ambientes urbanos. Aqui você encontrará informações sobre como proceder em ocorrências envolvendo animais silvestres, animais domésticos e animais de criação, como bois e cavalos, no município de São Bernardo do Campo.';

  static const List<FaqItem> ocorrencias = [
    FaqItem(
      pergunta: 'Entrega voluntária de animal silvestre legalizado ou não legalizado',
      conteudo: [
        FaqText('Instruções sobre como realizar a entrega voluntária sem penalidades, dirigindo-se aos órgãos ambientais competentes... (Texto de exemplo)'),
      ],
    ),
    FaqItem(
      pergunta: 'Animal silvestre ferido ou acidentado',
      conteudo: [
        FaqText('Caso encontre um animal ferido, não tente capturá-lo. Acione imediatamente a Polícia Militar Ambiental ou o Centro de Controle de Zoonoses... (Texto de exemplo)'),
      ],
    ),
    FaqItem(
      pergunta: 'Animal silvestre saudável e que não oferece risco',
      conteudo: [
        FaqText('Se o animal estiver em seu habitat ou de passagem sem causar riscos, a recomendação é apenas observar e não interferir... (Texto de exemplo)'),
      ],
    ),
    // ... Adicione os demais itens seguindo este padrão
  ];
}