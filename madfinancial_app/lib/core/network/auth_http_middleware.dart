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
  bool _sessionInvalidated = false;

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
      _sessionInvalidated = false;
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

    if (_isAuthPath(options.path)) {
      return handler.next(err);
    }

    final alreadyRetried = options.extra['__retried'] == true;
    if (!alreadyRetried && (statusCode == 401 || statusCode == 403)) {
      final latestToken = (await _sessionManager.getToken()) ?? '';
      final requestToken = options.headers['authorization'] as String? ?? '';

      if (latestToken.isNotEmpty && requestToken != latestToken) {
        return _retryWithToken(options, latestToken, handler);
      }
    }

    if (statusCode == 401 && !alreadyRetried) {
      try {
        final newToken = await _getOrStartRefresh();
        await _onTokenRefreshed();
        options.extra['__retried'] = true;
        options.headers['authorization'] = newToken;
        return _retryWithToken(options, newToken, handler);
      } catch (_) {
        await _handleSessionExpired();
        return handler.next(err);
      }
    }

    if (statusCode == 401 || statusCode == 403) {
      await _handleSessionExpired();
    }
    return handler.next(err);
  }

  Future<void> _retryWithToken(
    RequestOptions options,
    String token,
    ErrorInterceptorHandler handler,
  ) async {
    options.extra['__retried'] = true;
    options.headers['authorization'] = token;
    try {
      final retryDio = Dio(
        BaseOptions(
          baseUrl: options.baseUrl,
          connectTimeout: options.connectTimeout,
          receiveTimeout: options.receiveTimeout,
          headers: options.headers,
          responseType: options.responseType,
          contentType: options.contentType,
        ),
      );
      final response = await retryDio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
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
    if (_sessionInvalidated) return;
    _sessionInvalidated = true;
    _pendingRefresh = null;
    try {
      await _sessionManager.clearSession();
    } catch (_) {}
    try {
      await _onSessionExpired();
    } catch (_) {}
  }
}
