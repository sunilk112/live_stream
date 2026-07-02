import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Thin wrapper that configures a single [Dio] instance for the whole app.
/// Data-layer remote data sources depend on this (injected via get_it).
class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = AppConstants.connectTimeout
      ..options.receiveTimeout = AppConstants.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.post<T>(path, data: data, queryParameters: queryParameters);
  }
}
