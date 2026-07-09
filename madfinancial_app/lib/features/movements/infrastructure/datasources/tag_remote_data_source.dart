import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../dtos/movement_dto.dart';

class TagRemoteDataSource {
  const TagRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TagDto>> getAll(int userId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.tags,
        data: {'user_id': userId},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('La API devolvió una respuesta vacía.');
      }
      final code = (data['code'] as num?)?.toInt();
      if (code != null && (code < 200 || code >= 300)) {
        throw ApiException(
          data['message'] as String? ?? 'No se pudieron obtener los tags.',
          code: code,
        );
      }
      final body = data['body'];
      if (body is! List) return const [];
      return body
          .map(
            (item) => TagDto.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final code = (data['code'] as num?)?.toInt() ?? error.response?.statusCode;
        final message = data['message'] as String? ?? error.message;
        if (code == 401 || code == 403) {
          throw AuthException(message ?? 'Tu sesión expiró.', code: code);
        }
        throw ApiException(
          message ?? 'No se pudieron obtener los tags.',
          code: code,
        );
      }
      throw NetworkException(
        error.message ?? 'No se pudo conectar con madfinancial_api.',
      );
    }
  }

  Future<TagDto> create({
    required int userId,
    required int tagId,
    required String description,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.tags,
        data: {
          'user_id': userId,
          'tag_id': tagId,
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
          data['message'] as String? ?? 'No se pudo crear el tag.',
          code: code,
        );
      }
      final body = data['body'];
      if (body is! Map) {
        throw const ApiException('No se pudo crear el tag.');
      }
      return TagDto.fromJson(body.cast<String, dynamic>());
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final code = (data['code'] as num?)?.toInt() ?? error.response?.statusCode;
        final message = data['message'] as String? ?? error.message;
        if (code == 401 || code == 403) {
          throw AuthException(message ?? 'Tu sesión expiró.', code: code);
        }
        throw ApiException(
          message ?? 'No se pudo crear el tag.',
          code: code,
        );
      }
      throw NetworkException(
        error.message ?? 'No se pudo conectar con madfinancial_api.',
      );
    }
  }
}
