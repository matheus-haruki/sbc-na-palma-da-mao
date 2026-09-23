import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:palma_da_mao/core/components/app_standard_page.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class ZeladoriaHomePage extends StatelessWidget {
  const ZeladoriaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppStandardPage(
      title: 'Ouvidoria / Zeladoria',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Como podemos ajudar?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionCard(
              context: context,
              title: 'Registrar Problema',
              subtitle: 'Buracos, iluminação, limpeza, etc.',
              icon: Icons.add_location_alt_outlined,
              onTap: () => Modular.to.pushNamed('/zeladoria/registrar'),
            ),
            
            const SizedBox(height: 16),
            
            _buildActionCard(
              context: context,
              title: 'Acompanhar Solicitações',
              subtitle: 'Consulte o status pelo seu CPF',
              icon: Icons.search_outlined,
              onTap: () => Modular.to.pushNamed('/zeladoria/acompanhar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
