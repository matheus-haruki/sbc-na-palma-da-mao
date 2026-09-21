import 'package:palma_da_mao/core/network/http_client.dart';
import 'package:palma_da_mao/modules/home/models/vacinacao_model.dart';

class VacinacaoRepository {
  final IHttpClient _httpClient;

  VacinacaoRepository(this._httpClient);

  Future<List<VacinacaoModel>> fetchVacinacoes() async {
    // Usando JSONPlaceholder como API mock por enquanto
    final response = await _httpClient.get('https://api-saudesmart-hmg.saobernardo.sp.gov.br/api/v1/vacinacao/sarampo');
    
    // A API retorna a lista diretamente na raiz
    final List<dynamic> data = response as List<dynamic>;

    // Mapeando a resposta para o nosso Model usando o fromJson que já preparamos
    return data.map((json) {
      return VacinacaoModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }
}
