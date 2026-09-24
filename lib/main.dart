import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:palma_da_mao/core/theme/app_theme_controller.dart';

import 'app_module.dart';
import 'app_widget.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await AppThemeController.instance.init();

  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}