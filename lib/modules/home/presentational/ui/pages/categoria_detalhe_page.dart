import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_cubit.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_state.dart';

class CategoriaDetalhePage extends StatefulWidget {
  final String titulo;
  final String idCategoria;

  const CategoriaDetalhePage({
    super.key,
    required this.titulo,
    required this.idCategoria,
  });

  @override
  State<CategoriaDetalhePage> createState() => _CategoriaDetalhePageState();
}

class _CategoriaDetalhePageState extends State<CategoriaDetalhePage> {
  // Pegamos a instância global do ServicosCubit
  late final ServicosCubit _servicosCubit;

  @override
  void initState() {
    super.initState();
    _servicosCubit = Modular.get<ServicosCubit>();

    // Se por algum motivo o JSON ainda não foi lido, forçamos o carregamento
    if (_servicosCubit.state is ServicosInitial) {
      _servicosCubit.carregarListaDeServicos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Substituímos o Scaffold pelo AppStandardPage
    return AppStandardPage(
      title: widget.titulo,
      body: BlocBuilder<ServicosCubit, ServicosState>(
        bloc: _servicosCubit,
        builder: (context, state) {
          if (state is ServicosLoading || state is ServicosInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ServicosSuccess) {
            final servicosFiltrados = state.servicos
                .where((servico) => servico.categoria == widget.idCategoria)
                .toList();

            if (servicosFiltrados.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum serviço disponível no momento.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return ListView.separated(
              // Padding ajustado: aumentamos o topo para 24 devido à borda arredondada do AppStandardPage
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              itemCount: servicosFiltrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final servico = servicosFiltrados[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      servico.title, // Assumindo que seu modelo usa "title"
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    onTap: () {
                      // Aqui entrará a lógica de abrir o navegador ou tela nativa depois
                    },
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