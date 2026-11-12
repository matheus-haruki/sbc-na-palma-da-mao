import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/components/app_error_state.dart';

void main() {
  testWidgets('AppErrorState exibe somente a imagem e o texto', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppErrorState(),
        ),
      ),
    );

    expect(
      find.text('Problemas técnicos! Por favor, tente novamente mais tarde.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });
}
