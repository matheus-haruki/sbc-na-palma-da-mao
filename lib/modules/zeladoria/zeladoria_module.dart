import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_consulta_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_detalhes_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_form_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/repositories/endereco_repository.dart';
import 'package:palma_da_mao/modules/zeladoria/repositories/zeladoria_repository.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/formulario_zeladoria_page.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/zeladoria_acompanhar_page.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/zeladoria_detalhes_page.dart';
import 'package:palma_da_mao/modules/zeladoria/ui/zeladoria_home_page.dart';

class ZeladoriaModule extends Module {
  @override
  void binds(Injector i) {
    i.add<Dio>(() {
      final dio = Dio();
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
      return dio;
    });

    i.add<EnderecoRepository>(EnderecoRepository.new);
    i.add<ZeladoriaRepository>(ZeladoriaRepository.new);
    i.add<ZeladoriaFormCubit>(ZeladoriaFormCubit.new);
    i.add<ZeladoriaConsultaCubit>(ZeladoriaConsultaCubit.new);
    i.add<ZeladoriaDetalhesCubit>(ZeladoriaDetalhesCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const ZeladoriaHomePage());
    r.child(
      '/registrar',
      child: (context) => const FormularioZeladoriaPage(),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/acompanhar',
      child: (context) => const ZeladoriaAcompanharPage(),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/detalhes',
      child: (context) => ZeladoriaDetalhesPage(solicitacao: r.args.data),
      transition: TransitionType.fadeIn,
    );
  }
}
