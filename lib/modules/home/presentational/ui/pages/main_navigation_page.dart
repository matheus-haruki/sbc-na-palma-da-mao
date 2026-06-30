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

  final _routes = const ['/home/', '/servicos/', '/mais/'];

  @override
  void initState() {
    super.initState();
    Modular.to.navigate(_routes[_currentIndex]);
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);
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

        // 👇 TEXTO
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
