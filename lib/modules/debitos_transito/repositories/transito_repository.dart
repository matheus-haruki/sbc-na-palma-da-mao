import 'package:dio/dio.dart';
import 'package:palma_da_mao/modules/debitos_transito/models/debito_model.dart';
import 'package:palma_da_mao/modules/debitos_transito/models/guia_pagamento_model.dart';

class TransitoRepository {
  final Dio _dio;

  // ===========================================================================
  // TODO: [IMPORTANTE - ANTES DE SUBIR PARA PRODUÇÃO]
  // Lembrar de alterar esta flag para `false` para apontar novamente para os
  // endpoints oficiais de produção da Prefeitura de São Bernardo do Campo!
  // ===========================================================================
  static const bool useHomolog = true;

  // Base URLs
  static const String _prodBaseUrl = 'https://consultadebitos.saobernardo.sp.gov.br/consulta-de-debitos';
  static const String _hmgBaseUrl = 'http://dti-pwebhmg-02:8080/consulta-de-debitos';

  static String get baseUrl => useHomolog ? _hmgBaseUrl : _prodBaseUrl;

  // Códigos de Sistema (Identificação da Aplicação)
  static const String _prodCodigoSistema = '8de4eb61-0c74-46ac-bb0a-e2c7f2609c2e';
  static const String _hmgCodigoSistema = '9a3b5f84-db2e-4c1e-98f7-4a6e9b214c08';

  static String get codigoSistema => useHomolog ? _hmgCodigoSistema : _prodCodigoSistema;

  TransitoRepository(this._dio);

  Future<List<DebitoModel>> consultarDebitos(String cpf) async {
    try {
      // Em Homologação utiliza a rota específica de trânsito; em Produção consulta-lancamentos
      final url = useHomolog
          ? '$baseUrl/sistema-externo/consulta-debitos-de-transito'
          : '$baseUrl/sistema-externo/consulta-lancamentos';

      final response = await _dio.post(
        url,
        data: {
          "cpf": cpf,
          "codigoSistema": codigoSistema,
        },
      );

      // Verifica se a resposta não é nula e aceita formato envelopado ('normal') ou lista direta
      if (response.data != null) {
        List? list;
        if (response.data is Map && response.data['normal'] != null) {
          list = response.data['normal'] as List;
        } else if (response.data is List) {
          list = response.data as List;
        }

        if (list != null) {
          // Filtra multas de trânsito (ou aceita todos caso o endpoint de homolog já traga filtrado)
          return list
              .map((e) => DebitoModel.fromJson(e))
              .where((debito) => debito.tipo == null || debito.tipo == 'M.TRANS')
              .toList();
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
      final url = '$baseUrl/chat-bot/consulta-detalhes-por-lancamento';

      final response = await _dio.post(
        url,
        data: {
          "lancamento": lancamento,
          "codigoSistema": codigoSistema,
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

  Future<GuiaPagamentoModel> gerarBoletoTotal(
    String lancamento, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
  }) async {
    try {
      // Em Homologação utiliza sistema-externo/consulta-boleto; em Produção chat-bot/consulta-boleto
      final url = useHomolog
          ? '$baseUrl/sistema-externo/consulta-boleto'
          : '$baseUrl/chat-bot/consulta-boleto';

      final response = await _dio.post(
        url,
        data: {
          "lancamento": lancamento,
          "codigoSistema": codigoSistema,
        },
      );

      if (response.data != null && response.data is Map) {
        return GuiaPagamentoModel.fromJson(
          response.data as Map<String, dynamic>,
          lancamento: lancamento,
          parcelasDescricao: parcelasDescricao,
          dadosComplementares: dadosComplementares,
        );
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

  Future<GuiaPagamentoModel> gerarBoletoParcela(
    String lancamento, 
    int parcela, {
    Map<String, dynamic>? dadosComplementares,
    String? parcelasDescricao,
    String? valorEstimado,
  }) async {
    try {
      final url = useHomolog
          ? '$baseUrl/sistema-externo/emissao-de-boleto-por-parcela'
          : '$baseUrl/chat-bot/emissao-de-boleto-por-parcela';

      final response = await _dio.post(
        url,
        data: {
          "lancamento": lancamento,
          "parcela": parcela.toString(),
          "codigoSistema": codigoSistema,
        },
      );

      if (response.data != null && response.data is Map) {
        return GuiaPagamentoModel.fromJson(
          response.data as Map<String, dynamic>,
          lancamento: lancamento,
          parcelasDescricao: parcelasDescricao ?? 'Parcela $parcela',
          dadosComplementares: dadosComplementares,
          valorEstimado: valorEstimado,
        );
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

