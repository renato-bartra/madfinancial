import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../services/session_manager.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient(ref.watch(sessionManagerProvider)).dio;
});

class DioClient {
  DioClient(this._sessionManager) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['authorization'] = token;
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            await _sessionManager.clearSession();
          }
          handler.next(error);
        },
      ),
    );
  }

  final SessionManager _sessionManager;
  late final Dio _dio;

  Dio get dio => _dio;
}
