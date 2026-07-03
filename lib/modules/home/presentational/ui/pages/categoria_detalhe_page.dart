import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/app_browser_navigator.dart';
import 'package:palma_da_mao/modules/servicos/models/servico_model.dart';
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
  late final ServicosCubit _servicosCubit;

  @override
  void initState() {
    super.initState();
    _servicosCubit = Modular.get<ServicosCubit>();

    if (_servicosCubit.state is ServicosInitial) {
      _servicosCubit.carregarListaDeServicos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                .where((servico) {
                  return servico.categoria.trim().toLowerCase() == 
                         widget.idCategoria.trim().toLowerCase();
                })
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              itemCount: servicosFiltrados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Passamos true para isTopLevel para aplicar o visual de "Card" na raiz
                return _buildServicoItem(
                  context, 
                  servicosFiltrados[index], 
                  isTopLevel: true
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Constrói o item dinamicamente unindo a LÓGICA da ServicosPage com o DESIGN da Categoria
  Widget _buildServicoItem(
    BuildContext context,
    ServicoModel servico, {
    bool isTopLevel = false,
  }) {
    final theme = Theme.of(context);
    final isAvailable = servico.isAvailable;

    final textColor = isAvailable
        ? AppColors.textPrimary
        : theme.colorScheme.outline;

    // 1. SE FOR UM GRUPO (Possui subserviços): Renderiza o ExpansionTile
    if (servico.type == ServicoType.group) {
      final expansionTile = Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.textPrimary,
          collapsedIconColor: AppColors.textPrimary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          title: Text(
            servico.title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Renderiza os subserviços passando isTopLevel = false
          children: servico.subItems.map((subItem) {
            return Column(
              children: [
                _buildServicoItem(context, subItem, isTopLevel: false),
                // Adiciona um divisor apenas se não for o último item da lista
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

      // Se for um grupo na raiz da lista, veste ele com o "Card" branco
      return isTopLevel ? _buildCardContainer(expansionTile) : expansionTile;
    }

    // 2. SE FOR WEB OU NATIVO (Item clicável final): Renderiza o ListTile
    final listTile = ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTopLevel ? 16 : 32, 
        vertical: isTopLevel ? 2 : 0,
      ),
      title: Text(
        servico.title,
        style: (isTopLevel ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium)?.copyWith(
          color: isTopLevel ? textColor : textColor.withOpacity(0.85),
          fontWeight: isTopLevel ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: _getTrailingIcon(servico),
      onTap: isAvailable
          ? () => _handleNavegacao(context, servico)
          : () => _mostrarAvisoIndisponivel(context),
    );

    // Se for um item solto na raiz, também precisa vestir o "Card" branco!
    return isTopLevel ? _buildCardContainer(listTile) : listTile;
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
        Icons.open_in_new, // Ajustado para bater com o que usamos antes
        size: 18,
        color: AppColors.textPrimary,
      );
    }
    return const Icon(
      Icons.chevron_right, // Ajustado para bater com o que usamos antes
      size: 18,
      color: AppColors.textPrimary,
    );
  }

  /// Aciona a navegação usando os utilitários da sua arquitetura
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