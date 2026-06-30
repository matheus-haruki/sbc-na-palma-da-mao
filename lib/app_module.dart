import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/home/home_module.dart';
import 'package:palma_da_mao/modules/home/presentational/ui/pages/main_navigation_page.dart';
import 'package:palma_da_mao/modules/mais/mais_module.dart';
import 'package:palma_da_mao/modules/servicos/servicos_module.dart';


class AppModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const MainNavigationPage(),
      children: [
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/servicos', module: ServicosModule()),
        ModuleRoute('/mais', module: MaisModule()),
      ],
    );
  }
}