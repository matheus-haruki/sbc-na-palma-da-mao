import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:palma_da_mao/core/components/app_empty_state.dart';
import 'package:palma_da_mao/core/components/app_error_state.dart';
import 'package:palma_da_mao/core/components/app_primary_button.dart';
import 'package:palma_da_mao/core/components/app_shimmer_list.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/components/cpf_text_field.dart';
import 'package:palma_da_mao/core/components/keyboard_done_accessory.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/cpf_validator.dart';
import '../models/solicitacao_resumo_model.dart';
import '../presentational/controllers/zeladoria_consulta_cubit.dart';
import '../presentational/controllers/zeladoria_consulta_state.dart';

class ZeladoriaAcompanharPage extends StatefulWidget {
  const ZeladoriaAcompanharPage({super.key});

  @override
  State<ZeladoriaAcompanharPage> createState() =>
      _ZeladoriaAcompanharPageState();
}

class _ZeladoriaAcompanharPageState extends State<ZeladoriaAcompanharPage> {
  final _cpfController = TextEditingController();
  final _cpfFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  late final ZeladoriaConsultaCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<ZeladoriaConsultaCubit>();
  }

  @override
  void dispose() {
    _cpfFocusNode.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void _buscarSolicitacoes() {
    _cpfFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    _cubit.consultarPorCpf(_cpfController.text);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AppStandardPage(
        title: 'Acompanhar Solicitações',
        body: KeyboardDoneAccessory(
          focusNodes: [_cpfFocusNode],
          child: GestureDetector(
            onTap: () {
              _cpfFocusNode.unfocus();
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Consulte suas solicitações',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Informe seu CPF',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                      CpfTextField(
                        controller: _cpfController,
                        focusNode: _cpfFocusNode,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Informe seu CPF';
                          }
                          if (!CpfValidator.isValid(val)) {
                            return 'Digite um CPF válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ZeladoriaConsultaCubit,
                          ZeladoriaConsultaState>(
                        builder: (context, state) {
                          final isLoading = state is ZeladoriaConsultaLoading;

                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _cpfController,
                            builder: (context, value, _) {
                              final isValidCpf =
                                  CpfValidator.isValid(value.text);

                              return AppPrimaryButton(
                                text: 'Buscar',
                                isLoading: isLoading,
                                onPressed: isValidCpf ? _buscarSolicitacoes : null,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child:
                  BlocBuilder<ZeladoriaConsultaCubit, ZeladoriaConsultaState>(
                builder: (context, state) {
                  if (state is ZeladoriaConsultaLoading) {
                    return const AppShimmerList(padding: EdgeInsets.all(16));
                  }

                  if (state is ZeladoriaConsultaInitial) {
                    return const SizedBox.shrink();
                  }

                  if (state is ZeladoriaConsultaEmpty) {
                    return const AppEmptyState(
                      message: 'Nenhuma solicitação encontrada para este CPF.',
                    );
                  }

                  if (state is ZeladoriaConsultaError) {
                    return const AppErrorState();
                  }

                  if (state is ZeladoriaConsultaSuccess) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.solicitacoes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.solicitacoes[index];
                        final status = item.rotuloStatus;
                        final color = _getStatusColor(status);

                        return _buildCardSolicitacao(item, status, color);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildCardSolicitacao(
    SolicitacaoResumoModel item,
    String status,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            _cpfFocusNode.unfocus();
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();

            await Modular.to.pushNamed(
              '/zeladoria/detalhes',
              arguments: {
                'protocolo': item.protocolo,
                'cpf': _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                'resumo': item,
              },
            );

            if (mounted) {
              _cpfFocusNode.unfocus();
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Text(
                      _formatarData(item.incluidoEm),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.nomeServico,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Protocolo:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      item.protocolo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
