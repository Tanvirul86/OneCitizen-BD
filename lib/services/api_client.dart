import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/services/mock_interceptor.dart';
import 'package:onecitizen/services/storage_service.dart';

class ApiClient {
  ApiClient({required StorageService storageService})
      : _storageService = storageService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(MockInterceptor());
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storageService.clearTokens();
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[API] $obj'),
    ));
  }

  final StorageService _storageService;
  late final Dio _dio;

  Dio get dio => _dio;
}
