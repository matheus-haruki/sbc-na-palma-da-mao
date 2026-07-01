import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppBrowserNavigator {
  static Future<void> openWebPage({
    required BuildContext context,
    required String urlString,
  }) async {
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppBrowserView, 
          browserConfiguration: const BrowserConfiguration(showTitle: true),
        );
      } else {
        throw 'Não foi possível abrir a página: $urlString';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir o serviço: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}


//TODO: Autorizar abertura de navegador externo para serviços web para o ios no info.plist

