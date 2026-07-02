import 'package:flutter_modular/flutter_modular.dart';

import 'presentational/ui/pages/servicos_page.dart';

class ServicosModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ServicosPage());
  }
}
