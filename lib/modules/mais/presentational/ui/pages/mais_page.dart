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
              if (state is! MaisSuccess) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // Tenta navegar para a raiz absoluta do aplicativo
                        Modular.to.navigate('/main/home');
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildListTile(
                    context,
                    'Política de Privacidade',
                    Icons.chevron_right,
                    onTap: () {
                      // Navegação usando pushNamed
                      Modular.to.pushNamed('./politica-privacidade');
                    },
                  ),
                  _buildListTile(
                    context,
                    'Fale com a Prefeitura',
                    Icons.chevron_right,
                    onTap: () {
                      // Navegação usando pushNamed
                      Modular.to.pushNamed('./fale-conosco');
                    },
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tema',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          RadioListTile<ThemeMode>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Tema atual'),
                            value: ThemeMode.light,
                            groupValue: state.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                _cubit.alterarTema(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Escuro'),
                            value: ThemeMode.dark,
                            groupValue: state.themeMode,
                            onChanged: (value) {
                              if (value != null) {
                                _cubit.alterarTema(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final titleColor =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.onSurface
            : AppColors.secondary;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
        ),
        trailing: Icon(icon, color: titleColor),
        onTap: onTap,
      ),
    );
  }
}
