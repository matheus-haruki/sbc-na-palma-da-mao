import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/app_browser_navigator.dart';
import 'package:palma_da_mao/modules/servicos/models/servico_model.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_cubit.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_state.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key});

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  final ServicosCubit _cubit = Modular.get<ServicosCubit>();
  
  // 1. Variável de estado que guarda o texto digitado na pesquisa
  String _searchQuery = '';

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ServicosCubit, ServicosState>(
        bloc: _cubit,
        builder: (context, state) {
          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Barra de Busca Customizada
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
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
                        decoration: InputDecoration(
                          hintText: 'O que você procura hoje?',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.secondary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        // 2. Atualiza a tela toda vez que o usuário digita algo
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // Tratamento de Estados e Renderização da Lista
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
                  ServicosSuccess(servicos: final servicos) => () {
                      // 3. Lógica de Filtragem em Tempo Real
                      final query = _searchQuery.trim().toLowerCase();

                      final servicosFiltrados = query.isEmpty
                          ? servicos
                          : servicos.where((servico) {
                              final bateuPrincipal = servico.title.toLowerCase().contains(query);
                              final bateuSubItem = servico.subItems.any(
                                (sub) => sub.title.toLowerCase().contains(query),
                              );
                              return bateuPrincipal || bateuSubItem;
                            }).toList();

                      // Se não achar nada, exibe mensagem amigável
                      if (servicosFiltrados.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'Nenhum resultado encontrado para "$_searchQuery"',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // 4. O SliverPadding adiciona o "espaço vazio" no final da lista (bottom: 40)
                      return SliverPadding(
                        padding: const EdgeInsets.only(bottom: 40),
                        sliver: SliverList.separated(
                          itemCount: servicosFiltrados.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildServicoItem(
                              context,
                              servicosFiltrados[index],
                              isTopLevel: true,
                            );
                          },
                        ),
                      );
                    }(),
                },
              ],
            ),
          );
        },
      ),
    );
  }

  /// Constrói o item dinamicamente mantendo o design elegante de "Cards"
  Widget _buildServicoItem(
    BuildContext context,
    ServicoModel servico, {
    bool isTopLevel = false,
  }) {
    final theme = Theme.of(context);
    final isAvailable = servico.isAvailable;

    final textColor = isAvailable
        ? AppColors.secondary 
        : theme.colorScheme.outline;

    if (servico.type == ServicoType.group) {
      final expansionTile = Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.secondary,
          collapsedIconColor: AppColors.secondary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          title: Text(
            servico.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          children: servico.subItems.map((subItem) {
            return Column(
              children: [
                _buildServicoItem(context, subItem, isTopLevel: false),
                if (subItem != servico.subItems.last)
                  Divider(
                    height: 1,
                    indent: 32,
                    endIndent: 16,
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }).toList(),
        ),
      );

      return isTopLevel
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCardContainer(expansionTile),
            )
          : expansionTile;
    }

    final listTile = ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTopLevel ? 16 : 32,
        vertical: isTopLevel ? 2 : 0,
      ),
      title: Text(
        servico.title,
        style: (isTopLevel ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(
          color: isTopLevel ? textColor : textColor.withOpacity(0.85),
          fontWeight: isTopLevel ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: _getTrailingIcon(servico),
      onTap: isAvailable
          ? () => _handleNavegacao(context, servico)
          : () => _mostrarAvisoIndisponivel(context),
    );

    return isTopLevel
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCardContainer(listTile),
          )
        : listTile;
  }

  /// Caixa de estilo (fundo branco, borda arredondada, sombra suave)
  Widget _buildCardContainer(Widget child) {
    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: child,
    );
  }

  /// Retorna o ícone correto dependendo do tipo do serviço
  Widget _getTrailingIcon(ServicoModel servico) {
    if (!servico.isAvailable) {
      return const Text(
        'Em breve',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    if (servico.type == ServicoType.web) {
      return const Icon(
        Icons.open_in_new, 
        size: 18,
        color: AppColors.secondary,
      );
    }
    return const Icon(
      Icons.chevron_right,
      size: 18,
      color: AppColors.secondary,
    );
  }

  /// Aciona a navegação adequada
  void _handleNavegacao(BuildContext context, ServicoModel servico) {
    if (servico.type == ServicoType.web) {
      if (servico.url.isNotEmpty) {
        AppBrowserNavigator.openWebPage(
          context: context,
          urlString: servico.url,
        );
      } else {
        _mostrarAviso(context, 'Link web ainda não configurado.');
      }
    } else if (servico.type == ServicoType.native) {
      if (servico.route.isNotEmpty) {
        Modular.to.pushNamed(servico.route);
      } else {
        _mostrarAviso(context, 'Rota nativa ainda não configurada.');
      }
    }
  }

  void _mostrarAvisoIndisponivel(BuildContext context) {
    _mostrarAviso(context, 'Este serviço estará disponível em breve!');
  }

  void _mostrarAviso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }
}