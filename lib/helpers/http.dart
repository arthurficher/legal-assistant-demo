import 'package:dio/dio.dart';
import 'package:flutter_gemini/helpers/http_response_helpers.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart' show required;

class Http {
  late Logger _logger;
  late bool _logsEnabled; //para deshabilitar los logs en produccion
  late Dio _dio;

  Http({
    required Dio dio,
    required Logger logger,
    required bool logsEnabled,
  }) {
    _dio = dio;
    _logger = logger;
    _logsEnabled = logsEnabled;
  }

  Future<HttpResponseHelpers<T?>> request<T>(
    String path, {
    String method = "GET",
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.request(
        path,
        options: Options(
          method: method,
          headers: headers,
        ),
        queryParameters: queryParameters,
        data: data,
      );

      _logger.i(response.data);
      if (parser != null) {
        return HttpResponseHelpers.success<T>(parser(response.data));
      }

      return HttpResponseHelpers.success<T>(response.data);
    } catch (e) {
      _logger.e(e);
      int statusCode = 0; //errores internos que no tienen que ver con Dio
      String message = "Error desconocido";
      dynamic data;

      if (e is DioException) {
        statusCode = -1; //
        if (e.message != null) {
          message = e.message!;
          if (e.response != null) {
            statusCode = e.response!.statusCode!;
            message = e.response!.statusMessage!;
            data = e.response!.data;
          }
        }
      }

      return HttpResponseHelpers.fail(
        statusCode: statusCode,
        message: message,
        data: data,
      );
    }
  }
}
