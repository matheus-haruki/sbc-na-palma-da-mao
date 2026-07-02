import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/splash/presentational/pages/splash_page.dart';

class SplashModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const SplashPage(),
    );
  }
}
 