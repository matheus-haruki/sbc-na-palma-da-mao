import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final _routes = const ['/main/home/', '/main/servicos/', '/main/mais/'];

  // 1. Criamos a variável do nosso "espião" de rotas
  late final VoidCallback _routeListener;

  @override
  void initState() {
    super.initState();

    // 2. Ensinamos o espião o que ele deve fazer quando a rota mudar
    _routeListener = () {
      final String currentPath = Modular.to.path;
      int newIndex = _currentIndex;

      if (currentPath.contains('/main/home')) {
        newIndex = 0;
      } else if (currentPath.contains('/main/servicos')) {
        newIndex = 1;
      } else if (currentPath.contains('/main/mais')) {
        newIndex = 2;
      }

      // Se o índice real for diferente do que está desenhado na tela, nós atualizamos!
      if (newIndex != _currentIndex && mounted) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    };

    // 3. Cadastramos o espião no sistema de rotas do Modular
    Modular.to.addListener(_routeListener);
  }

  @override
  void dispose() {
    // 4. Regra de ouro: sempre demitir o espião quando a tela for destruída (evita vazamento de memória)
    Modular.to.removeListener(_routeListener);
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;

    // Agora só precisamos mandar navegar! O nosso Listener (espião) vai detectar a mudança
    // e disparar o setState alterando o _currentIndex automaticamente.
    Modular.to.navigate(_routes[index]);
  }

  Widget _buildIcon(String asset, bool selected) {
    return SvgPicture.asset(
      asset,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(
        selected ? AppColors.primary : AppColors.textSecondary,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const RouterOutlet(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
        destinations: [
          NavigationDestination(
            icon: _buildIcon(AppAssets.iconeHome, false),
            selectedIcon: _buildIcon(AppAssets.iconeHome, true),
            label: 'Início',
          ),
          NavigationDestination(
            icon: _buildIcon(AppAssets.iconeServicos, false),
            selectedIcon: _buildIcon(AppAssets.iconeServicos, true),
            label: 'Serviços',
          ),
          NavigationDestination(
            icon: _buildIcon(AppAssets.iconeMenu, false),
            selectedIcon: _buildIcon(AppAssets.iconeMenu, true),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
