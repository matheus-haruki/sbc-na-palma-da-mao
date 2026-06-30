import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/mais/presentational/controllers/mais_cubit.dart';
import 'package:palma_da_mao/modules/mais/presentational/ui/pages/fale_conosco_page.dart';
import 'package:palma_da_mao/modules/mais/presentational/ui/pages/mais_page.dart';

class MaisModule extends Module {
  @override
  void binds(Injector i) {
    i.add<MaisCubit>(MaisCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const MaisPage());
    r.child('/fale-conosco', child: (context) => const FaleConoscoPage());
  }
}
