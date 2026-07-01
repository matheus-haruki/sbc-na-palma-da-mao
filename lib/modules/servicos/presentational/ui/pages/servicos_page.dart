import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/app_browser_navigator.dart';
import 'package:palma_da_mao/modules/servicos/models/servico_model.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_cubit.dart';
import 'package:palma_da_mao/modules/servicos/presentational/controllers/servicos_state.dart';

// Ajuste os caminhos conforme o seu projeto

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ServicosCubit, ServicosState>(
        bloc: _cubit,
        builder: (context, state) {
          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Barra de Busca Customizada (Mantida intacta)
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
                  // MUDANÇA AQUI: Recebemos a lista de ServicoModel
                  ServicosSuccess(servicos: final servicos) =>
                    SliverList.separated(
                      itemCount: servicos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        // Passamos true para isTopLevel para manter o padding lateral
                        // da raiz da lista que você havia definido
                        return _buildServicoItem(
                          context,
                          servicos[index],
                          isTopLevel: true,
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

  /// Constrói o item dinamicamente mantendo o seu design MD3
  Widget _buildServicoItem(
    BuildContext context,
    ServicoModel servico, {
    bool isTopLevel = false,
  }) {
    final theme = Theme.of(context);
    final isAvailable = servico.isAvailable;

    // Cor do texto fica opaca se o serviço não estiver disponível
    final textColor = isAvailable
        ? AppColors.secondary
        : theme.colorScheme.outline;

    // Se for um GRUPO, renderiza o seu ExpansionTile estilizado
    if (servico.type == ServicoType.group) {
      final expansionTile = Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          iconColor: AppColors.secondary,
          backgroundColor: AppColors.background,
          collapsedBackgroundColor: AppColors.background,
          collapsedIconColor: AppColors.secondary,
          title: Text(
            servico.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          // Recursividade: renderiza os subitens dentro do grupo (isTopLevel = false)
          children: servico.subItems
              .map(
                (subItem) =>
                    _buildServicoItem(context, subItem, isTopLevel: false),
              )
              .toList(),
        ),
      );

      return isTopLevel
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: expansionTile,
            )
          : expansionTile;
    }

    // Se for WEB ou NATIVO, renderiza o ListTile
    final listTile = ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isTopLevel ? 24 : 32),
      title: Text(
        servico.title,
        style: theme.textTheme.titleMedium?.copyWith(color: textColor),
      ),
      trailing: _getTrailingIcon(servico),
      onTap: isAvailable
          ? () => _handleNavegacao(context, servico)
          : () => _mostrarAvisoIndisponivel(context),
    );

    // Se um item web/nativo estiver solto na raiz (fora de grupo), colocamos um fundo nele
    // para bater com o design arredondado que você fez no ExpansionTile
    if (isTopLevel) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: listTile,
        ),
      );
    }

    return listTile;
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
        Icons.open_in_browser,
        size: 18,
        color: AppColors.secondary,
      );
    }
    return const Icon(
      Icons.arrow_forward_ios,
      size: 14,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }
}
