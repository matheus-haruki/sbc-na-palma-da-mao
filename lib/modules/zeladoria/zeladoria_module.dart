import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/zeladoria_home_page.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/formulario_zeladoria_page.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/zeladoria_acompanhar_page.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/zeladoria_detalhes_page.dart';

class ZeladoriaModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ZeladoriaHomePage());
    r.child('/registrar', child: (context) => const FormularioZeladoriaPage());
    r.child('/acompanhar', child: (context) => const ZeladoriaAcompanharPage());
    r.child(
      '/detalhes',
      child: (context) => ZeladoriaDetalhesPage(solicitacao: r.args.data),
    );
  }
}
