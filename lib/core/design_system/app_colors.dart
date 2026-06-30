import 'package:flutter/material.dart';

abstract class AppColors {
  // Cores de Marca 
  static const Color primary = Color(0xFFFF8200); 
  static const Color secondary = Color(0xFF1F3A5F);

  // Cores de Fundo e Superfície
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);

  // Cores de Texto
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);

  // Cores de Feedback (Erros, Sucesso, Alertas)
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFFFC107);
}