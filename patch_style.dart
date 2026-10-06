import 'dart:io';

void main() {
  var file = File('lib/modules/zeladoria/ui/formulario_zeladoria_page.dart');
  var content = file.readAsStringSync();

  var searchStr = '''
              AppInputContainer(
                child: DropdownMenu<int>(
                  initialSelection: _categoriaId,
                  expandedInsets: EdgeInsets.zero,
                  hintText: _isLoadingCategorias
                      ? 'Carregando categorias...'
                      : 'Selecione uma categoria',
                  textStyle: const TextStyle(fontSize: 16),
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
''';

  var replaceStr = '''
              AppInputContainer(
                child: DropdownMenu<int>(
                  initialSelection: _categoriaId,
                  expandedInsets: EdgeInsets.zero,
                  hintText: _isLoadingCategorias
                      ? 'Carregando categorias...'
                      : 'Selecione uma categoria',
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16) ?? const TextStyle(fontSize: 16),
                  inputDecorationTheme: InputDecorationTheme(
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
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
