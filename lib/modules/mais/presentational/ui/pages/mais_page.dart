// lib/modules/mais/presentational/ui/pages/mais_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/modules/mais/presentational/controllers/mais_cubit.dart';
import 'package:palma_da_mao/modules/mais/presentational/controllers/mais_state.dart';

class MaisPage extends StatefulWidget {
  const MaisPage({super.key});

  @override
  State<MaisPage> createState() => _MaisPageState();
}

class _MaisPageState extends State<MaisPage> {
  final MaisCubit _cubit = Modular.get<MaisCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.carregarConfiguracoes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<MaisCubit, MaisState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state is! MaisSuccess)
                return const Center(child: CircularProgressIndicator());

              return Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Modular.to.navigate('/home/'),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ListTile(
                    title: Text(
                      'Tema: ${state.isDarkMode ? "Escuro" : "Claro"}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    trailing: Transform.scale(
                      scale: 0.85, // ajuste esse valor para o tamanho desejado
                      child: Switch(
                        value: state.isDarkMode,
                        onChanged: _cubit.toggleTheme,
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // remove a área extra de toque
                        trackOutlineColor: const WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                        trackColor: WidgetStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.secondary;
                          }
                          return AppColors.primary;
                        }),
                        thumbColor: WidgetStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          return AppColors.surface;
                        }),
                      ),
                    ),
                  ),
                  _buildListTile(
                    context,
                    'Política de Privacidade',
                    Icons.chevron_right,
                    onTap: () {
                      // Navegação usando pushNamed
                      Modular.to.pushNamed('/mais/politica-privacidade');
                    },
                  ),
                  _buildListTile(
                    context,
                    'Fale com a Prefeitura',
                    Icons.chevron_right,
                    onTap: () {
                      // Navegação usando pushNamed
                      Modular.to.pushNamed('/mais/fale-conosco');
                    },
                  ),

                  const Spacer(),

                  // Rodapé
                  Column(
                    children: [
                      // Substitua pelo seu asset de logo
                      Image.asset(AppAssets.logo, height: 90),
                      const SizedBox(height: 60),
                      Text(
                        'Versão 3.0.0\nDesenvolvido por DTI - PMSBC',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap, // <- É este parâmetro nomeado que estava faltando!
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppColors.secondary),
      ),
      trailing: Icon(icon),
      onTap: onTap, // O ListTile agora usa a função que foi passada
    );
  }
}
