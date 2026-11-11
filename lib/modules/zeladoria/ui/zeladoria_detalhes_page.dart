import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:palma_da_mao/core/components/app_input_container.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import '../models/solicitacao_detalhe_model.dart';
import '../presentational/controllers/zeladoria_detalhes_cubit.dart';
import '../presentational/controllers/zeladoria_detalhes_state.dart';

class ZeladoriaDetalhesPage extends StatefulWidget {
  final dynamic solicitacao;

  const ZeladoriaDetalhesPage({super.key, required this.solicitacao});

  @override
  State<ZeladoriaDetalhesPage> createState() => _ZeladoriaDetalhesPageState();
}

class _ZeladoriaDetalhesPageState extends State<ZeladoriaDetalhesPage> {
  late final ZeladoriaDetalhesCubit _cubit;
  late final String _protocolo;
  late final String _cpf;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<ZeladoriaDetalhesCubit>();

    if (widget.solicitacao is Map) {
      _protocolo = widget.solicitacao['protocolo']?.toString() ?? '';
      _cpf = widget.solicitacao['cpf']?.toString() ?? '';
    } else if (widget.solicitacao is SolicitacaoDetalheModel) {
      final model = widget.solicitacao as SolicitacaoDetalheModel;
      _protocolo = model.protocolo;
      _cpf = '';
    } else {
      _protocolo = '';
      _cpf = '';
    }

    if (_protocolo.isNotEmpty) {
      _cubit.buscarDetalhes(cpfMunicipe: _cpf, protocolo: _protocolo);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'em análise':
      case 'em analise':
        return Colors.orange;
      case 'encaminhada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      case 'em execução':
      case 'em execucao':
        return Colors.purple;
      case 'concluída':
      case 'concluida':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
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

  Widget _buildReadOnlyField(String value, {int maxLines = 1}) {
    return AppInputContainer(
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        canRequestFocus: false,
        enableInteractiveSelection: true,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  void _abrirVisualizadorFoto(Uint8List fotoBytes, int numero) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.memory(
                    fotoBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Foto $numero de evidência',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AppStandardPage(
        title: 'Detalhes da Solicitação',
        body: BlocBuilder<ZeladoriaDetalhesCubit, ZeladoriaDetalhesState>(
          builder: (context, state) {
            if (state is ZeladoriaDetalhesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ZeladoriaDetalhesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _cubit.buscarDetalhes(
                          cpfMunicipe: _cpf,
                          protocolo: _protocolo,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ZeladoriaDetalhesSuccess) {
              final detalhe = state.detalhe;
              final statusColor = _getStatusColor(detalhe.rotuloStatus);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Protocolo e Status Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Protocolo',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: detalhe.protocolo),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Protocolo copiado!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    detalhe.protocolo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Courier',
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            detalhe.rotuloStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mensagem pública da Prefeitura (se houver)
                    if (detalhe.mensagemPublica != null &&
                        detalhe.mensagemPublica!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.secondary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Posicionamento da Prefeitura',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detalhe.mensagemPublica!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Data de Registro
                    _buildLabel('Data de Registro'),
                    _buildReadOnlyField(_formatarData(detalhe.incluidoEm)),
                    const SizedBox(height: 16),

                    // Serviço
                    _buildLabel('Serviço'),
                    _buildReadOnlyField(detalhe.nomeServico),
                    const SizedBox(height: 16),

                    // Endereço Completo
                    _buildLabel('Endereço do Local'),
                    _buildReadOnlyField(
                      '${detalhe.logradouroOcorrencia}, nº ${detalhe.numeroOcorrencia} - ${detalhe.bairroOcorrencia}\nCEP: ${detalhe.cepOcorrencia}',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    _buildLabel('Descrição detalhada'),
                    _buildReadOnlyField(
                      detalhe.descricaoOcorrencia,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // Fotos de Evidência
                    if (detalhe.quantidadeFotos > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Fotos de Evidência'),
                          Text(
                            '${state.fotos.isNotEmpty ? state.fotos.length : detalhe.quantidadeFotos} ${detalhe.quantidadeFotos == 1 ? "foto anexada" : "fotos anexadas"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (state.carregandoFotos && state.fotos.isEmpty)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Carregando fotos...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (state.fotos.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.fotos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final fotoBytes = state.fotos[index];
                              return GestureDetector(
                                onTap: () => _abrirVisualizadorFoto(
                                  fotoBytes,
                                  index + 1,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.memory(
                                        fotoBytes,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.zoom_in,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Não foi possível carregar as fotos desta solicitação.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
