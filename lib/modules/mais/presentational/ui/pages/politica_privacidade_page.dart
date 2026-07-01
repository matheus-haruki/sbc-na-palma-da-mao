import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';

class PoliticaPrivacidadePage extends StatelessWidget {
  const PoliticaPrivacidadePage({super.key});

  // O HTML simulando a resposta do backend
  static const String _politicaHtml = '''
    <body>
      <h1>Política de Privacidade</h1>
      <p>Acreditamos na importância de construir um relacionamento transparente com o munícipe. Consciente da confiança necessária para armazenar seus dados, a prefeitura municipal de São Bernardo do Campo gostaria de informar quais dados coletamos e o porquê desta necessidade.</p>
      
      <h2>Informações Coletadas:</h2>
      <p>Coletamos as informações, sobretudo, para oferecer um serviço com maior agilidade aos munícipes.</p>
      <p><strong>Criação do Usuário na agenda munícipe:</strong> Ao abrir uma conta, o munícipe fornece informações pessoais como nome, endereço de e-mail, número de telefone e CPF para armazenar com a conta. Esses dados são importantes para conhecermos o perfil dos munícipes que utilizam essa plataforma para melhor atendê-los.</p>
      <p><strong>Função 'Meus Dados Municipais':</strong> A prefeitura disponibiliza uma série de serviços em sua plataforma de forma independente. Sendo assim, é solicitado ao munícipe preencher formulários diferentes de acordo com o serviço desejado nos quais eventualmente as informações se repetem. Com o objetivo de fornecer agilidade ao usuário e contribuir com a desburocratização dos serviços prestados, esta funcionalidade permite que o munícipe salve seus dados no sistema e utilize o preenchimento automático sempre que necessário. Os dados salvos são utilizados apenas na função de autopreenchimento.</p>
      
      <h2>Sigilo das Informações</h2>
      <p>Não compartilhamos as informações de pessoa física ou jurídica com empresas, organizações e indivíduos externos à Prefeitura de São Bernardo do Campo. Salvo em uma das circunstâncias a seguir:</p>
      <ul>
        <li>Por motivos legais.</li>
      </ul>
      <p>Poderemos ceder informações a pessoas, empresas, organizações ou indivíduos externos a Prefeitura Municipal de São Bernardo do Campo com base na confiança e na boa fé do uso, acesso, conservação e divulgação das informações contidas na nossa base de dados desde que tal ação seja imprescindível para:</p>
      <ul>
        <li>Proteger contra danos à propriedade, aos direitos ou a segurança do Município de São Bernardo do Campo, ao público ou aos nossos usuários, conforme permitido por lei ou solicitado.</li>
        <li>Impedir ou detectar alguma forma de fraude que atinja o Município de São Bernardo do Campo ou que atinja as questões de segurança ou técnicas.</li>
        <li>Cumprir legislação, processo legal ou regulamento.</li>
        <li>Cumprir solicitação governamental aplicável.</li>
        <li>Cumprir os Termos de Serviço aplicáveis, inclusive de investigações de possíveis violações.</li>
        <li>Podemos compartilhar informações com nossos parceiros desde que as informações não exponham nenhum usuário publicamente. Exemplo: Divulgar a porcentagem de usuários que utilizam um certo serviço do aplicativo.</li>
        <li>Com autorização expressa do usuário.</li>
      </ul>
      <p>Caso obtenhamos a autorização expressa do usuário, podemos compartilhar informações pessoais com organizações, empresas ou indivíduos externos a Prefeitura Municipal de São Bernardo do Campo.</p>
      <ul>
        <li>Para as informações serem processadas externamente:</li>
      </ul>
      <p style="margin-left: 40px;">Podemos fornecer informações da nossa base de dados para pessoas externas, órgãos e secretária do Município de nossa confiança para processar os dados. Esse processamento será realizado baseado em nossas instruções e na nossa Política de Privacidade vigente.</p>
      
      <h2>Aplicação da Política de Privacidade</h2>
      <p>Nossa Política de Privacidade contempla todos serviços oferecidos no aplicativo "SBC na Palma da Mão" porém exclui serviços que tenham políticas de privacidade próprios mesmo que estes estejam disponíveis no aplicativo.</p>
      
      <h2>Segurança das Informações</h2>
      <p>O Departamento de Tecnologia da Informação do município de São Bernardo do Campo é responsável pelas informações coletadas, armazenadas e processadas do aplicativo "SBC na Palma da Mão" bem como pela segurança das informações transmitidas para a disponibilização dos serviços do aplicativo. O administrador do sistema deverá tomar medidas adequadas, levando em consideração o estado da tecnologia, afim de garantir a integridade e a segurança das informações pessoais contidas no aplicativo, evitando assim qualquer acesso indevido.</p>
      <p>Quando a utilização destas informações é protagonizada por terceiros (empresas ou indivíduos externos a Prefeitura Municipal de São Bernardo do Campo), estes serão inteiramente responsáveis pelas informações.</p>
      <p>Somente os servidores ou prestadores de serviços autorizados pela Prefeitura Municipal de São Bernardo do Campo terão acesso as informações pessoais contidas no aplicativo, e deverão utilizar estas informações por necessidades estritamente ligadas ao seu trabalho.</p>
      
      <h2>Atualizações</h2>
      <p>A Política de Privacidade pode sofrer alterações no perpassar do tempo de acordo com as novas necessidades dos serviços prestados. Havendo alguma alteração da política, o usuário será notificado por e-mail.</p>
    </body>
  ''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppStandardPage(
      title: 'Política de Privacidade',
      // Envolvemos o Html em um SingleChildScrollView nativo para ter a rolagem Bouncing do iOS
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Html(
          data: _politicaHtml,
          // Mapeamento crítico: Forçando as tags HTML a usarem o seu Design System
          style: {
            "body": Style(margin: Margins.zero, padding: HtmlPaddings.all(24)),
            "h1": Style(
              color: colorScheme.primary,
              fontSize: FontSize(theme.textTheme.titleMedium?.fontSize ?? 22),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 16),
            ),
            "h2": Style(
              color: colorScheme.primary,
              fontSize: FontSize(theme.textTheme.titleSmall?.fontSize ?? 16),
              fontWeight: FontWeight.bold,
              margin: Margins.only(top: 24, bottom: 8),
            ),
            "p": Style(
              color: colorScheme.onSurfaceVariant,
              fontSize: FontSize(theme.textTheme.bodySmall?.fontSize ?? 14),
              lineHeight: LineHeight(1.5),
              margin: Margins.only(bottom: 12),
            ),
            "ul": Style(margin: Margins.only(bottom: 12)),
            "li": Style(
              color: colorScheme.onSurfaceVariant,
              fontSize: FontSize(theme.textTheme.bodySmall?.fontSize ?? 14),
              lineHeight: LineHeight(1.5),
              margin: Margins.only(bottom: 8),
            ),
            "strong": Style(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          },
        ),
      ),
    );
  }
}
