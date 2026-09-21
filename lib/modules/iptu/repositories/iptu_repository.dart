import 'package:dio/dio.dart';
import 'package:palma_da_mao/modules/iptu/models/debito_model.dart';
import 'package:palma_da_mao/modules/iptu/models/guia_pagamento_model.dart';

class IptuRepository {
  final Dio _dio;

  IptuRepository(this._dio);

  Future<List<DebitoModel>> consultarDebitos(String cpf) async {
    try {
      final response = await _dio.post(
        'http://10.1.0.240:8080/consulta-de-debitos/chat-bot/consulta-debitos-de-iptu',
        data: {
          "cpf": cpf,
          "codigoSistema": "7f3a91c4-8b27-11f1-a6d2-3e5c9b71f804",
        },
      );

      // Verifica se a resposta não é nula e se é um Map (JSON válido)
      if (response.data != null && response.data is Map) {
        if (response.data['normal'] != null) {
          final list = response.data['normal'] as List;
          return list.map((e) => DebitoModel.fromJson(e)).toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Servidor indisponível (Erro 500). Tente novamente mais tarde.');
      }
      throw Exception('Falha na comunicação com o servidor: ${e.message}');
    } catch (e) {
      throw Exception('Formato de resposta inválido ou erro inesperado.');
    }
  }

  Future<Map<String, dynamic>> consultarDetalhes(String lancamento) async {
    try {
      final response = await _dio.post(
        'http://10.1.0.240:8080/consulta-de-debitos/chat-bot/consulta-detalhes-por-lancamento',
        data: {
          "lancamento": lancamento,
          "codigoSistema": "7f3a91c4-8b27-11f1-a6d2-3e5c9b71f804",
        },
      );

      if (response.data != null && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      
      throw Exception('Resposta vazia');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Servidor indisponível (Erro 500). Tente novamente mais tarde.');
      }
      throw Exception('Falha na comunicação com o servidor: ${e.message}');
    } catch (e) {
      throw Exception('Formato de resposta inválido ou erro inesperado.');
    }
  }

  Future<GuiaPagamentoModel> gerarBoletoTotal(String lancamento) async {
    try {
      final response = await _dio.post(
        'http://10.1.0.240:8080/consulta-de-debitos/chat-bot/consulta-boleto',
        data: {
          "lancamento": lancamento,
          "codigoSistema": "7f3a91c4-8b27-11f1-a6d2-3e5c9b71f804",
        },
      );

      if (response.data != null && response.data is Map) {
        return GuiaPagamentoModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Resposta vazia da guia de pagamento.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Servidor indisponível ao gerar a guia total.');
      }
      throw Exception('Falha ao gerar guia total: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar guia de pagamento.');
    }
  }

  Future<GuiaPagamentoModel> gerarBoletoParcela(String lancamento, int parcela) async {
    try {
      final response = await _dio.post(
        'http://10.1.0.240:8080/consulta-de-debitos/chat-bot/emissao-de-boleto-por-parcela',
        data: {
          "lancamento": lancamento,
          "parcela": parcela.toString(),
          "codigoSistema": "7f3a91c4-8b27-11f1-a6d2-3e5c9b71f804",
        },
      );

      if (response.data != null && response.data is Map) {
        return GuiaPagamentoModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Resposta vazia do boleto específico.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Servidor indisponível ao gerar o boleto da parcela.');
      }
      throw Exception('Falha ao gerar boleto: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar boleto específico.');
    }
  }
}

