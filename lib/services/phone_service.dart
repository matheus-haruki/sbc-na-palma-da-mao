import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  static Future<bool> call(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(telUri)) {
        return await launchUrl(telUri);
      } else {
        debugPrint('Não foi possível abrir o discador para $phoneNumber');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao tentar ligar: $e');
      return false;
    }
  }
}
