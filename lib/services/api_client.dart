import 'package:dio/dio.dart';
import 'package:onecitizen/config/api_config.dart';
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
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final opts = error.requestOptions;
              final token = await _storageService.getAccessToken();
              opts.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  final StorageService _storageService;
  late final Dio _dio;
  bool _isRefreshing = false;

  Dio get dio => _dio;

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)).post(
        ApiConfig.refreshToken,
        data: {'refresh': refreshToken},
      );

      final access = response.data['access'] as String?;
      if (access != null) {
        await _storageService.saveTokens(accessToken: access);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
