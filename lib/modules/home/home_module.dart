import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:palma_da_mao/core/network/dio_adapter.dart';
import 'package:palma_da_mao/core/network/http_client.dart';
import 'package:palma_da_mao/modules/mais/presentational/ui/pages/fale_conosco_page.dart';
import 'presentational/controllers/home_cubit.dart';
import 'presentational/ui/pages/home_page.dart';
import 'presentational/ui/pages/categoria_detalhe_page.dart';
import 'presentational/ui/pages/vacinacao_page.dart';
import 'repositories/vacinacao_repository.dart';
import 'presentational/controllers/vacinacao_cubit.dart';

class HomeModule extends Module {
  @override
  void binds(Injector i) {
    i.add<HomeCubit>(HomeCubit.new);
    i.add<Dio>(() {
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          // Aceita certificados de homologação (self-signed ou cadeias incompletas)
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
      return dio;
    });
    i.add<IHttpClient>(DioAdapter.new);
    i.add<VacinacaoRepository>(VacinacaoRepository.new);
    i.add<VacinacaoCubit>(VacinacaoCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const HomePage());
    r.child('/fale-conosco', child: (context) => const FaleConoscoPage());
    r.child('/vacinacao', child: (context) => const VacinacaoPage());

    r.child(
      '/categoria',
      child: (context) => CategoriaDetalhePage(
        titulo: r.args.data['titulo'],
        idCategoria: r.args.data['idCategoria'],
      ),
    );
  }
}
