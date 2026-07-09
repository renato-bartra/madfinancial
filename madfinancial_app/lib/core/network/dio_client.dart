import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/providers/auth_providers.dart';
import '../services/session_expired_handler.dart';
import '../services/session_manager.dart';
import '../services/token_refresh_notifier.dart';
import 'auth_http_middleware.dart';
import 'dio_factory.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = createBaseDio();
  dio.interceptors.add(
    AuthHttpMiddleware(
      sessionManager: ref.watch(sessionManagerProvider),
      refreshToken: () => ref.read(refreshTokenUseCaseProvider).call(),
      onTokenRefreshed: () async {
        ref.read(tokenRefreshNotifierProvider.notifier).notifyRefreshed();
      },
      onSessionExpired: () =>
          ref.read(sessionExpiredHandlerProvider).handle(),
      isAuthPath: _isAuthPath,
    ),
  );
  return dio;
});

bool _isAuthPath(String path) {
  return path.endsWith('/users/login') ||
      path.endsWith('/users/refresh') ||
      path.endsWith('/users') ||
      path.endsWith('/users/');
}
