import 'package:flutter/material.dart';

abstract class AppColors {
  // Cores de Marca
  static const Color primary = Color(0xFFFF8200);
  static const Color secondary = Color(0xFF1F3A5F);

  // Cores de Fundo e Superfície
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color backgroundBlue = Color(0xFFEEF4FD);
  static const Color darkBlue = Color(0xFF003E6F);
  static const Color shadow = Color(0x0C000000);

  // Cores de Texto
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLabel = Color(0xFF151C22);

  // Cores de Feedback (Erros, Sucesso, Alertas)
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFFFC107);
}
