import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/components/cpf_text_field.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_cubit.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_state.dart';
import 'package:palma_da_mao/core/components/app_empty_state.dart';
import 'package:palma_da_mao/core/components/app_shimmer_list.dart';

class TransitoPage extends StatefulWidget {
  const TransitoPage({super.key});

  @override
  State<TransitoPage> createState() => _TransitoPageState();
}

class _TransitoPageState extends State<TransitoPage> {
  final _cpfController = TextEditingController();
  late final TransitoCubit _cubit;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<TransitoCubit>();
    _cpfController.addListener(_onCpfChanged);
  }

  void _onCpfChanged() {
    final unmaskedText = _cpfController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final isComplete = unmaskedText.length == 11;
    if (_isButtonEnabled != isComplete) {
      setState(() {
        _isButtonEnabled = isComplete;
      });
    }
  }

  @override
  void dispose() {
    _cpfController.removeListener(_onCpfChanged);
    _cpfController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppStandardPage(
      title: 'Consulta de Multas de Trânsito',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Informe o CPF:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                CpfTextField(
                  controller: _cpfController,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isButtonEnabled
                        ? () {
                            FocusScope.of(context).unfocus();
                            final unmaskedText = _cpfController.text
                                .replaceAll(RegExp(r'[^0-9]'), '');
                            _cubit.buscarDebitos(unmaskedText);
                          }
                        : null,
                    child: const Text(
                      'Buscar Débitos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TransitoCubit, TransitoState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is TransitoLoading) {
                  return const AppShimmerList(
                    padding: EdgeInsets.all(16),
                  );
                } else if (state is TransitoError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is TransitoSuccess) {
                    if (state.debitos.isEmpty) {
                      return const AppEmptyState(
                        message: 'Nenhuma multa encontrada.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.debitos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final debito = state.debitos[index];
                        final origem = debito.tipo ?? 'Débito';
                        final valorFormatado = debito.valorAtual != null
                            ? debito.valorAtual!
                                .toStringAsFixed(2)
                                .replaceAll('.', ',')
                            : '-';

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
                              onTap: () {
                                if (debito.lancamento != null) {
                                  Modular.to.pushNamed(
                                    '/transito/detalhes',
                                    arguments: debito.lancamento,
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                origem.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.secondary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              // Container(
                                              //   padding:
                                              //       const EdgeInsets.symmetric(
                                              //           horizontal: 10,
                                              //           vertical: 4),
                                              //   decoration: BoxDecoration(
                                              //     color: Colors.grey.shade100,
                                              //     borderRadius:
                                              //         BorderRadius.circular(12),
                                              //   ),
                                              //   child: Text(
                                              //     'Ano $ano',
                                              //     style: TextStyle(
                                              //       fontSize: 13,
                                              //       fontWeight: FontWeight.w600,
                                              //       color: Colors.grey.shade700,
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Lançamento: ${debito.lancamento ?? "-"}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (debito.placa != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Placa: ${debito.placa} - Auto: ${debito.ait ?? "-"}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Valor a pagar',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text.rich(
                                            TextSpan(
                                              text: 'R\$ ',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.darkBlue,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: valorFormatado,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade400,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: SizedBox(),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
