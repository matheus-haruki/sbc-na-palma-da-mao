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
                        Modular.to.navigate('/main/home');
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildListTile(
                    context,
                    'Escolher tema',
                    Icons.palette_outlined,
                    onTap: () => _showThemeDialog(context, state.isDarkMode),
                  ),
                  _buildListTile(
                    context,
                    'Política de Privacidade',
                    Icons.chevron_right,
                    onTap: () {
                      Modular.to.pushNamed('./politica-privacidade');
                    },
                  ),
                  _buildListTile(
                    context,
                    'Fale com a Prefeitura',
                    Icons.chevron_right,
                    onTap: () {
                      Modular.to.pushNamed('./fale-conosco');
                    },
                  ),

                  const Spacer(),

                  Column(
                    children: [
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

  void _showThemeDialog(BuildContext context, bool isDarkMode) {
    final currentValue = isDarkMode ? 'Escuro' : 'Claro';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Escolher tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Claro'),
                leading: Icon(
                  currentValue == 'Claro' ? Icons.check_circle : Icons.circle_outlined,
                ),
                onTap: () async {
                  await _cubit.setTheme(ThemeMode.light);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
              ListTile(
                title: const Text('Escuro'),
                leading: Icon(
                  currentValue == 'Escuro' ? Icons.check_circle : Icons.circle_outlined,
                ),
                onTap: () async {
                  await _cubit.setTheme(ThemeMode.dark);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.secondary,
        ),
      ),
      trailing: Icon(icon),
      onTap: onTap,
    );
  }
}
