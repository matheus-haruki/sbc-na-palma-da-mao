import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/components/app_error_modal.dart';

void main() {
  testWidgets('AppErrorModal exibe imagem de erro, título, mensagem e fecha ao clicar em OK', (tester) async {
    bool closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppErrorModal.show(
                    context,
                    onPressed: () => closed = true,
                  );
                },
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Problemas técnicos!'), findsOneWidget);
    expect(
      find.text(
          'Não foi possível enviar sua solicitação. Por favor, verifique sua conexão com a internet e tente novamente mais tarde.'),
      findsOneWidget,
    );
    expect(find.text('OK'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(find.text('Problemas técnicos!'), findsNothing);
  });
}
