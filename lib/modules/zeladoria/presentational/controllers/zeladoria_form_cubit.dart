import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/cpf_validator.dart';
import '../../models/bairro_model.dart';
import '../../models/categoria_model.dart';
import '../../models/nova_solicitacao_dto.dart';
import '../../models/servico_model.dart';
import '../../repositories/endereco_repository.dart';
import '../../repositories/zeladoria_repository.dart';
import 'zeladoria_form_state.dart';

class ZeladoriaFormCubit extends Cubit<ZeladoriaFormState> {
  final ZeladoriaRepository _zeladoriaRepository;
  final EnderecoRepository _enderecoRepository;

  ZeladoriaFormCubit(this._zeladoriaRepository, this._enderecoRepository)
      : super(const ZeladoriaFormState());

  /// Carrega as categorias ativas no backend Spring
  Future<void> carregarCategorias() async {
    emit(state.copyWith(isLoadingCategorias: true, errorMessage: () => null));

    try {
      final categorias = await _zeladoriaRepository.listarCategorias();
      emit(
        state.copyWith(
          isLoadingCategorias: false,
          categorias: categorias,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingCategorias: false,
          errorMessage: () => e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Seleciona uma categoria e busca seus serviços vinculados
  Future<void> selecionarCategoria(CategoriaModel categoria) async {
    emit(
      state.copyWith(
        categoriaSelecionada: () => categoria,
        servicoSelecionado: () => null,
        servicos: [],
        isLoadingServicos: true,
      ),
    );

    try {
      final servicos = await _zeladoriaRepository.listarServicosPorCategoria(
        categoria.categoriaId,
      );
      emit(
        state.copyWith(
          isLoadingServicos: false,
          servicos: servicos,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingServicos: false,
          errorMessage: () => e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Seleciona um serviço
  void selecionarServico(ServicoModel servico) {
    emit(state.copyWith(servicoSelecionado: () => servico));
  }

  /// Busca endereço por CEP (8 dígitos)
  Future<void> buscarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return;

    emit(
      state.copyWith(
        isBuscandoCep: true,
        erroCep: () => null,
      ),
    );

    try {
      final endereco = await _enderecoRepository.consultarCep(cepLimpo);
      if (endereco != null) {
        emit(
          state.copyWith(
            isBuscandoCep: false,
            enderecoCep: () => endereco,
            erroCep: () => null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isBuscandoCep: false,
            enderecoCep: () => null,
            erroCep: () => 'CEP inválido',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isBuscandoCep: false,
          enderecoCep: () => null,
          erroCep: () => 'CEP inválido',
        ),
      );
    }
  }

  /// Limpa erro de CEP caso o usuário altere a digitação
  void limparErroCep() {
    if (state.erroCep != null) {
      emit(state.copyWith(erroCep: () => null));
    }
  }

  /// Define erro de CEP (ex: digitação incompleta ou inválida)
  void setErroCep([String erro = 'CEP inválido']) {
    emit(state.copyWith(erroCep: () => erro));
  }

  /// Busca bairros por nome para o autocomplete/dropdown
  Future<void> buscarBairros(String nome) async {
    emit(state.copyWith(isBuscandoBairros: true));
    try {
      final bairros = await _enderecoRepository.buscarBairros(nome.trim());
      emit(
        state.copyWith(
          isBuscandoBairros: false,
          bairrosAutocomplete: bairros,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isBuscandoBairros: false, bairrosAutocomplete: []));
    }
  }

  /// Seleciona um bairro manualmente no dropdown/autocomplete
  void selecionarBairro(BairroModel bairro) {
    emit(state.copyWith(bairroSelecionado: () => bairro));
  }

  /// Envia a solicitação com fotos para o backend Spring
  Future<void> enviarSolicitacao({
    required NovaSolicitacaoDto solicitacao,
    required List<File> fotos,
  }) async {
    final cpfLimpo = solicitacao.cpfMunicipe.replaceAll(RegExp(r'[^0-9]'), '');
    if (!CpfValidator.isValid(cpfLimpo)) {
      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.failure,
          errorMessage: () => 'CPF do solicitante inválido.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submissionStatus: FormSubmissionStatus.submitting,
        errorMessage: () => null,
      ),
    );

    try {
      final protocolo = await _zeladoriaRepository.enviarSolicitacao(
        solicitacao: solicitacao,
        fotos: fotos,
      );

      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.success,
          protocoloCriado: () => protocolo,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.failure,
          errorMessage: () => e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  /// Reseta o status de submissão (usado ao fechar modais)
  void resetSubmissionStatus() {
    emit(
      state.copyWith(
        submissionStatus: FormSubmissionStatus.initial,
        protocoloCriado: () => null,
        errorMessage: () => null,
      ),
    );
  }
}
