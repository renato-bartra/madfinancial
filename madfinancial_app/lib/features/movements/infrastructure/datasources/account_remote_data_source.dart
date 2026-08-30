import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../dtos/movement_dto.dart';

class AccountRemoteDataSource {
  const AccountRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<AccountDto>> getAll(int userId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.accounts,
        data: {'user_id': userId},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('La API devolvió una respuesta vacía.');
      }
      final code = (data['code'] as num?)?.toInt();
      if (code != null && (code < 200 || code >= 300)) {
        throw ApiException(
          data['message'] as String? ??
              'No se pudieron obtener las cuentas.',
          code: code,
        );
      }
      final body = data['body'];
      if (body is! List) return const [];
      return body
          .map(
            (item) => AccountDto.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
    } on DioException catch (error) {
      throw _mapDioError(error, 'No se pudieron obtener las cuentas.');
    }
  }

  Future<AccountDto> create({
    required int userId,
    required String description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.accounts,
        data: {
          'user_id': userId,
          'account_id': 0,
          'description': description,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('La API devolvió una respuesta vacía.');
      }
      final code = (data['code'] as num?)?.toInt();
      if (code != null && (code < 200 || code >= 300)) {
        throw ApiException(
          data['message'] as String? ?? 'No se pudo crear la cuenta.',
          code: code,
        );
      }
      final body = data['body'];
      if (body is! Map) {
        throw const ApiException('No se pudo crear la cuenta.');
      }
      return AccountDto.fromJson(body.cast<String, dynamic>());
    } on DioException catch (error) {
      throw _mapDioError(error, 'No se pudo crear la cuenta.');
    }
  }

  AppException _mapDioError(DioException error, String defaultMessage) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = (data['code'] as num?)?.toInt() ?? error.response?.statusCode;
      final message = data['message'] as String? ?? error.message;
      if (code == 401 || code == 403) {
        return AuthException(message ?? 'Tu sesión expiró.', code: code);
      }
      return ApiException(message ?? defaultMessage, code: code);
    }
    return NetworkException(
      error.message ?? 'No se pudo conectar con madfinancial_api.',
    );
  }
}
