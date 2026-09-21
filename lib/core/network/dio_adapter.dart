import 'package:dio/dio.dart';
import 'http_client.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

class DioAdapter implements IHttpClient {
  final Dio _dio;

  DioAdapter(this._dio);

  Exception _handleError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return NetworkException('Tempo limite de conexão excedido.');
      }
      String? errorMessage;
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'];
      }
      return NetworkException(
        errorMessage ?? e.message ?? 'Erro na requisição',
        e.response?.statusCode,
      );
    }
    return NetworkException('Erro desconhecido: $e');
  }

  @override
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<dynamic> post(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(url, data: data, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<dynamic> put(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(url, data: data, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<dynamic> delete(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(url, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
}
