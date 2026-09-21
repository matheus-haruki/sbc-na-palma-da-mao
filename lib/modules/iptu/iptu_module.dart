import 'dart:io';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_detalhes_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_guia_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/ui/pages/iptu_page.dart';
import 'package:palma_da_mao/modules/iptu/presentational/ui/pages/iptu_detalhes_page.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';

class IptuModule extends Module {
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
    i.add<IptuRepository>(IptuRepository.new);
    i.add<IptuCubit>(IptuCubit.new);
    i.add<IptuDetalhesCubit>(IptuDetalhesCubit.new);
    i.add<IptuGuiaCubit>(IptuGuiaCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const IptuPage());
    r.child('/detalhes', child: (context) => IptuDetalhesPage(lancamento: r.args.data as String));
  }
}
