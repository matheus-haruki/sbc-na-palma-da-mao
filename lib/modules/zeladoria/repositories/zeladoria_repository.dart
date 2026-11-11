import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../models/categoria_model.dart';
import '../models/consulta_solicitacoes_response.dart';
import '../models/nova_solicitacao_dto.dart';
import '../models/servico_model.dart';
import '../models/solicitacao_detalhe_model.dart';

class ZeladoriaRepository {
  final Dio _dio;
  final String baseUrl;

  static const String defaultBaseUrl =
      'https://appsbc-api-hmg.saobernardo.sp.gov.br/v1';

  ZeladoriaRepository(this._dio, {this.baseUrl = defaultBaseUrl});

  /// Lista todas as categorias ativas com serviços ativos em ordem alfabética.
  Future<List<CategoriaModel>> listarCategorias() async {
    try {
      final response = await _dio.get('$baseUrl/zeladoria/categorias');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Falha ao listar categorias: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao listar categorias: $e');
    }
  }

  /// Lista os serviços ativos vinculados a uma categoria específica.
  /// Caso a categoria não possua serviços ou não exista, a API responde 404.
  Future<List<ServicoModel>> listarServicosPorCategoria(int categoriaId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/zeladoria/categorias/$categoriaId/servicos',
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => ServicoModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception('Falha ao listar serviços da categoria: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado ao listar serviços: $e');
    }
  }

  /// Envia uma solicitação de zeladoria em multipart/form-data.
  /// Contém duas partes:
  /// - `solicitacao`: JSON com Content-Type application/json.
  /// - `fotos`: 1 a 3 fotos em JPEG (até 5MB cada).
  /// Header: `Idempotency-Key` com UUID v4.
  /// Retorna o protocolo gerado pela API.
  Future<String> enviarSolicitacao({
    required NovaSolicitacaoDto solicitacao,
    required List<File> fotos,
    String? idempotencyKey,
  }) async {
    final uuid = idempotencyKey ?? UuidGenerator.generateV4();

    final formData = FormData();

    // Parte 1: solicitacao (JSON com content-type application/json)
    formData.files.add(
      MapEntry(
        'solicitacao',
        MultipartFile.fromString(
          jsonEncode(solicitacao.toJson()),
          filename: 'solicitacao.json',
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );

    // Parte 2: fotos (1 a 3 imagens JPEG)
    for (final foto in fotos) {
      final fileName = foto.path.split(Platform.pathSeparator).last;
      final safeName = fileName.toLowerCase().endsWith('.jpg') ||
              fileName.toLowerCase().endsWith('.jpeg')
          ? fileName
          : '$fileName.jpg';

      formData.files.add(
        MapEntry(
          'fotos',
          await MultipartFile.fromFile(
            foto.path,
            filename: safeName,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    try {
      final response = await _dio.post(
        '$baseUrl/zeladoria/solicitacoes',
        data: formData,
        options: Options(
          headers: {
            'Idempotency-Key': uuid,
            'accept': 'application/json',
          },
        ),
      );

      if (response.data is Map && response.data['protocolo'] != null) {
        return response.data['protocolo'].toString();
      }
      return response.data.toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(
          'Conflito no envio: Idempotency-Key já utilizada com outro CPF.',
        );
      }
      if (e.response?.statusCode == 415) {
        throw Exception(
          'Erro de formato (415): Parte solicitacao deve ser application/json.',
        );
      }

      String detalheErro = '';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          // Procura por listas de erros em padrões do Spring Boot
          final camposLista = data['campos'] ??
              data['errors'] ??
              data['fieldErrors'] ??
              data['detalhes'] ??
              data['violations'] ??
              data['objects'];

          if (camposLista is List && camposLista.isNotEmpty) {
            detalheErro = camposLista.map((err) {
              if (err is Map) {
                final field = err['nome'] ??
                    err['field'] ??
                    err['campo'] ??
                    err['property'];
                final msg = err['mensagem'] ??
                    err['defaultMessage'] ??
                    err['message'] ??
                    err['userMessage'];
                return field != null ? '$field: $msg' : '$msg';
              }
              return err.toString();
            }).join('\n');
          }

          if (detalheErro.isEmpty) {
            detalheErro = data['detail']?.toString() ??
                data['mensagem']?.toString() ??
                data['message']?.toString() ??
                data['error']?.toString() ??
                '';
          }

          // Se a mensagem for apenas um título genérico, exibe o JSON completo para identificar o campo exato
          if (detalheErro == 'Um ou mais campos são inválidos.' ||
              detalheErro.isEmpty) {
            detalheErro = jsonEncode(data);
          }
        } else if (data is String && data.isNotEmpty) {
          detalheErro = data;
        }
      }

      if (detalheErro.isEmpty) {
        detalheErro = e.message ??
            'Erro desconhecido retornado pelo servidor (Status ${e.response?.statusCode}).';
      }

      throw Exception(detalheErro);
    } catch (e) {
      throw Exception('Erro inesperado ao enviar solicitação: $e');
    }
  }

  /// Consulta solicitações registradas por um munícipe através do CPF.
  /// Paginação padrão: page=0 e size=10.
  Future<ConsultaSolicitacoesResponse> consultarSolicitacoes({
    required String cpfMunicipe,
    int page = 0,
    int size = 10,
  }) async {
    final cpfLimpo = cpfMunicipe.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final response = await _dio.post(
        '$baseUrl/zeladoria/solicitacoes/consulta',
        queryParameters: {
          'page': page,
          'size': size,
        },
        data: {
          'cpfMunicipe': cpfLimpo,
        },
      );

      if (response.statusCode == 204) {
        return ConsultaSolicitacoesResponse(
          content: [],
          pageNumber: page,
          pageSize: size,
          totalElements: 0,
          totalPages: 0,
        );
      }

      if (response.data is Map) {
        return ConsultaSolicitacoesResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Formato de resposta inválido retornado pelo servidor.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 204) {
        return ConsultaSolicitacoesResponse(
          content: [],
          pageNumber: page,
          pageSize: size,
          totalElements: 0,
          totalPages: 0,
        );
      }
      final msg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : e.message;
      throw Exception('Falha ao consultar solicitações: $msg');
    } catch (e) {
      throw Exception('Erro inesperado ao consultar solicitações: $e');
    }
  }

  /// Consulta os detalhes completos de uma solicitação por CPF e protocolo.
  Future<SolicitacaoDetalheModel> consultarDetalheSolicitacao({
    required String cpfMunicipe,
    required String protocolo,
  }) async {
    final cpfLimpo = cpfMunicipe.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final response = await _dio.post(
        '$baseUrl/zeladoria/solicitacoes/consulta/detalhe',
        data: {
          'cpfMunicipe': cpfLimpo,
          'protocolo': protocolo,
        },
      );

      if (response.data is Map) {
        return SolicitacaoDetalheModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Formato de resposta inválido ao consultar detalhe.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : e.message;
      throw Exception('Falha ao consultar detalhes da solicitação: $msg');
    } catch (e) {
      throw Exception('Erro inesperado ao consultar detalhes: $e');
    }
  }

  /// Consulta uma foto específica de uma solicitação por posição (1 a quantidadeFotos).
  Future<Uint8List?> buscarFotoSolicitacao({
    required String cpfMunicipe,
    required String protocolo,
    required int numeroFoto,
  }) async {
    final cpfLimpo = cpfMunicipe.replaceAll(RegExp(r'[^0-9]'), '');

    try {
      final response = await _dio.post(
        '$baseUrl/zeladoria/solicitacoes/consulta/foto',
        data: {
          'cpfMunicipe': cpfLimpo,
          'protocolo': protocolo,
          'numeroFoto': numeroFoto,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'accept': '*/*',
          },
        ),
      );

      final dynamic rawData = response.data;
      if (rawData == null) return null;

      Uint8List bytes;
      if (rawData is Uint8List) {
        bytes = rawData;
      } else if (rawData is List) {
        bytes = Uint8List.fromList(rawData.cast<int>());
      } else {
        return null;
      }

      if (bytes.isEmpty) return null;

      // Se o backend respondeu JSON em vez de imagem binária direta
      final contentType =
          response.headers.value('content-type')?.toLowerCase() ?? '';
      if (contentType.contains('application/json') ||
          contentType.contains('text/plain')) {
        try {
          final jsonStr = utf8.decode(bytes);
          final dynamic decoded = jsonDecode(jsonStr);
          if (decoded is Map) {
            final base64Val = decoded['foto'] ??
                decoded['conteudo'] ??
                decoded['base64'] ??
                decoded['imagem'] ??
                decoded['arquivo'] ??
                decoded['data'];
            if (base64Val is String && base64Val.isNotEmpty) {
              final cleanBase64 = base64Val.contains(',')
                  ? base64Val.split(',').last
                  : base64Val;
              return base64Decode(cleanBase64);
            }
          }
        } catch (_) {
          // Mantém bytes caso não seja JSON decodificável
        }
      }

      return bytes;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      debugPrint(
        'Erro ao buscar foto $numeroFoto da solicitação $protocolo: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Erro inesperado ao buscar foto $numeroFoto: $e');
      return null;
    }
  }

  /// Consulta todas as fotos de uma solicitação realizando requisições paralelas por número/posição.
  Future<List<Uint8List>> buscarFotosSolicitacao({
    required String cpfMunicipe,
    required String protocolo,
    required int quantidadeFotos,
  }) async {
    if (quantidadeFotos <= 0) return [];

    final futures = <Future<Uint8List?>>[];
    for (int i = 1; i <= quantidadeFotos; i++) {
      futures.add(
        buscarFotoSolicitacao(
          cpfMunicipe: cpfMunicipe,
          protocolo: protocolo,
          numeroFoto: i,
        ),
      );
    }

    final resultados = await Future.wait(futures);
    return resultados.whereType<Uint8List>().toList();
  }
}
