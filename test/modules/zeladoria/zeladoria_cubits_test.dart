import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/modules/zeladoria/models/categoria_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/consulta_solicitacoes_response.dart';
import 'package:palma_da_mao/modules/zeladoria/models/endereco_cep_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/servico_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/solicitacao_detalhe_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/solicitacao_resumo_model.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_consulta_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_consulta_state.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_detalhes_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_detalhes_state.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_form_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/repositories/endereco_repository.dart';
import 'package:palma_da_mao/modules/zeladoria/repositories/zeladoria_repository.dart';

class FakeZeladoriaRepository extends Fake implements ZeladoriaRepository {
  List<CategoriaModel> categoriasMock = [];
  List<ServicoModel> servicosMock = [];
  ConsultaSolicitacoesResponse? consultaMock;
  SolicitacaoDetalheModel? detalheMock;

  @override
  Future<List<CategoriaModel>> listarCategorias() async {
    return categoriasMock;
  }

  @override
  Future<List<ServicoModel>> listarServicosPorCategoria(int categoriaId) async {
    return servicosMock;
  }

  @override
  Future<ConsultaSolicitacoesResponse> consultarSolicitacoes({
    required String cpfMunicipe,
    int page = 0,
    int size = 10,
  }) async {
    return consultaMock ??
        ConsultaSolicitacoesResponse(
          content: [],
          pageNumber: 0,
          pageSize: 10,
          totalElements: 0,
          totalPages: 0,
        );
  }

  @override
  Future<SolicitacaoDetalheModel> consultarDetalheSolicitacao({
    required String cpfMunicipe,
    required String protocolo,
  }) async {
    if (detalheMock != null) return detalheMock!;
    throw Exception('Detalhe não encontrado');
  }

  List<Uint8List> fotosMock = [];

  @override
  Future<List<Uint8List>> buscarFotosSolicitacao({
    required String cpfMunicipe,
    required String protocolo,
    required int quantidadeFotos,
  }) async {
    return fotosMock;
  }
}

class FakeEnderecoRepository extends Fake implements EnderecoRepository {
  EnderecoCepModel? cepMock;
  List<BairroModel> bairrosMock = [];

  @override
  Future<EnderecoCepModel?> consultarCep(String cep) async {
    return cepMock;
  }

  @override
  Future<List<BairroModel>> buscarBairros(String nome) async {
    return bairrosMock;
  }
}

