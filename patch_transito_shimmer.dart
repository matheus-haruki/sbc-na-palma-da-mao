import 'dart:io';

void main() {
  var file = File('lib/modules/debitos_transito/presentational/ui/pages/transito_page.dart');
  var content = file.readAsStringSync();

  var importStr = "import 'package:palma_da_mao/core/components/app_empty_state.dart';";
  if (!content.contains("app_shimmer_list.dart")) {
    content = content.replaceFirst(importStr, "\$importStr\\nimport 'package:palma_da_mao/core/components/app_shimmer_list.dart';");
  }

  var searchLoading = '''
                  if (state is TransitoLoading) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 150,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 100,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 120,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
''';

  var replaceLoading = '''
                  if (state is TransitoLoading) {
                    return const AppShimmerList(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    );
                  }
''';

  if (content.contains(searchLoading)) {
    content = content.replaceFirst(searchLoading, replaceLoading);
    file.writeAsStringSync(content);
    print('Transito patched.');
  } else {
    print('Transito shimmer search string not found.');
  }
}
