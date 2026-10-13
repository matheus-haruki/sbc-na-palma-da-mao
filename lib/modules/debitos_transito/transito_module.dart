import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_cubit.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_detalhes_cubit.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_guia_cubit.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/ui/pages/transito_page.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/ui/pages/transito_detalhes_page.dart';
import 'package:palma_da_mao/modules/debitos_transito/repositories/transito_repository.dart';

class TransitoModule extends Module {
  @override
  void binds(Injector i) {
    i.add<Dio>(() {
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
      return dio;
    });
    i.add<TransitoRepository>(TransitoRepository.new);
    i.add<TransitoCubit>(TransitoCubit.new);
    i.add<TransitoDetalhesCubit>(TransitoDetalhesCubit.new);
    i.add<TransitoGuiaCubit>(TransitoGuiaCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const TransitoPage());
    r.child('/detalhes', child: (context) => TransitoDetalhesPage(lancamento: r.args.data as String));
  }
}
