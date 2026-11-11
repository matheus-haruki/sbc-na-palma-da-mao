import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/components/app_success_modal.dart';
import 'package:palma_da_mao/core/components/app_text_field.dart';
import 'package:palma_da_mao/core/components/cpf_text_field.dart';
import 'package:palma_da_mao/core/components/keyboard_done_accessory.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/modules/zeladoria/models/categoria_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/nova_solicitacao_dto.dart';
import 'package:palma_da_mao/modules/zeladoria/models/servico_model.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_form_cubit.dart';
import 'package:palma_da_mao/modules/zeladoria/presentational/controllers/zeladoria_form_state.dart';

class FormularioZeladoriaPage extends StatefulWidget {
  const FormularioZeladoriaPage({super.key});

  @override
  State<FormularioZeladoriaPage> createState() =>
      _FormularioZeladoriaPageState();
}

class _FormularioZeladoriaPageState extends State<FormularioZeladoriaPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _celularController = TextEditingController();

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _servicoController = TextEditingController();
  int? _bairroId;
  String? _ultimoCepBuscado;
  bool _isFetchingGps = false;

  final _descricaoController = TextEditingController();
  final FocusNode _cpfFocusNode = FocusNode();
  final FocusNode _celularFocusNode = FocusNode();
  final FocusNode _cepFocusNode = FocusNode();
  final FocusNode _numeroFocusNode = FocusNode();

  final _celularFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final GlobalKey _categoriaKey = GlobalKey();
  final GlobalKey _servicoKey = GlobalKey();
  final GlobalKey _bairroKey = GlobalKey();
  final GlobalKey _descricaoKey = GlobalKey();

  final List<XFile> _fotos = [];

  late final ZeladoriaFormCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<ZeladoriaFormCubit>();
    _cubit.carregarCategorias();
    _cepController.addListener(_handleCepControllerChanged);
    _cepFocusNode.addListener(_handleCepFocusChanged);
  }

  @override
  void dispose() {
    _cepController.removeListener(_handleCepControllerChanged);
    _cepFocusNode.removeListener(_handleCepFocusChanged);
    _nomeController.dispose();
    _cpfController.dispose();
    _celularController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _categoriaController.dispose();
    _servicoController.dispose();
    _descricaoController.dispose();
    _cpfFocusNode.dispose();
    _celularFocusNode.dispose();
    _cepFocusNode.dispose();
    _numeroFocusNode.dispose();
    super.dispose();
  }

  void _handleCepFocusChanged() {
    if (!_cepFocusNode.hasFocus) {
      final cepLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (cepLimpo.isNotEmpty && cepLimpo.length < 8) {
        _cubit.setErroCep('CEP inválido');
      }
    }
  }

  void _handleCepControllerChanged() {
    final cepLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (_cubit.state.erroCep != null) {
      _cubit.limparErroCep();
    }
    if (cepLimpo.length == 8 && cepLimpo != _ultimoCepBuscado) {
      _ultimoCepBuscado = cepLimpo;
      _cubit.buscarCep(cepLimpo);
    }
  }

  void _buscarCepManual() {
    final cepLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length == 8) {
      FocusScope.of(context).unfocus();
      _ultimoCepBuscado = cepLimpo;
      _cubit.buscarCep(cepLimpo);
    } else if (cepLimpo.isNotEmpty) {
      _cubit.setErroCep('CEP inválido');
    }
  }

  Future<void> _obterEnderecoPorGps() async {
    FocusScope.of(context).unfocus();
    setState(() => _isFetchingGps = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização/GPS está desativado.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão de localização negada permanentemente nas configurações.',
        );
      }

      final position = await Geolocator.getCurrentPosition();

      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 1. CEP: Se identificou, preenche e busca dados oficiais na prefeitura
        final rawPostalCode =
            place.postalCode?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
        if (rawPostalCode.length == 8) {
          _cepController.text =
              '${rawPostalCode.substring(0, 5)}-${rawPostalCode.substring(5, 8)}';
          _ultimoCepBuscado = rawPostalCode;
          await _cubit.buscarCep(rawPostalCode);
        }

        // 2. Logradouro (rua/avenida)
        final rua = place.thoroughfare ?? place.street ?? '';
        if (rua.isNotEmpty) {
          _logradouroController.text = rua;
        }

        // 3. Número
        if (place.subThoroughfare != null &&
            place.subThoroughfare!.trim().isNotEmpty) {
          _numeroController.text = place.subThoroughfare!;
        }

        // 4. Bairro
        final bairroGps = place.subLocality ?? '';
        if (bairroGps.isNotEmpty) {
          _bairroController.text = bairroGps;
          await _cubit.buscarBairros(bairroGps);
          if (_cubit.state.bairrosAutocomplete.isNotEmpty) {
            final correspondente = _cubit.state.bairrosAutocomplete.firstWhere(
              (b) => b.nomeBairro.toLowerCase() == bairroGps.toLowerCase(),
              orElse: () => _cubit.state.bairrosAutocomplete.first,
            );
            _bairroId = correspondente.bairroId;
            _cubit.selecionarBairro(correspondente);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Endereço preenchido via localização atual!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception(
          'Não foi possível identificar o endereço para este local.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingGps = false);
      }
    }
  }

  void _abrirSelecaoBairro() {
    FocusManager.instance.primaryFocus?.unfocus();

    // Dispara busca inicial se o campo já tiver algo ou limpa para nova busca
    final termoInicial = _bairroController.text.trim();
    if (termoInicial.isNotEmpty) {
      _cubit.buscarBairros(termoInicial);
    } else {
      _cubit.buscarBairros('');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        final searchController = TextEditingController(text: termoInicial);
        Timer? debounce;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final mediaQuery = MediaQuery.of(context);
            final modalHeight = mediaQuery.size.height * 0.85;

            return SizedBox(
              height: modalHeight,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: mediaQuery.viewInsets.bottom,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selecione o Bairro',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkBlue,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AppTextField(
                          controller: searchController,
                          hintText: 'Digite o bairro',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          onChanged: (query) {
                            debounce?.cancel();
                            debounce =
                                Timer(const Duration(milliseconds: 350), () {
                              _cubit.buscarBairros(query);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      Expanded(
                        child:
                            BlocBuilder<ZeladoriaFormCubit, ZeladoriaFormState>(
                          bloc: _cubit,
                          builder: (context, state) {
                            if (state.isBuscandoBairros) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state.bairrosAutocomplete.isEmpty) {
                              return Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    searchController.text.trim().isEmpty
                                        ? 'Digite o nome do bairro acima para pesquisar.'
                                        : 'Nenhum bairro encontrado para "${searchController.text}".',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: state.bairrosAutocomplete.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final bairro = state.bairrosAutocomplete[index];
                                final isSelected = _bairroId == bairro.bairroId;

                                return ListTile(
                                  title: Text(
                                    bairro.nomeBairro,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _bairroId = bairro.bairroId;
                                      _bairroController.text =
                                          bairro.nomeBairro;
                                    });
                                    _cubit.selecionarBairro(bairro);
                                    Navigator.pop(modalContext);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _abrirSelecaoCategoria(List<CategoriaModel> categorias) {
    FocusManager.instance.primaryFocus?.unfocus();

    final ctx = _categoriaKey.currentContext;
    if (ctx != null && ctx.mounted) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Selecione uma categoria',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final item = categorias[index];
                      final isSelected =
                          _cubit.state.categoriaSelecionada?.categoriaId ==
                              item.categoriaId;

                      return ListTile(
                        title: Text(
                          item.nomeCategoria,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          _cubit.selecionarCategoria(item);
                          _categoriaController.text = item.nomeCategoria;
                          _servicoController.clear();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _abrirSelecaoServico(List<ServicoModel> servicos) {
    FocusScope.of(context).unfocus();

    if (_cubit.state.categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione primeiro uma categoria.')),
      );
      return;
    }

    if (servicos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum serviço disponível para esta categoria.'),
        ),
      );
      return;
    }

    final ctx = _servicoKey.currentContext;
    if (ctx != null && ctx.mounted) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Selecione o serviço',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: servicos.length,
                    itemBuilder: (context, index) {
                      final item = servicos[index];
                      final isSelected =
                          _cubit.state.servicoSelecionado?.servicoId ==
                              item.servicoId;

                      return ListTile(
                        title: Text(
                          item.nomeServico,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          _cubit.selecionarServico(item);
                          _servicoController.text = item.nomeServico;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Future<void> _abrirOpcoesDeFoto() async {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _tirarFotoCamera();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarFotosGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tirarFotoCamera() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _fotos.add(pickedFile);
        if (_fotos.length > 3) {
          _fotos.removeRange(3, _fotos.length);
        }
      });
    }
  }

  Future<void> _selecionarFotosGaleria() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _fotos.addAll(pickedFiles);
        if (_fotos.length > 3) {
          _fotos.removeRange(3, _fotos.length);
        }
      });
    }
  }

  void _enviarSolicitacao() {
    if (!_formKey.currentState!.validate()) return;

    final state = _cubit.state;

    if (state.categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria.')),
      );
      return;
    }

    if (state.servicoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um serviço.')),
      );
      return;
    }

    final bairroIdFinal = _bairroId ??
        state.bairroSelecionado?.bairroId ??
        state.enderecoCep?.bairroId;

    if (bairroIdFinal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o bairro na lista.'),
        ),
      );
      return;
    }

    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, anexe pelo menos 1 foto como evidência (de 1 a 3 fotos).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // O CEP é opcional. Se for inválido ou não pertencer a SBC, enviamos null no payload.
    final cepLimpo = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final bool isCepValido = cepLimpo.length == 8 &&
        state.erroCep == null &&
        state.enderecoCep != null;
    final String? cepFinal = isCepValido ? cepLimpo : null;

    final dto = NovaSolicitacaoDto(
      bairroId: bairroIdFinal,
      descricaoOcorrencia: _descricaoController.text.trim(),
      cepOcorrencia: cepFinal,
      logradouroOcorrencia: _logradouroController.text.trim(),
      celularMunicipe: _celularController.text.trim(),
      numeroOcorrencia: _numeroController.text.trim(),
      cpfMunicipe: _cpfController.text.trim(),
      nomeMunicipe: _nomeController.text.trim(),
      servicoId: state.servicoSelecionado!.servicoId,
    );

    final arquivosFotos = _fotos.map((f) => File(f.path)).toList();

    _cubit.enviarSolicitacao(
      solicitacao: dto,
      fotos: arquivosFotos,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ZeladoriaFormCubit, ZeladoriaFormState>(
        listener: (context, state) {
          if (state.categoriaSelecionada != null &&
              _categoriaController.text !=
                  state.categoriaSelecionada!.nomeCategoria) {
            _categoriaController.text =
                state.categoriaSelecionada!.nomeCategoria;
          }
          if (state.servicoSelecionado != null &&
              _servicoController.text !=
                  state.servicoSelecionado!.nomeServico) {
            _servicoController.text = state.servicoSelecionado!.nomeServico;
          }

          if (state.enderecoCep != null) {
            _logradouroController.text = state.enderecoCep!.logradouro;
            _bairroController.text = state.enderecoCep!.nomeBairro;
            _bairroId = state.enderecoCep!.bairroId;
            _numeroFocusNode.requestFocus();
          }

          if (state.submissionStatus == FormSubmissionStatus.success &&
              state.protocoloCriado != null) {
            AppSuccessModal.show(
              context,
              title: 'Solicitação Enviada!',
              message:
                  'Sua solicitação foi registrada com sucesso. Anote o número do seu protocolo:',
              highlightedText: state.protocoloCriado!,
              bottomMessage: 'Aguarde o andamento da análise.',
              onPressed: () {
                _cubit.resetSubmissionStatus();
                Navigator.pop(context);
              },
            );
          }

          if (state.submissionStatus == FormSubmissionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao enviar: ${state.errorMessage!}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting =
              state.submissionStatus == FormSubmissionStatus.submitting;
          final isCepPreenchido =
              _cepController.text.replaceAll(RegExp(r'[^0-9]'), '').length ==
                      8 ||
                  _logradouroController.text.isNotEmpty;

          return AppStandardPage(
            title: 'Zeladoria',
            body: KeyboardDoneAccessory(
              focusNodes: [
                _cpfFocusNode,
                _celularFocusNode,
                _cepFocusNode,
                _numeroFocusNode,
              ],
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Registre um problema na cidade',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nome do Munícipe
                      _buildLabel('Nome Completo'),
                      AppTextField(
                        controller: _nomeController,
                        hintText: 'Digite seu nome completo',
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Informe o seu nome';
                          }
                          if (val.trim().length < 3) {
                            return 'Nome muito curto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CPF do Solicitante
                      _buildLabel('CPF do Solicitante'),
                      CpfTextField(
                        controller: _cpfController,
                        focusNode: _cpfFocusNode,
                      ),
                      const SizedBox(height: 16),

                      // Celular (WhatsApp)
                      _buildLabel('Celular (WhatsApp)'),
                      AppTextField(
                        controller: _celularController,
                        focusNode: _celularFocusNode,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_celularFormatter],
                        hintText: '(11) 99999-9999',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Informe o celular';
                          }
                          if (val.length < 14) {
                            return 'Informe um celular válido';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          'Este número será utilizado para enviar o protocolo e as atualizações de status.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildLabel('Endereço da Ocorrência'),
                      const SizedBox(height: 2),

                      // CEP com botão de GPS ao lado
                      _buildLabel('CEP (Opcional)'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _cepController,
                              focusNode: _cepFocusNode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cepFormatter],
                              hintText: '00000-000',
                              customErrorText: state.erroCep,
                              suffixIcon: state.isBuscandoCep
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: _buscarCepManual,
                                      child: const Icon(
                                        Icons.search,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _isFetchingGps ? null : _obterEnderecoPorGps,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _isFetchingGps
                                  ? const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.location_on_sharp,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bairro Dropdown com Autocomplete
                      _buildLabel('Bairro'),
                      AppTextField(
                        key: _bairroKey,
                        controller: _bairroController,
                        readOnly: true,
                        hintText: 'Selecione o bairro',
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        onTap: _abrirSelecaoBairro,
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Selecione o bairro'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Logradouro
                      _buildLabel('Logradouro (Rua / Avenida)'),
                      AppTextField(
                        controller: _logradouroController,
                        hintText: 'Ex: Rua das Flores',
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Informe o logradouro'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Número
                      _buildLabel('Número'),
                      AppTextField(
                        focusNode: _numeroFocusNode,
                        controller: _numeroController,
                        keyboardType: TextInputType.text,
                        enabled: isCepPreenchido,
                        hintText: isCepPreenchido ? 'Ex: 1200' : 'Ex: 1200',
                        validator: (val) {
                          if (isCepPreenchido &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Informe o nº';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Categoria
                      _buildLabel('Categoria'),
                      AppTextField(
                        key: _categoriaKey,
                        controller: _categoriaController,
                        readOnly: true,
                        hintText: state.isLoadingCategorias
                            ? 'Carregando categorias...'
                            : 'Selecione uma categoria',
                        suffixIcon: state.isLoadingCategorias
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                        onTap: state.isLoadingCategorias
                            ? null
                            : () => _abrirSelecaoCategoria(state.categorias),
                        validator: (val) => state.categoriaSelecionada == null
                            ? 'Selecione uma categoria'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Serviço
                      _buildLabel('Serviço'),
                      AppTextField(
                        key: _servicoKey,
                        controller: _servicoController,
                        readOnly: true,
                        hintText: state.categoriaSelecionada == null
                            ? 'Selecione a categoria primeiro'
                            : (state.isLoadingServicos
                                ? 'Carregando serviços...'
                                : 'Selecione o serviço'),
                        suffixIcon: state.isLoadingServicos
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                        onTap: (state.categoriaSelecionada == null ||
                                state.isLoadingServicos)
                            ? null
                            : () => _abrirSelecaoServico(state.servicos),
                        validator: (val) => state.servicoSelecionado == null
                            ? 'Selecione um serviço'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      _buildLabel('Descrição detalhada'),
                      AppTextField(
                        key: _descricaoKey,
                        controller: _descricaoController,
                        hintText: 'Explique o problema detalhadamente...',
                        alignLabelWithHint: true,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        onTap: () {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (!mounted) return;
                            final ctx = _descricaoKey.currentContext;
                            if (ctx != null && ctx.mounted) {
                              Scrollable.ensureVisible(
                                ctx,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: 0.2,
                              );
                            }
                          });
                        },
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Descreva o problema'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Fotos (1 a 3 fotos)
                      _buildLabel('Fotos (até 3)'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._fotos.map((foto) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(foto.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _fotos.remove(foto)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_fotos.length < 3)
                            InkWell(
                              onTap: _abrirOpcoesDeFoto,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Botão de Envio
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _enviarSolicitacao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Enviar Solicitação',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}
