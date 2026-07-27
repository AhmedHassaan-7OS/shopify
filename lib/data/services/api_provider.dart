import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';

class ApiProvider {
  ApiProvider({Dio? dio, bool enableLogging = true}) : _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.timeout,
      sendTimeout: ApiConstants.timeout,
      receiveTimeout: ApiConstants.timeout,
      responseType: ResponseType.json,
      headers: const <String, dynamic>{'Accept': 'application/json'},
    );
    if (enableLogging) {
      _dio.interceptors.add(_loggingInterceptor());
    }
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Interceptor _loggingInterceptor() => InterceptorsWrapper(
    onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      developer.log(
        '→ ${options.method} ${options.path} '
        'params=${options.queryParameters}',
        name: _logName,
      );
      handler.next(options);
    },
    onResponse:
        (Response<dynamic> response, ResponseInterceptorHandler handler) {
          developer.log(
            '← ${response.statusCode} '
            '${response.requestOptions.path}',
            name: _logName,
          );
          handler.next(response);
        },
    onError: (DioException error, ErrorInterceptorHandler handler) {
      developer.log(
        '✕ ${error.type.name} ${error.requestOptions.path} '
        'status=${error.response?.statusCode}',
        name: _logName,
      );
      handler.next(error);
    },
  );

  static const String _logName = 'ApiProvider';
}
