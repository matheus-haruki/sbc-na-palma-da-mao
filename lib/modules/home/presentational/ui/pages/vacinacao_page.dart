import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/vacinacao_cubit.dart';
import '../../controllers/vacinacao_state.dart';

class VacinacaoPage extends StatefulWidget {
  const VacinacaoPage({super.key});

  @override
  State<VacinacaoPage> createState() => _VacinacaoPageState();
}

class _VacinacaoPageState extends State<VacinacaoPage> {
  late final VacinacaoCubit _vacinacaoCubit;

  @override
  void initState() {
    super.initState();
    _vacinacaoCubit = Modular.get<VacinacaoCubit>();
    _vacinacaoCubit.fetchDados();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppStandardPage(
      title: 'Vacinação',
      body: BlocBuilder<VacinacaoCubit, VacinacaoState>(
        bloc: _vacinacaoCubit,
        builder: (context, state) {
          if (state is VacinacaoLoading || state is VacinacaoInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VacinacaoError) {
            return Center(
              child: Text(
                'Ocorreu um erro ao carregar os dados:\n${state.message}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.error,
                ),
              ),
            );
          }

          if (state is VacinacaoSuccess) {
            final dados = state.dados;

            if (dados.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma informação de vacinação disponível.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: dados.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = dados[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                            placeholder: (context, url) => Container(
                              height: 150,
                              color: Colors.grey.withValues(alpha: 0.2),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 150,
                              color: Colors.grey.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.nome,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.enderecoCompleto,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
