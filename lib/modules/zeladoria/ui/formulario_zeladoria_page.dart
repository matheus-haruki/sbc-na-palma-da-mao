import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/components/cpf_text_field.dart';
import 'package:palma_da_mao/core/components/app_input_container.dart';
import 'package:flutter/services.dart';

class FormularioZeladoriaPage extends StatefulWidget {
  const FormularioZeladoriaPage({super.key});

  @override
  State<FormularioZeladoriaPage> createState() =>
      _FormularioZeladoriaPageState();
}

class _FormularioZeladoriaPageState extends State<FormularioZeladoriaPage> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  int? _categoriaId;
  final List<XFile> _fotos = [];
  bool _isLoading = false;

  Map<int, String> _categorias = {};
  bool _isLoadingCategorias = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final response = await Supabase.instance.client
          .from('categorias')
          .select('id, nome')
          .order('id', ascending: true);
      final Map<int, String> categoriasCarregadas = {};
      for (var row in response) {
        categoriasCarregadas[row['id'] as int] = row['nome'] as String;
      }
      if (mounted) {
        setState(() {
          _categorias = categoriasCarregadas;
          _isLoadingCategorias = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategorias = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _capturarLocalizacao(void Function(Position) onSucesso) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
    }

    final position = await Geolocator.getCurrentPosition();
    onSucesso(position);
  }

  Future<void> _selecionarFotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _fotos.addAll(pickedFiles);
        if (_fotos.length > 3) {
          _fotos.removeRange(3, _fotos.length); // Limita a 3 fotos
        }
      });
    }
  }

  Future<List<String>> _uploadFotos() async {
    final supabase = Supabase.instance.client;
    List<String> urls = [];

    for (var foto in _fotos) {
      final file = File(foto.path);
      final fileExt = foto.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_cpfController.text}.$fileExt';
      final path = 'solicitacoes/$fileName';

      await supabase.storage.from('zeladoria-fotos').upload(path, file);

      final publicUrl = supabase.storage
          .from('zeladoria-fotos')
          .getPublicUrl(path);
      urls.add(publicUrl);
    }

    return urls;
  }

  Future<void> _enviarSolicitacao() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma categoria.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Passo 1: Localização
      Position? position;
      await _capturarLocalizacao((pos) => position = pos);

      // Passo 2: Upload das fotos
      final urlsFotos = await _uploadFotos();

      // Passo 3: Inserir no Supabase e recuperar protocolo
      final response = await Supabase.instance.client
          .from('solicitacoes')
          .insert({
            'cpf_usuario': _cpfController.text.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            ),
            'categoria_id': _categoriaId,
            'titulo': _tituloController.text,
            'descricao': _descricaoController.text,
            'latitude': position!.latitude,
            'longitude': position!.longitude,
            'fotos': urlsFotos,
          })
          .select('protocolo')
          .single();

      final protocolo = response['protocolo'];

      // Sucesso!
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Solicitação Enviada!'),
            content: Text(
              'Seu protocolo de atendimento é:\n\n$protocolo\n\nAguarde o andamento da análise.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _limparFormulario();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limparFormulario() {
    _cpfController.clear();
    _tituloController.clear();
    _descricaoController.clear();
    setState(() {
      _categoriaId = null;
      _fotos.clear();
    });
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
    return AppStandardPage(
      title: 'Zeladoria',
      body: SingleChildScrollView(
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

              _buildLabel('CPF do Solicitante'),
              CpfTextField(controller: _cpfController),
              const SizedBox(height: 16),

              _buildLabel('Categoria do Problema'),
              AppInputContainer(
                child: DropdownMenu<int>(
                  initialSelection: _categoriaId,
                  expandedInsets: EdgeInsets.zero,
                  hintText: _isLoadingCategorias
                      ? 'Carregando categorias...'
                      : 'Selecione uma categoria',
                  textStyle: const TextStyle(fontSize: 16),
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  menuStyle: MenuStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  dropdownMenuEntries: _isLoadingCategorias
                      ? []
                      : _categorias.entries.map((e) {
                          return DropdownMenuEntry<int>(
                            value: e.key,
                            label: e.value,
                          );
                        }).toList(),
                  onSelected: _isLoadingCategorias
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() => _categoriaId = val);
                          }
                        },
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Título'),
              AppInputContainer(
                child: TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Buraco na via',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Informe um título' : null,
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Descrição detalhada'),
              AppInputContainer(
                child: TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    hintText: 'Explique o problema detalhadamente...',
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 4,
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Descreva o problema'
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Fotos (Até 3)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
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
                            onTap: () => setState(() => _fotos.remove(foto)),
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
                      onTap: _selecionarFotos,
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

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enviarSolicitacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar Solicitação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
