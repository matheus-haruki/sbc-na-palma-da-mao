import 'package:dio/dio.dart';
import '../models/bairro_model.dart';
import '../models/endereco_cep_model.dart';

class EnderecoRepository {
  final Dio _dio;
  final String baseUrl;

  static const String defaultBaseUrl =
      'https://appsbc-api-hmg.saobernardo.sp.gov.br/v1';

  EnderecoRepository(this._dio, {this.baseUrl = defaultBaseUrl});

  /// Consulta os dados de endereço pelo CEP informado (8 dígitos).
  Future<EnderecoCepModel?> consultarCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) return null;

    try {
      final response = await _dio.get(
        '$baseUrl/endereco/ceps/$cepLimpo',
        options: Options(headers: {'accept': 'application/json'}),
      );
      if (response.data != null && response.data is Map) {
        return EnderecoCepModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Falha ao consultar CEP: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao consultar CEP: $e');
    }
  }

  /// Busca lista de bairros por nome para autocomplete.
  Future<List<BairroModel>> buscarBairros(String nome) async {
    try {
      final response = await _dio.get(
        '$baseUrl/endereco/bairros',
        queryParameters: {'nome': nome},
        options: Options(headers: {'accept': 'application/json'}),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((e) => BairroModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Falha ao buscar bairros: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao buscar bairros: $e');
    }
  }
}
