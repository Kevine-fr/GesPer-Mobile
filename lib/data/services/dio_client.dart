import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../app/config/app_config.dart';
import '../../app/routes/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../services/token_storage.dart';

/// Client HTTP unique de l'application. Branche :
///   - `AuthInterceptor` : ajoute le Bearer + refresh automatique sur 401
///   - `ErrorInterceptor` : convertit les DioException en AppException lisibles
///   - PrettyDioLogger en debug
class DioClient {
  late final Dio dio;
  final TokenStorage _tokens;

  DioClient(this._tokens) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio, _tokens));
    dio.interceptors.add(ErrorInterceptor());
    assert(() {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        compact: true,
        maxWidth: 100,
      ));
      return true;
    }());
  }
}

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio _dio;
  final TokenStorage _tokens;
  bool _refreshing = false;

  AuthInterceptor(this._dio, this._tokens);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final shouldTryRefresh = response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/login') &&
        !err.requestOptions.path.contains('/auth/refresh') &&
        !err.requestOptions.path.contains('/auth/register');

    if (!shouldTryRefresh) return handler.next(err);

    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _logoutAndRedirect();
      return handler.next(err);
    }

    if (_refreshing) {
      // Le retry intervient automatiquement quand la file se débloque.
      return handler.next(err);
    }
    _refreshing = true;

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final refreshResp = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = (refreshResp.data['data'] ?? refreshResp.data) as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String;
      final newRefresh = data['refreshToken'] as String;
      await _tokens.saveTokens(accessToken: newAccess, refreshToken: newRefresh);

      // Rejouer la requête initiale
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';
      final retry = await _dio.fetch(opts);
      return handler.resolve(retry);
    } catch (_) {
      await _logoutAndRedirect();
      return handler.next(err);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _logoutAndRedirect() async {
    await _tokens.clear();
    if (getx.Get.currentRoute != Routes.login) {
      getx.Get.offAllNamed(Routes.login);
    }
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final data = response?.data;

    String message = 'Une erreur est survenue.';
    Map<String, String>? fieldErrors;

    if (data is Map<String, dynamic>) {
      message = (data['message'] as String?) ?? message;
      final rawErrors = data['errors'];
      if (rawErrors is Map<String, dynamic>) {
        fieldErrors = rawErrors.map((k, v) => MapEntry(k, v.toString()));
      }
    }

    final exception = switch (response?.statusCode) {
      400 => ValidationException(message, fieldErrors),
      401 => UnauthorizedException(message),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      409 => ConflictException(message),
      500 => ServerException(message),
      _ => err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.receiveTimeout ||
              err.type == DioExceptionType.connectionError
          ? NetworkException()
          : AppException(message),
    };

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: response,
      error: exception,
      type: err.type,
    ));
  }
}

/// Utilitaire pour extraire l'AppException d'un DioException.
AppException toAppException(Object error) {
  if (error is AppException) return error;
  if (error is DioException) {
    final inner = error.error;
    if (inner is AppException) return inner;
    return NetworkException();
  }
  return AppException(error.toString());
}
