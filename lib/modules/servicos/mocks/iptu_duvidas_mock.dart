import 'package:palma_da_mao/modules/servicos/models/faq_model.dart';

class IptuDuvidasMock {
  static const List<FaqItem> lista = [
    FaqItem(
      pergunta:
          'Eu recebi o meu carnê para pagamento do exercício de 2026. Quais são os tributos que estão sendo cobrados através desse carnê?',
      conteudo: [
        FaqText(
          'O carnê que foi encaminhado possui a cobrança de IPTU, nos termos da Lei Municipal 1.802/1969, Artigos 95 a 114, e da taxa de coleta de lixo, nos termos da Lei Municipal 1.802/1969, Artigos 195 a 198-A.',
        ),
      ],
    ),

    FaqItem(
      pergunta: 'Qual o índice de atualização aplicado ao IPTU de 2026?',
      conteudo: [
        FaqText(
          'Nos termos da Lei Municipal 6.008/2009, a atualização monetária considera a variação do Índice Nacional de Preços ao Consumidor Amplo-15 – IPCA-15, relativa aos meses de dezembro de 2024 a novembro de 2025, que foi 4,50% (Quatro Inteiros e Cinquenta Centésimos por cento).',
        ),
      ],
    ),

    FaqItem(
      pergunta: 'Entenda os valores do IPTU do seu imóvel:',
      conteudo: [
        FaqText(
          'O valor do IPTU a ser pago é calculado pela aplicação da alíquota sobre o valor venal do imóvel.',
        ),
        FaqText(
          'A alíquota é estipulada em Lei e em função do uso do imóvel e seu valor venal, nos termos da Lei Municipal 1.802/1969, artigo 106.',
        ),
        FaqText(
          'O valor venal do imóvel é calculado através do somatório do valor venal do terreno e da construção, se houver, nos termos da Lei Municipal 1.802/1969, artigo 105.',
        ),
        FaqText(
          'O valor venal do terreno é calculado levando-se em consideração: área do terreno, valor do m² do terreno e demais características, nos termos da Lei Municipal 1802/1969, artigo 109 e anexo X da Lei Municipal 5.015/2001, atualizada conforme Lei Municipal 6.008/2009.',
        ),
        FaqText(
          'Já o valor venal da construção é calculado levando-se em consideração: área construída, padrão construtivo, valor do m² e ano de conclusão de cada construção, nos termos da Lei Municipal 1.802/1969, artigo 110.',
        ),
        FaqText(
          'A seguir temos um exemplo de cálculo a partir das informações constantes em seu carnê:',
        ),
        FaqImage('assets/image/iptu26.png'),
        FaqText(
          'O exemplo mostrado acima demonstra um imóvel com uso exclusivamente residencial, área de terreno de 27,08 m² e construída de 176,10 m².',
        ),
        FaqText(
          'A base de cálculo, para fins de incidência do IPTU, é o valor venal do imóvel, considerando as características do terreno e da construção, perfazendo um total de R\$ 375.792,94.',
        ),
        FaqText(
          'O exemplo deste imóvel, com valor venal equivalente a R\$ 375.792,94, uso residencial, terá o respectivo IPTU calculado com a aplicação da alíquota de 0,50%. Nesse exemplo, uma vez que o valor venal do imóvel se encontra na segunda faixa de aplicação das alíquotas, com valor a deduzir de R\$ 672,37.',
        ),
        FaqText(
          'Dessa forma, vamos demonstrar o valor calculado de IPTU, a partir do exemplo mostrado acima:',
        ),
      ],
    ),
    //4
    FaqItem(
      pergunta: 'Qual é o desconto para pagamento do IPTU à vista?',
      conteudo: [
        FaqText(
          'O desconto para o pagamento do IPTU em cota única é de 5% (cinco por cento), desde que o pagamento seja realizado de forma integral e até a data de vencimento da primeira parcela.',
        ),
      ],
    ),
    //5
    FaqItem(
      pergunta: 'Como faço a emissão da segunda via do IPTU?',
      conteudo: [
        FaqText(
          'A emissão da segunda via pode ser feita pela internet. Preencha os campos: “Inscrição Imobiliária” e “CPF” ou “CNPJ”.',
        ),
      ],
    ),
    //6
    FaqItem(
      pergunta:
          'Quais os encargos aplicados ao IPTU pago depois do vencimento?',
      conteudo: [
        FaqText(
          'O lançamento pago em atraso tem a incidência de atualização monetária calculada pelo Índice Nacional de Preços ao Consumidor Amplo (IPCA-15), Multa de Mora de 0,16667% ao dia (limitada a 5%), além de juros moratórios de 1% ao mês calculado sobre o débito atualizado monetariamente, inclusive multa de mora.',
        ),
      ],
    ),
    //7
    FaqItem(
      pergunta:
          'Em caso de não pagamento da parcela, quanto tempo leva para meu IPTU ir a cartório?',
      conteudo: [
        FaqText(
          'Após vencida, a parcela do IPTU é inscrita em dívida ativa e encaminhada aos Cartórios de Protesto. O prazo para a inscrição em dívida ativa é de até 90 dias do mês do vencimento, e a cobrança extrajudicial (protesto) ocorre após 150 dias da inscrição em dívida ativa. Após esse prazo, é feito o encaminhamento para execução fiscal (Lei 6.008/2009).',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Por que o IPTU do meu imóvel veio com menos de 12 parcelas?',
      conteudo: [
        FaqText(
          'Apesar de o IPTU puder ser dividido em até 12 parcelas, cada parcela não pode ser menor do que R\$ 59,60.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Como alterar o endereço de correspondência do carnê do IPTU?',
      conteudo: [
        FaqText(
          'A atualização pode ser feita pessoalmente ou através de representante legal em um dos postos da Atende Bem, ou ainda pela Internet.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Como alterar o vencimento do meu IPTU?',
      conteudo: [
        FaqText(
          'A alteração pode ser feita pessoalmente ou através de representante legal em um dos postos da Atende Bem, obedecendo as datas pré determinadas, ou ainda pela Internet.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'Onde posso pagar o IPTU depois de vencido?',
      conteudo: [
        FaqText(
          'Poderão ser pagos durante o horário bancário ou serviços de internet banking em qualquer banco do território nacional. Caso o pagamento ocorra no mês subsequente ao do vencimento, é necessária a emissão de 2ª via com nova data de validade para pagamento.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'O que é o IPTU Premiado?',
      conteudo: [
        FaqText(
          'Pagando o seu IPTU em dia, você recebe prêmios em dinheiro, sendo 12 (doze) prêmios de R\$ 10.000,00 (dez mil reais) através do Programa Incentivo à adimplência - IPTU PREMIADO.',
        ),
      ],
    ),
    FaqItem(
      pergunta: 'O que é o IPTU Digital?',
      conteudo: [
        FaqText(
          'A partir de 2023, existe a opção de receber o seu carnê de IPTU diretamente em seu e-mail.',
        ),
      ],
    ),

    FaqItem(
      pergunta: 'Como faço para alterar o nome do meu IPTU?',
      conteudo: [
        FaqText(
          'Para alterar o nome do IPTU, é necessário realizar o cadastro no site da Prefeitura, informando seu e-mail e optando por receber o carnê digitalmente.',
        ),
      ],
    ),

    FaqItem(
      pergunta:
          'Como solicitar a retificação de informações relativas à área de terreno do imóvel utilizada no cálculo do Imposto Predial e Territorial Urbano (IPTU)?',
      conteudo: [
        FaqText(
          'Necessário formalizar processo administrativo para revisão de área de terreno, acessando o site http://guiadeservicos.saobernardo.sp.gov.br/guia-de-servicos/servicos/211518/mostrar. Siga as orientações para efetuar o agendamento em uma das unidades do Atende Bem e verificar os documentos necessários.',
        ),
      ],
    ),
    FaqItem(
      pergunta:
          'Como solicitar a retificação de informações relativas à área de construção, tipo de utilização do imóvel e alteração de classificação fiscal (tipologia)?',
      conteudo: [
        FaqText(
          'Necessário formalizar processo administrativo para revisão de área construída, acessando o site https://guiadeservicos.saobernardo.sp.gov.br/guia-de-servicos/servicos/211516/mostrar e siga as orientações para efetuar o agendamento em uma das unidades do Atende Bem e verificar os documentos necessários.',
        ),
      ],
    ),
  ];
}
