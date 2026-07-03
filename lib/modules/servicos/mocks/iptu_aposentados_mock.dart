import 'package:palma_da_mao/modules/servicos/models/faq_model.dart';

class IptuAposentadosMock {
  static const List<FaqItem> lista = [
    FaqItem(
      pergunta: 'Qual o desconto no IPTU para aposentados?',
      conteudo: [
        FaqText(
          'Tem direito ao benefício de 50% no IPTU e taxa(s) vinculadas: o contribuinte (proprietário do imóvel) na condição de aposentado, pensionista ou beneficiário de Amparo Social ao Idoso de Instituto de Previdência Pública, que resida no imóvel, e com renda bruta total (aposentadoria mais outras rendas) de até R\$ 3.795,00 (rendimentos referentes ao ano 2025) conforme Lei Municipal nº 6.594/2017, sendo que esse valor será atualizado em 2025 quando houver o reajuste do salário-mínimo. O artigo 13 da Lei Municipal 6.594/2017 foi alterado pelo Artigo 13 da Lei 7.038/2021. Porém, de acordo com o Artigo 21 dessa lei, as alterações só valerão para os tributos incidentes a partir do exercício de 2026.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Quais casos não têm direito ao desconto de aposentado?',
      conteudo: [
        FaqText(
          'Não têm direito ao benefício os contribuintes que se enquadrem nas seguintes situações:',
        ),
        FaqText(
          '1. Sejam beneficiados com auxílio-doença, auxílio-acidente, pensão alimentícia e outros benefícios recebidos temporariamente.\n2. Não residam no imóvel.\n3. Possuem renda bruta total que ultrapassem o valor de R\$ 3.795,00 (rendimentos referentes ao ano de 2025) e R\$ 3.530,00 (rendimentos referentes ao ano 2024).',
        ),
        FaqText(
          'Para os pedidos feitos para os tributos incidentes no exercício de 2023 em diante, também não têm direito ao benefício:',
        ),
        FaqText(
          '• Contribuinte que possuir mais de um imóvel no município de SBC.\n• A soma da Renda Bruta de benefícios previdenciários e benefícios sociais (Bolsa Família, Auxílio Brasil, etc.) não pode ultrapassar o valor de 2,5 salários mínimos, considerando o valor do salário mínimo no Brasil em Dezembro/2025.\n• O imóvel para o qual se pede o benefício não pode ter mais que 300 m² de área construída e 1000,00 m² de área de terreno.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Como saber se meu IPTU já está com desconto de aposentado?',
      conteudo: [
        FaqText(
          'Se o seu carnê já tiver sido emitido com desconto, nele haverá a seguinte mensagem: APOSENTADO, JÁ LANÇADO COM DESCONTO DE 50%.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Como solicitar o desconto de aposentado?',
      conteudo: [
        FaqText(
          'Faça a solicitação diretamente pela WEB: Acesse o site http://www.saobernardo.sp.gov.br/prodigi/. Clique em "Efetuar login" e acesse o sistema. Caso não tenha login e senha, clique em "Cadastro de usuários" e realize seu cadastro.',
        ),
        FaqText(
          'IMPORTANTE: Para solicitar, tanto o solicitante (proprietário do imóvel) quanto o responsável técnico e/ou representante legal (caso houver) necessitam cadastrar um login e senha pessoal. Após realizar o cadastro e login, na página "Serviços on-line", dentre as opções de "Tipo de Serviço", selecione "Benefício Fiscal - Lei 6594/2017 - Isenção 50% Aposentado/Pensionista". O formulário referente ao serviço deverá ser preenchido na tela e anexado todos os documentos necessários, que deverão estar digitalizados em PDF. ',
        ),
        FaqText(
          'Ou agende o serviço em um dos centros de atendimento ao cidadão ATENDE BEM (o agendamento também poderá ser feito pelo site da Prefeitura http://www.saobernardo.sp.gov.br em “Agendamento Eletrônico”)',
        ),
      ],
    ),
  ];
}
