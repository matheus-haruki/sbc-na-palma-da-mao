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

  // CORREÇÃO 1: Caminhos absolutos garantem que o Modular nunca se perca
  final _routes = const [
    '/main/home/', 
    '/main/servicos/', 
    '/main/mais/'
  ];

  @override
  void initState() {
    super.initState();
    // CORREÇÃO 2: Removemos a navegação daqui! 
    // A SplashPage já fez o trabalho de chamar Modular.to.navigate('/main/home');
    // Então, quando esta tela nasce, o RouterOutlet já sabe que deve carregar o HomeModule.
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);
    
    // O navigate injeta a nova rota silenciosamente dentro do RouterOutlet
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
      // O RouterOutlet é o buraco negro onde os módulos filhos serão renderizados
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