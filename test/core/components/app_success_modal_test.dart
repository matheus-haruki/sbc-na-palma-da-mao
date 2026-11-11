import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/components/app_success_modal.dart';

void main() {
  testWidgets('AppSuccessModal renderiza protocolo longo sem overflow', (tester) async {
    // Configura tela compacta (ex: iPhone SE / 360x640)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppSuccessModal.show(
                    context,
                    title: 'Solicitação Enviada!',
                    message: 'Sua solicitação foi registrada com sucesso:',
                    highlightedText: 'SBC-16102026-7K3QX9-EXTRA-LONGO',
                    bottomMessage: 'Aguarde o andamento.',
                    onPressed: () {},
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

    expect(find.text('Solicitação Enviada!'), findsOneWidget);
    expect(find.text('SBC-16102026-7K3QX9-EXTRA-LONGO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
