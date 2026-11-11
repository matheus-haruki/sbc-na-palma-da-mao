import 'package:palma_da_mao/modules/zeladoria/models/bairro_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/categoria_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/endereco_cep_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/servico_model.dart';

enum FormSubmissionStatus { initial, submitting, success, failure }

class ZeladoriaFormState {
  final bool isLoadingCategorias;
  final List<CategoriaModel> categorias;
  final CategoriaModel? categoriaSelecionada;

  final bool isLoadingServicos;
  final List<ServicoModel> servicos;
  final ServicoModel? servicoSelecionado;

  final bool isBuscandoCep;
  final EnderecoCepModel? enderecoCep;
  final String? erroCep;

  final bool isBuscandoBairros;
  final List<BairroModel> bairrosAutocomplete;
  final BairroModel? bairroSelecionado;

  final FormSubmissionStatus submissionStatus;
  final String? protocoloCriado;
  final String? errorMessage;

  const ZeladoriaFormState({
    this.isLoadingCategorias = false,
    this.categorias = const [],
    this.categoriaSelecionada,
    this.isLoadingServicos = false,
    this.servicos = const [],
    this.servicoSelecionado,
    this.isBuscandoCep = false,
    this.enderecoCep,
    this.erroCep,
    this.isBuscandoBairros = false,
    this.bairrosAutocomplete = const [],
    this.bairroSelecionado,
    this.submissionStatus = FormSubmissionStatus.initial,
    this.protocoloCriado,
    this.errorMessage,
  });

  ZeladoriaFormState copyWith({
    bool? isLoadingCategorias,
    List<CategoriaModel>? categorias,
    CategoriaModel? Function()? categoriaSelecionada,
    bool? isLoadingServicos,
    List<ServicoModel>? servicos,
    ServicoModel? Function()? servicoSelecionado,
    bool? isBuscandoCep,
    EnderecoCepModel? Function()? enderecoCep,
    String? Function()? erroCep,
    bool? isBuscandoBairros,
    List<BairroModel>? bairrosAutocomplete,
    BairroModel? Function()? bairroSelecionado,
    FormSubmissionStatus? submissionStatus,
    String? Function()? protocoloCriado,
    String? Function()? errorMessage,
  }) {
    return ZeladoriaFormState(
      isLoadingCategorias: isLoadingCategorias ?? this.isLoadingCategorias,
      categorias: categorias ?? this.categorias,
      categoriaSelecionada: categoriaSelecionada != null
          ? categoriaSelecionada()
          : this.categoriaSelecionada,
      isLoadingServicos: isLoadingServicos ?? this.isLoadingServicos,
      servicos: servicos ?? this.servicos,
      servicoSelecionado: servicoSelecionado != null
          ? servicoSelecionado()
          : this.servicoSelecionado,
      isBuscandoCep: isBuscandoCep ?? this.isBuscandoCep,
      enderecoCep: enderecoCep != null ? enderecoCep() : this.enderecoCep,
      erroCep: erroCep != null ? erroCep() : this.erroCep,
      isBuscandoBairros: isBuscandoBairros ?? this.isBuscandoBairros,
      bairrosAutocomplete: bairrosAutocomplete ?? this.bairrosAutocomplete,
      bairroSelecionado: bairroSelecionado != null
          ? bairroSelecionado()
          : this.bairroSelecionado,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      protocoloCriado: protocoloCriado != null
          ? protocoloCriado()
          : this.protocoloCriado,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
