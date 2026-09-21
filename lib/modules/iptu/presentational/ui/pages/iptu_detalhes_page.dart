import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:palma_da_mao/modules/iptu/models/parcela_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_detalhes_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_detalhes_state.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_guia_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_guia_state.dart';
import 'package:shimmer/shimmer.dart';

class IptuDetalhesPage extends StatefulWidget {
  final String lancamento;

  const IptuDetalhesPage({super.key, required this.lancamento});

  @override
  State<IptuDetalhesPage> createState() => _IptuDetalhesPageState();
}

class _IptuDetalhesPageState extends State<IptuDetalhesPage> {
  late final IptuDetalhesCubit _cubit;
  late final IptuGuiaCubit _guiaCubit;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<IptuDetalhesCubit>();
    _guiaCubit = Modular.get<IptuGuiaCubit>();
    _cubit.buscarDetalhes(widget.lancamento);
  }

  void _abrirModalGuia({int? parcela}) {
    if (parcela != null) {
      _guiaCubit.emitirGuiaParcela(widget.lancamento, parcela);
    } else {
      _guiaCubit.emitirGuiaTotal(widget.lancamento);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        bool isCopied = false;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: BlocBuilder<IptuGuiaCubit, IptuGuiaState>(
                bloc: _guiaCubit,
                builder: (context, guiaState) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        const Text(
                          'Guia de Arrecadação - IPTU',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBlue),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        if (guiaState is IptuGuiaLoading) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            guiaState.mensagem,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ] else if (guiaState is IptuGuiaError) ...[
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            guiaState.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tentar Novamente'),
                          ),
                        ] else if (guiaState is IptuGuiaSuccess) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                            child: Text(
                              guiaState.guia.linhaDigitavel,
                              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Primary Action: Copiar
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: isCopied ? null : () async {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(ClipboardData(text: guiaState.guia.linhaDigitavel));
                                setStateModal(() => isCopied = true);
                                await Future.delayed(const Duration(seconds: 2));
                                if (context.mounted) setStateModal(() => isCopied = false);
                              },
                              icon: Icon(isCopied ? Icons.check_circle : Icons.copy),
                              label: Text(
                                isCopied ? 'Copiado!' : 'Copiar Código',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCopied ? Colors.green : AppColors.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Secondary Action: PDF
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (guiaState.pdfBytes != null) {
                                  Share.shareXFiles([
                                    XFile.fromData(
                                      guiaState.pdfBytes!, 
                                      name: 'IPTU_SBC_Lancamento.pdf',
                                      mimeType: 'application/pdf',
                                    )
                                  ], text: 'Segue a guia de pagamento do IPTU.');
                                }
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Salvar Documento (PDF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                side: const BorderSide(color: AppColors.secondary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _guiaCubit.reset();
                              Navigator.pop(context);
                            },
                            child: const Text('Fechar'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    ).then((_) => _guiaCubit.reset());
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppStandardPage(
      title: 'Detalhes do Débito',
      body: BlocBuilder<IptuDetalhesCubit, IptuDetalhesState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is IptuDetalhesLoading || state is IptuDetalhesInitial) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildShimmer(),
            );
          } else if (state is IptuDetalhesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          } else if (state is IptuDetalhesSuccess) {
            final double valorTotalAberto = state.parcelasVencidas.fold(0.0, (s, p) => s + p.valor) +
                (state.proximaParcela?.valor ?? 0.0) +
                state.parcelasFuturas.fold(0.0, (s, p) => s + p.valor);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (state.parcelasVencidas.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Existem ${state.parcelasVencidas.length} parcelas em atraso. Procure a Dívida Ativa ou gere um boleto atualizado.',
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (state.parcelasPagas.isNotEmpty)
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(
                              'Histórico de Pagamentos\n(${state.parcelasPagas.length} parcelas pagas)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            collapsedBackgroundColor: Colors.grey.shade50,
                            backgroundColor: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            children: state.parcelasPagas
                                .map((p) => _buildParcelaComum(p, true))
                                .toList(),
                          ),
                        ),

                      if (state.parcelasPagas.isNotEmpty)
                        const SizedBox(height: 24),

                      if (state.proximaParcela != null) ...[
                        const Text(
                          'Próximo Vencimento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildHeroCard(state.proximaParcela!),
                        const SizedBox(height: 24),
                      ],

                      if (state.parcelasFuturas.isNotEmpty) ...[
                        const Text(
                          'Parcelas Futuras',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...state.parcelasFuturas.map(
                          (p) => _buildParcelaComum(p, false),
                        ),
                      ],
                    ],
                  ),
                ),
                // Sticky CTA
                if (valorTotalAberto > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                        )
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: BlocBuilder<IptuGuiaCubit, IptuGuiaState>(
                          bloc: _guiaCubit,
                          builder: (context, guiaState) {
                            final isLoading = guiaState is IptuGuiaLoading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : () => _abrirModalGuia(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Pagar Total - ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valorTotalAberto)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeroCard(ParcelaModel parcela) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormatter = DateFormat('dd/MM/yyyy');

    int diasRestantes = 0;
    if (parcela.dataVencimento != null) {
      diasRestantes = parcela.dataVencimento!.difference(DateTime.now()).inDays;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Parcela ${parcela.numeroParcela ?? "-"}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (diasRestantes >= 0)
                Text(
                  diasRestantes == 0
                      ? 'Vence hoje'
                      : 'Vence em $diasRestantes dias',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Valor da parcela',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormatter.format(parcela.valor),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vencimento: ${parcela.dataVencimento != null ? dateFormatter.format(parcela.dataVencimento!) : "-"}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: BlocBuilder<IptuGuiaCubit, IptuGuiaState>(
              bloc: _guiaCubit,
              builder: (context, guiaState) {
                final isLoading = guiaState is IptuGuiaLoading;
                return ElevatedButton.icon(
                  onPressed: isLoading ? null : () {
                    if (parcela.numeroParcela != null) {
                      _abrirModalGuia(parcela: parcela.numeroParcela!);
                    }
                  },
                  icon: isLoading ? const SizedBox() : SvgPicture.asset(
                    'assets/icon/barcode.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Gerar Boleto',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelaComum(ParcelaModel parcela, bool isPaga) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPaga ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parcela ${parcela.numeroParcela ?? "-"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaga ? Colors.grey.shade600 : AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Venc. ${parcela.dataVencimento != null ? dateFormatter.format(parcela.dataVencimento!) : "-"}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormatter.format(parcela.valor),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaga ? Colors.grey.shade500 : Colors.black87,
                  decoration: isPaga ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 6),
              if (isPaga)
                const Text(
                  'PAGO',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                SizedBox(
                  height: 28,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Antecipar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
