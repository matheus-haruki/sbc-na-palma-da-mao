import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';
import 'package:palma_da_mao/core/design_system/app_assets.dart';
import 'package:palma_da_mao/core/design_system/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  void _goToNextRoute() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Modular.to.navigate('/main/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.logo, width: 200),
            Lottie.asset(
              AppAssets.loadingAnimation,
              width: 80,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, _goToNextRoute);
              },
              errorBuilder: (context, error, stackTrace) {
                Future.delayed(const Duration(seconds: 2), _goToNextRoute);
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
