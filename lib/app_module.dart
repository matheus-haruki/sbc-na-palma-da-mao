import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/chat/chat_module.dart';
import 'package:palma_da_mao/modules/home/home_module.dart';
import 'package:palma_da_mao/modules/home/presentational/ui/pages/main_navigation_page.dart';
import 'package:palma_da_mao/modules/iptu/iptu_module.dart';
import 'package:palma_da_mao/modules/mais/mais_module.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_cubit.dart';
import 'package:palma_da_mao/modules/servicos/servicos_module.dart';
import 'package:palma_da_mao/modules/splash/splash_module.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<ServicosCubit>(ServicosCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.module('/', module: SplashModule());

    r.child(
      '/main',
      child: (context) => const MainNavigationPage(),
      children: [
        ModuleRoute('/home', module: HomeModule()),
        ModuleRoute('/servicos', module: ServicosModule()),
        ModuleRoute('/mais', module: MaisModule()),
      ],
    );
    r.module('/chat', module: ChatModule());
    r.module('/iptu', module: IptuModule());
  }
}
