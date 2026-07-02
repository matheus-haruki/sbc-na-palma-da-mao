import 'package:flutter_modular/flutter_modular.dart';
import 'presentational/controllers/home_cubit.dart';
import 'presentational/ui/pages/home_page.dart';
// ADICIONE ESTE IMPORT
import 'presentational/ui/pages/categoria_detalhe_page.dart'; 

class HomeModule extends Module {
  @override
  void binds(Injector i) {
    i.add<HomeCubit>(HomeCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const HomePage());
    
    r.child('/categoria', child: (context) => CategoriaDetalhePage(
      titulo: r.args.data['titulo'],
      idCategoria: r.args.data['idCategoria'],
    ));
  }
}