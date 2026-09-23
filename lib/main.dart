import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_module.dart';
import 'app_widget.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Supabase.initialize(
    url: 'https://jlpsxevapiuamutiqsdh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpscHN4ZXZhcGl1YW11dGlxc2RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAwMTIxMzYsImV4cCI6MjEwNTU4ODEzNn0.CiHrLazsznqbtqFt3rdGA_gvdIdf3gY40eBLEB8-fs4',
  );

  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
