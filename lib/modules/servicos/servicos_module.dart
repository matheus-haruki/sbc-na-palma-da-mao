import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/servicos/presentational/ui/pages/animais/adocao_grande_porte_page.dart';
import 'package:palma_da_mao/modules/servicos/presentational/ui/pages/animais/adocao_instrucoes_page.dart';
import 'package:palma_da_mao/modules/servicos/presentational/ui/pages/animais/ocorrencias_animais_page.dart';
import 'package:palma_da_mao/modules/servicos/presentational/ui/pages/iptu/iptu_aposentados_page.dart';
import 'package:palma_da_mao/modules/servicos/presentational/ui/pages/iptu/iptu_duvidas_page.dart';

import 'presentational/ui/pages/servicos_page.dart';

class ServicosModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ServicosPage());
    r.child('/iptu-duvidas', child: (context) => const IptuDuvidasPage());
    r.child(
      '/iptu-aposentados',
      child: (context) => const IptuAposentadosPage(),
    );
    r.child(
      '/ocorrencias-animais',
      child: (context) => const OcorrenciasAnimaisPage(),
    );
    r.child(
      '/adocao-instrucoes',
      child: (context) => const AdocaoInstrucoesPage(),
    );
    r.child('/grande-porte', child: (context) => const AdocaoGrandePortePage());
  }
}
