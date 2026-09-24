import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palma_da_mao/core/components/contact_card.dart';
import 'package:palma_da_mao/core/components/square_button.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';
import 'package:palma_da_mao/core/utils/app_browser_navigator.dart';
import 'package:palma_da_mao/core/utils/greeting_helper.dart';

import 'package:palma_da_mao/modules/home/presentational/controllers/home_cubit.dart';
import 'package:palma_da_mao/modules/home/presentational/controllers/home_state.dart';
import 'package:palma_da_mao/modules/home/presentational/ui/widgets/emergency_call_modal.dart';
import 'package:palma_da_mao/modules/home/presentational/ui/widgets/noticias_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit _cubit = Modular.get<HomeCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.carregarDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset(
                        theme.brightness == Brightness.dark
                            ? AppAssets.logoTemaEscuro
                            : AppAssets.logo,
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${GreetingHelper.getGreeting()}\nComo podemos te ajudar hoje?',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: BlocBuilder<HomeCubit, HomeState>(
              bloc: _cubit,
              builder: (context, state) {
                return switch (state) {
                  HomeInitial() || HomeLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  HomeError(message: final msg) => Center(
                    child: Text(
                      msg,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                  HomeSuccess(atalhos: final atalhos) => SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Título da Seção
                        Text(
                          'Serviços Mais Utilizados',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Grid de Serviços
                        SizedBox(
                          // A altura agora define o tamanho do card inteiro
                          height: 120,
                          child: ListView.separated(
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.maisUtilizados.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final atalho = state.maisUtilizados[index];

                              return InkWell(
                                onTap: () {
                                  if (atalho.url != null &&
                                      atalho.url!.isNotEmpty) {
                                    AppBrowserNavigator.openWebPage(
                                      context: context,
                                      urlString: atalho.url!,
                                    );
                                  } else if (atalho.rota != null &&
                                      atalho.rota!.isNotEmpty) {
                                    Modular.to.pushNamed(atalho.rota!);
                                  } else {
                                    Modular.to.pushNamed(
                                      './categoria',
                                      arguments: {
                                        'titulo': atalho.titulo,
                                        'idCategoria': atalho.idCategoria,
                                      },
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 110,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1C1C1F)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(24),
                                    border: isDark
                                        ? Border.all(color: Colors.white12)
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? const Color(0xFF2E2E32)
                                              : AppColors.backgroundBlue,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            atalho.iconePath,
                                            width: 22,
                                            height: 22,
                                            colorFilter: ColorFilter.mode(
                                              isDark
                                                  ? Colors.white
                                                  : AppColors.darkBlue,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        atalho.titulo,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Notícias',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        //Carrossel de Notícias
                        const NoticiasCarousel(),
                        const SizedBox(height: 16),

                        //Categorias de Serviços
                        Text(
                          'Categorias de Serviços',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 112,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: atalhos.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final atalho = atalhos[index];

                              return SquareButton(
                                label: atalho.titulo,
                                iconPath: atalho.iconePath,
                                onTap: () {
                                  // Dispara a navegação passando o bastão (argumentos) para a tela do Canvas
                                  Modular.to.pushNamed(
                                    './categoria', // O "./" mantém o usuário dentro da aba Início!
                                    arguments: {
                                      'titulo': atalho.titulo,
                                      'idCategoria': atalho.idCategoria,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        //Atendimento ao Cidadão
                        Text(
                          'Atendimento ao Cidadão',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Linha contendo os dois cards dividindo o espaço
                        Row(
                          children: [
                            // Primeiro Card (Padrão)
                            Expanded(
                              child: ContactCard(
                                title: 'Fale Conosco',
                                subtitle: 'Telefones',
                                iconPath: AppAssets.iconeTelefone,
                                backgroundColor: isDark
                                    ? const Color(0xFF1D1D20)
                                    : AppColors.surface,
                                borderColor: isDark
                                    ? Colors.white12
                                    : AppColors.border,
                                iconBackgroundColor: isDark
                                    ? const Color(0xFF2B2B2F)
                                    : AppColors.backgroundGray,
                                iconColor: isDark ? Colors.white : colorScheme.onSurface,
                                onTap: () {
                                  Modular.to.pushNamed('./fale-conosco');
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ), // Espaçamento entre os cards
                            // Segundo Card (Alerta/Emergência)
                            Expanded(
                              child: ContactCard(
                                title: 'Emergência',
                                subtitle: 'LIGAR',
                                iconPath: AppAssets.iconeAlerta,
                                backgroundColor: AppColors.lightRed.withValues(
                                  alpha: 0.4,
                                ),
                                borderColor: colorScheme
                                    .errorContainer, // Borda avermelhada
                                iconBackgroundColor: colorScheme
                                    .errorContainer, // Fundo vermelho um pouco mais forte pro ícone
                                iconColor:
                                    colorScheme.error, // Ícone vermelho escuro

                                onTap: () {
                                  showEmergencyCallModal(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Redirecionando para a raiz do chat (que agora é a lista de tickets)
                            Modular.to.pushNamed('/chat/');
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Acessar Meus Chamados'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
