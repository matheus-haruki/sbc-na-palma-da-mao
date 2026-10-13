import 'dart:io';

void main() {
  var file = File('lib/modules/iptu/presentational/ui/pages/iptu_page.dart');
  var content = file.readAsStringSync();

  var importStr = "import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_state.dart';";
  if (!content.contains("app_shimmer_list.dart")) {
    content = content.replaceFirst(importStr, "\$importStr\\nimport 'package:palma_da_mao/core/components/app_shimmer_list.dart';");
  }

  // IPTU currently uses CircularProgressIndicator
  final regex = RegExp(r'if \(state is IptuLoading\) \{\s*return const Center\(child: CircularProgressIndicator\(\)\);\s*\}');
  
  if (regex.hasMatch(content)) {
    content = content.replaceFirst(regex, '''if (state is IptuLoading) {
                    return const AppShimmerList(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    );
                  }''');
    file.writeAsStringSync(content);
    print('IPTU patched via regex.');
  } else {
    print('Regex not found in IPTU.');
  }
}
