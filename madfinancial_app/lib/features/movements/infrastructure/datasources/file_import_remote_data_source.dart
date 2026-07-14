import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

class FileImportRemoteDataSource {
  const FileImportRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> uploadCsv({
    required String path,
    required String filename,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: filename),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.uploadFiles,
        data: formData,
      );
      _ensureSuccess(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  void _ensureSuccess(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('La API devolvió una respuesta vacía.');
    }
    final code = (data['code'] as num?)?.toInt();
    if (code != null && code >= 200 && code < 300) return;

    final baseMessage =
        data['message'] as String? ?? 'La API devolvió un error inesperado.';
    final body = data['body'];

    if (body is List && body.isNotEmpty) {
      final details = <String>[];
      for (final item in body) {
        if (item is Map) {
          final attribute = item['attribute']?.toString();
          final message = item['message']?.toString();
          if (message != null && message.isNotEmpty) {
            if (attribute != null && attribute.isNotEmpty) {
              details.add('$attribute: $message');
            } else {
              details.add(message);
            }
          }
        }
      }
      if (details.isNotEmpty) {
        throw ApiException('$baseMessage\n${details.join('\n')}', code: code);
      }
    }

    throw ApiException(baseMessage, code: code);
  }

  AppException _mapDioException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code =
          (data['code'] as num?)?.toInt() ?? error.response?.statusCode;
      final message = data['message'] as String? ?? error.message;
      if (code == 401 || code == 403) {
        return AuthException(
          message ?? 'No se pudo validar la sesión.',
          code: code,
        );
      }
      return ApiException(
        message ?? 'No se pudo importar el archivo.',
        code: code,
      );
    }
    return NetworkException(
      error.message ?? 'No se pudo conectar con madfinancial_api.',
    );
  }
}
