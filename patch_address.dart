import 'dart:io';

void main() {
  var file = File('lib/modules/zeladoria/ui/formulario_zeladoria_page.dart');
  var content = file.readAsStringSync();

  var searchStr = '''
          final partes = <String>[];
          if (place.street != null && place.street!.isNotEmpty) {
            partes.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            partes.add(place.subLocality!);
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            partes.add(place.administrativeArea!);
          }
''';

  var replaceStr = '''
          final partes = <String>[];
          
          // Logradouro e Número
          if (place.street != null && place.street!.isNotEmpty) {
            partes.add(place.street!);
          } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            String rua = place.thoroughfare!;
            if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
              rua += ", \${place.subThoroughfare}";
            }
            partes.add(rua);
          }

          // Bairro
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            partes.add(place.subLocality!);
          }
          
          // Cidade
          if (place.locality != null && place.locality!.isNotEmpty) {
            partes.add(place.locality!);
          } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
            partes.add(place.subAdministrativeArea!);
          }
          
          // UF / Estado
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            partes.add(place.administrativeArea!);
          }
''';

  if (content.contains(searchStr)) {
    content = content.replaceFirst(searchStr, replaceStr);
    file.writeAsStringSync(content);
    print('Pacth applied successfully.');
  } else {
    print('String not found.');
  }
}
