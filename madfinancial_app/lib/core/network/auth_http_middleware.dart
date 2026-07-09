import 'package:dio/dio.dart';

import '../services/session_manager.dart';

class AuthHttpMiddleware extends QueuedInterceptor {
  AuthHttpMiddleware({
    required SessionManager sessionManager,
    required Future<String> Function() refreshToken,
    required Future<void> Function() onTokenRefreshed,
    required Future<void> Function() onSessionExpired,
    required bool Function(String path) isAuthPath,
  })  : _sessionManager = sessionManager,
        _refreshToken = refreshToken,
        _onTokenRefreshed = onTokenRefreshed,
        _onSessionExpired = onSessionExpired,
        _isAuthPath = isAuthPath;

  final SessionManager _sessionManager;
  final Future<String> Function() _refreshToken;
  final Future<void> Function() _onTokenRefreshed;
  final Future<void> Function() _onSessionExpired;
  final bool Function(String path) _isAuthPath;

  Future<String>? _pendingRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthPath(options.path)) {
      return handler.next(options);
    }
    final token = await _sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['authorization'] = token;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final options = err.requestOptions;

    if (statusCode != 401 ||
        options.extra['__retried'] == true ||
        _isAuthPath(options.path)) {
      if (statusCode == 401 || statusCode == 403) {
        await _sessionManager.clearSession();
      }
      return handler.next(err);
    }

    try {
      final newToken = await _getOrStartRefresh();
      if (newToken.isEmpty) {
        await _handleSessionExpired();
        return handler.next(err);
      }
      await _onTokenRefreshed();

      options.extra['__retried'] = true;
      options.headers['authorization'] = newToken;

      final dio = Dio(BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        headers: options.headers,
        responseType: options.responseType,
        contentType: options.contentType,
      ));
      final response = await dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } catch (_) {
      await _handleSessionExpired();
      return handler.next(err);
    }
  }

  Future<String> _getOrStartRefresh() async {
    final pending = _pendingRefresh;
    if (pending != null) return pending;
    final future = _refreshToken().whenComplete(() {
      _pendingRefresh = null;
    });
    _pendingRefresh = future;
    return future;
  }

  Future<void> _handleSessionExpired() async {
    _pendingRefresh = null;
    await _sessionManager.clearSession();
    await _onSessionExpired();
  }
}
