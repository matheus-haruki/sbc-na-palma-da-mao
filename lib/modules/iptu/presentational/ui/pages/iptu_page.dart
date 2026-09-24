import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_state.dart';
import 'package:palma_da_mao/modules/iptu/models/debito_model.dart';

class IptuPage extends StatefulWidget {
  const IptuPage({super.key});

  @override
  State<IptuPage> createState() => _IptuPageState();
}

class _IptuPageState extends State<IptuPage> {
  final _cpfController = TextEditingController();
  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  late final IptuCubit _cubit;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<IptuCubit>();
    _cpfController.addListener(_onCpfChanged);
  }

  void _onCpfChanged() {
    final isComplete = _cpfMaskFormatter.getUnmaskedText().length == 11;
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

  String _extrairAno(DebitoModel debito) {
    if (debito.vencimento != null && debito.vencimento!.length >= 4) {
      final partes = debito.vencimento!.split('/');
      if (partes.length == 3) {
        return partes[2];
      }
    }
    return debito.vencimento ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppStandardPage(
      title: 'Consulta de Débitos - IPTU',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informe o CPF do proprietário do imóvel:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _cpfController,
                inputFormatters: [_cpfMaskFormatter],
                decoration: InputDecoration(
                  hintText: '000.000.000-00',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
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
                        _cubit.buscarDebitos(_cpfMaskFormatter.getUnmaskedText());
                      }
                    : null,
                child: const Text(
                  'Buscar Débitos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<IptuCubit, IptuState>(
                bloc: _cubit,
                builder: (context, state) {
                  if (state is IptuLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is IptuError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is IptuSuccess) {
                    if (state.debitos.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum débito encontrado.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: state.debitos.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final debito = state.debitos[index];
                        final ano = _extrairAno(debito);
                        final origem = debito.tipo ?? 'Débito';
                        final valorFormatado = debito.valorAtual != null
                            ? debito.valorAtual!.toStringAsFixed(2).replaceAll('.', ',')
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
                                    '/iptu/detalhes',
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                origem.toUpperCase(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.secondary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Ano $ano',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
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
                                              style: TextStyle(
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
      ),
    );
  }
}
