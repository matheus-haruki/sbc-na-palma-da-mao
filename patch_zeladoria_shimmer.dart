import 'dart:io';

void main() {
  var file = File('lib/modules/zeladoria/ui/zeladoria_acompanhar_page.dart');
  var content = file.readAsStringSync();

  var importStr = "import 'package:palma_da_mao/core/components/app_empty_state.dart';";
  if (!content.contains("app_shimmer_list.dart")) {
    content = content.replaceFirst(importStr, "\$importStr\\nimport 'package:palma_da_mao/core/components/app_shimmer_list.dart';");
  }

  // Zeladoria uses _isLoading ? ListView.separated(...) : ...
  final regex = RegExp(r'_isLoading\s*\?\s*ListView\.separated\([\s\S]*?;\s*},\s*\)\s*:\s*\(!_foiBuscado\)');
  
  if (regex.hasMatch(content)) {
    content = content.replaceFirst(regex, '''_isLoading
                ? const AppShimmerList(
                    padding: EdgeInsets.all(16),
                  )
                : (!_foiBuscado)''');
    file.writeAsStringSync(content);
    print('Zeladoria patched via regex.');
  } else {
    print('Regex not found in Zeladoria.');
  }
}