void main() {
  late FakeZeladoriaRepository fakeZeladoriaRepo;
  late FakeEnderecoRepository fakeEnderecoRepo;

  setUp(() {
    fakeZeladoriaRepo = FakeZeladoriaRepository();
    fakeEnderecoRepo = FakeEnderecoRepository();
  });

  group('ZeladoriaFormCubit', () {
    test('carregarCategorias deve atualizar a lista de categorias no estado', () async {
      fakeZeladoriaRepo.categoriasMock = [
        CategoriaModel(categoriaId: 1, nomeCategoria: 'Pavimentação'),
      ];

      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);

      await cubit.carregarCategorias();

      expect(cubit.state.isLoadingCategorias, isFalse);
      expect(cubit.state.categorias.length, 1);
      expect(cubit.state.categorias.first.nomeCategoria, 'Pavimentação');
    });

    test('buscarCep com sucesso deve atualizar enderecoCep no estado', () async {
      fakeEnderecoRepo.cepMock = EnderecoCepModel(
        logradouro: 'Rua Marechal Deodoro',
        bairroId: 10,
        nomeBairro: 'Centro',
      );

      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);

      await cubit.buscarCep('09750000');

      expect(cubit.state.isBuscandoCep, isFalse);
      expect(cubit.state.enderecoCep?.logradouro, 'Rua Marechal Deodoro');
      expect(cubit.state.erroCep, isNull);
    });

    test('buscarCep não encontrado deve definir erroCep como "CEP inválido"', () async {
      fakeEnderecoRepo.cepMock = null;

      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);

      await cubit.buscarCep('00000000');

      expect(cubit.state.isBuscandoCep, isFalse);
      expect(cubit.state.enderecoCep, isNull);
      expect(cubit.state.erroCep, 'CEP inválido');
    });

    test('limparErroCep deve remover erroCep do estado', () async {
      fakeEnderecoRepo.cepMock = null;

      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);

      await cubit.buscarCep('00000000');
      expect(cubit.state.erroCep, 'CEP inválido');

      cubit.limparErroCep();
      expect(cubit.state.erroCep, isNull);
    });

    test('setErroCep deve definir mensagem de erro no estado', () {
      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);
      expect(cubit.state.erroCep, isNull);

      cubit.setErroCep();
      expect(cubit.state.erroCep, 'CEP inválido');
    });

    test('buscarBairros deve atualizar lista de autocomplete de bairros', () async {
      fakeEnderecoRepo.bairrosMock = [
        BairroModel(bairroId: 19, nomeBairro: 'Independência'),
        BairroModel(bairroId: 352, nomeBairro: 'Jardim Independência'),
      ];

      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);

      await cubit.buscarBairros('Independencia');

      expect(cubit.state.isBuscandoBairros, isFalse);
      expect(cubit.state.bairrosAutocomplete.length, 2);
      expect(cubit.state.bairrosAutocomplete.first.nomeBairro, 'Independência');
    });

    test('selecionarCategoria deve resetar servico e carregar lista de servicos', () async {
      fakeZeladoriaRepo.servicosMock = [
        ServicoModel(servicoId: 3, nomeServico: 'Tapa-buraco'),
      ];

      final cubit = ZeladoriaFormCubit(fakeZeladoriaRepo, fakeEnderecoRepo);

      final cat = CategoriaModel(categoriaId: 1, nomeCategoria: 'Vias');
      await cubit.selecionarCategoria(cat);

      expect(cubit.state.categoriaSelecionada, cat);
      expect(cubit.state.servicos.length, 1);
      expect(cubit.state.servicos.first.nomeServico, 'Tapa-buraco');
    });
  });

  group('ZeladoriaConsultaCubit', () {
    test('deve emitir erro quando o CPF informado for inválido', () async {
      final cubit = ZeladoriaConsultaCubit(fakeZeladoriaRepo);

      await cubit.consultarPorCpf('123');
      expect(cubit.state, isA<ZeladoriaConsultaError>());

      await cubit.consultarPorCpf('11111111111');
      expect(cubit.state, isA<ZeladoriaConsultaError>());
    });

    test('deve emitir Success quando a consulta retornar itens', () async {
      fakeZeladoriaRepo.consultaMock = ConsultaSolicitacoesResponse(
        content: [
          SolicitacaoResumoModel(
            protocolo: 'SBC-1011-001',
            nomeServico: 'Tapa-buracos',
            rotuloStatus: 'Em análise',
            incluidoEm: DateTime.now(),
          ),
        ],
        pageNumber: 0,
        pageSize: 10,
        totalElements: 1,
        totalPages: 1,
      );

      final cubit = ZeladoriaConsultaCubit(fakeZeladoriaRepo);

      await cubit.consultarPorCpf('12345678909');

      expect(cubit.state, isA<ZeladoriaConsultaSuccess>());
      final success = cubit.state as ZeladoriaConsultaSuccess;
      expect(success.solicitacoes.length, 1);
      expect(success.solicitacoes.first.protocolo, 'SBC-1011-001');
    });

    test('deve emitir Empty quando a consulta retornar lista vazia (ex: 404 sem solicitacoes)', () async {
      fakeZeladoriaRepo.consultaMock = ConsultaSolicitacoesResponse(
        content: [],
        pageNumber: 0,
        pageSize: 10,
        totalElements: 0,
        totalPages: 0,
      );

      final cubit = ZeladoriaConsultaCubit(fakeZeladoriaRepo);

      await cubit.consultarPorCpf('12345678909');

      expect(cubit.state, isA<ZeladoriaConsultaEmpty>());
    });
  });

  group('ZeladoriaDetalhesCubit', () {
    test('deve emitir Success quando buscar detalhes com sucesso', () async {
      fakeZeladoriaRepo.detalheMock = SolicitacaoDetalheModel(
        protocolo: 'SBC-1011-001',
        nomeServico: 'Tapa-buracos',
        rotuloStatus: 'Em análise',
        incluidoEm: DateTime.now(),
        descricaoOcorrencia: 'Buraco grande',
        logradouroOcorrencia: 'Av Vergueiro',
        numeroOcorrencia: '100',
        bairroOcorrencia: 'Centro',
        cepOcorrencia: '09750000',
        quantidadeFotos: 1,
      );

      final cubit = ZeladoriaDetalhesCubit(fakeZeladoriaRepo);

      await cubit.buscarDetalhes(
        cpfMunicipe: '12345678909',
        protocolo: 'SBC-1011-001',
      );

      expect(cubit.state, isA<ZeladoriaDetalhesSuccess>());
      final success = cubit.state as ZeladoriaDetalhesSuccess;
      expect(success.detalhe.protocolo, 'SBC-1011-001');
      expect(success.detalhe.bairroOcorrencia, 'Centro');
    });

    test('deve buscar e carregar fotos quando quantidadeFotos > 0', () async {
      fakeZeladoriaRepo.detalheMock = SolicitacaoDetalheModel(
        protocolo: 'SBC-1011-002',
        nomeServico: 'Poda de árvore',
        rotuloStatus: 'Em execução',
        incluidoEm: DateTime.now(),
        descricaoOcorrencia: 'Árvore encostando na fiação',
        logradouroOcorrencia: 'Rua Jurubatuba',
        numeroOcorrencia: '500',
        bairroOcorrencia: 'Centro',
        cepOcorrencia: '09750000',
        quantidadeFotos: 2,
      );
      fakeZeladoriaRepo.fotosMock = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ];

      final cubit = ZeladoriaDetalhesCubit(fakeZeladoriaRepo);

      await cubit.buscarDetalhes(
        cpfMunicipe: '12345678909',
        protocolo: 'SBC-1011-002',
      );

      expect(cubit.state, isA<ZeladoriaDetalhesSuccess>());
      final success = cubit.state as ZeladoriaDetalhesSuccess;
      expect(success.fotos.length, 2);
      expect(success.carregandoFotos, isFalse);
    });
  });
}
