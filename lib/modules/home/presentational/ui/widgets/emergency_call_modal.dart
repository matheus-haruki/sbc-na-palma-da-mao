// lib/widgets/emergency_call_modal.dart
import 'package:flutter/material.dart';
import 'package:palma_da_mao/core/constants/emergency_numbers.dart';
import 'package:palma_da_mao/services/phone_service.dart';


class EmergencyCallModal extends StatelessWidget {
  const EmergencyCallModal({super.key});

  static const List<_EmergencyOption> _options = [
    _EmergencyOption('Defesa Civil', EmergencyNumbers.defesaCivil, Icons.shield_outlined),
    _EmergencyOption('Polícia', EmergencyNumbers.policia, Icons.local_police_outlined),
    _EmergencyOption('SAMU', EmergencyNumbers.samu, Icons.medical_services_outlined),
    _EmergencyOption('Bombeiros', EmergencyNumbers.bombeiros, Icons.local_fire_department_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ligar para emergência',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ..._options.map((option) {
              return ListTile(
                leading: Icon(option.icon),
                title: Text(option.label),
                subtitle: Text(option.number),
                onTap: () async {
                  Navigator.of(context).pop();
                  await PhoneService.call(option.number);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmergencyOption {
  final String label;
  final String number;
  final IconData icon;

  const _EmergencyOption(this.label, this.number, this.icon);
}

Future<void> showEmergencyCallModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const EmergencyCallModal(),
  );
}