import 'dart:io';

void main() {
  var file = File('lib/modules/zeladoria/ui/formulario_zeladoria_page.dart');
  var content = file.readAsStringSync();

  var searchStr = '''
  Future<void> _selecionarFotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _fotos.addAll(pickedFiles);
        if (_fotos.length > 3) {
          _fotos.removeRange(3, _fotos.length); // Limita a 3 fotos
        }
      });
    }
  }
''';

  var replaceStr = '''
  Future<void> _abrirOpcoesDeFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _tirarFotoCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _selecionarFotosGaleria();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tirarFotoCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _fotos.add(pickedFile);
        if (_fotos.length > 3) {
          _fotos.removeRange(3, _fotos.length);
        }
      });
    }
  }

  Future<void> _selecionarFotosGaleria() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _fotos.addAll(pickedFiles);
        if (_fotos.length > 3) {
          _fotos.removeRange(3, _fotos.length); // Limita a 3 fotos
        }
      });
    }
  }
''';

  if (content.contains(searchStr)) {
    content = content.replaceFirst(searchStr, replaceStr);
    
    // Also change the onTap in the Widget tree:
    content = content.replaceAll('onTap: _selecionarFotos,', 'onTap: _abrirOpcoesDeFoto,');
    
    file.writeAsStringSync(content);
    print('Pacth applied successfully.');
  } else {
    print('String not found.');
  }
}
