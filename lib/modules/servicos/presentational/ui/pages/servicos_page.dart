import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

import '../../controllers/servicos_cubit.dart';
import '../../controllers/servicos_state.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key});

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  final ServicosCubit _cubit = Modular.get<ServicosCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.carregarListaDeServicos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<ServicosCubit, ServicosState>(
        bloc: _cubit,
        builder: (context, state) {
          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Barra de Busca Customizada
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        // Borda sutil em vez de fundo chapado
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                        // Sombra leve para destacar no fundo
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'O que você procura hoje?',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.secondary,
                          ),
                          // Remove as linhas padrão do TextField nativo
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          // Futuro acionamento de filtro no Cubit
                        },
                      ),
                    ),
                  ),
                ),

                // 2. Tratamento de Estados para a Lista de Serviços
                switch (state) {
                  ServicosInitial() ||
                  ServicosLoading() => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  ServicosError(message: final msg) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        msg,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ),
                  ServicosSuccess(categorias: final categorias) =>
                    SliverList.separated(
                      itemCount: categorias.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          // O widget Theme remove as linhas divisórias nativas e feias do ExpansionTile
                          child: Theme(
                            data: theme.copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              // Customização de bordas para ficar como um card MD3
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide
                                    .none, // Borda removida quando fechado
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide
                                    .none, // Borda removida quando aberto
                              ),
                              iconColor: AppColors.secondary,
                              backgroundColor: AppColors.background,
                              collapsedBackgroundColor: AppColors.background,
                              collapsedIconColor: AppColors.secondary,

                              title: Text(
                                categorias[index],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),

                              // Filhos (Sub-itens) que aparecem ao expandir
                              children: [
                                // Mock de serviços dentro da categoria
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  title: Text(
                                    'Agendamento de Consulta',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: AppColors.secondary),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  onTap: () {
                                    // Navegar para o serviço específico
                                  },
                                ),

                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  title: Text(
                                    'Histórico Médico',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: AppColors.secondary),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  onTap: () {
                                    // Navegar para o serviço específico
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}
