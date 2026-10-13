import 'dart:io';

void main() {
  var file = File('lib/modules/debitos_transito/presentational/ui/pages/transito_page.dart');
  var content = file.readAsStringSync();

  var importStr = "import 'package:palma_da_mao/core/components/app_empty_state.dart';";
  if (!content.contains("app_shimmer_list.dart")) {
    content = content.replaceFirst(importStr, "\$importStr\\nimport 'package:palma_da_mao/core/components/app_shimmer_list.dart';");
  }

  // Regex replacement to replace the whole ListView.separated inside TransitoLoading
  final regex = RegExp(r'if \(state is TransitoLoading\) \{\s*return ListView\.separated\([\s\S]*?;\s*\} else if \(state is TransitoError\) \{');
  
  if (regex.hasMatch(content)) {
    content = content.replaceFirst(regex, '''if (state is TransitoLoading) {
                    return const AppShimmerList(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    );
                  } else if (state is TransitoError) {''');
    file.writeAsStringSync(content);
    print('Transito patched via regex.');
  } else {
    print('Regex not found.');
  }
}
