import 'dart:io';

void main() {
  var file = File('lib/modules/zeladoria/ui/formulario_zeladoria_page.dart');
  var content = file.readAsStringSync();

  // Restore the import of AppInputContainer
  var importStr = "import 'package:palma_da_mao/core/components/app_text_field.dart';";
  var newImportStr = "import 'package:palma_da_mao/core/components/app_input_container.dart';\nimport 'package:palma_da_mao/core/components/app_text_field.dart';";

  if (!content.contains("import 'package:palma_da_mao/core/components/app_input_container.dart';")) {
    content = content.replaceFirst(importStr, newImportStr);
  }

  // Remove AppDropdownField import
  content = content.replaceAll("import 'package:palma_da_mao/core/components/app_dropdown_field.dart';\n", "");

  var searchStr = '''
              _buildLabel('Categoria do Problema'),
              AppDropdownField<int>(
                value: _categoriaId,
                hintText: _isLoadingCategorias
                    ? 'Carregando categorias...'
                    : 'Selecione uma categoria',
                items: _isLoadingCategorias
                    ? []
                    : _categorias.entries.map((e) {
                        return DropdownMenuItem<int>(
                          value: e.key,
                          child: Text(e.value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                onChanged: _isLoadingCategorias
                    ? null
                    : (val) {
                        if (val != null) {
                          setState(() => _categoriaId = val);
                        }
                      },
                validator: (val) => val == null ? 'Selecione uma categoria' : null,
              ),
''';

  var replaceStr = '''
              _buildLabel('Categoria do Problema'),
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
                  menuStyle: MenuStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  dropdownMenuEntries: _isLoadingCategorias
                      ? []
                      : _categorias.entries.map((e) {
                          return DropdownMenuEntry<int>(
                            value: e.key,
                            label: e.value,
                          );
                        }).toList(),
                  onSelected: _isLoadingCategorias
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() => _categoriaId = val);
                          }
                        },
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
