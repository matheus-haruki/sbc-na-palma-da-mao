import 'dart:io';

void main() {
  var file = File('lib/modules/zeladoria/ui/formulario_zeladoria_page.dart');
  var content = file.readAsStringSync();

  var searchStr = '''
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _limparFormulario();
                },
                child: const Text('OK'),
              ),
''';

  var replaceStr = '''
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o modal de sucesso
                  Navigator.pop(context); // Volta para a ZeladoriaHomePage
                },
                child: const Text('OK'),
              ),
''';

  if (content.contains(searchStr)) {
    content = content.replaceFirst(searchStr, replaceStr);
    file.writeAsStringSync(content);
    print('Pacth applied successfully.');
  } else {
    print('String not found.');
  }
}
