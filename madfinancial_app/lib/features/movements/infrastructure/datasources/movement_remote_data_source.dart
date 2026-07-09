import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../dtos/movement_dto.dart';

class MovementRemoteDataSource {
  const MovementRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MovementDto>> getByDate(DateTime date) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.movements,
        data: {'accounting_date': DateFormat('yyyy-MM-dd').format(date)},
      );
      return _parseListResponse(response.data);
    } on DioException catch (error) {
      throw _mapDioError(error, 'No se pudieron obtener los movimientos.');
    }
  }

  Future<MovementDto> create(MovementDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.movements,
        data: dto.toCreateJson(),
      );
      return _parseSingleResponse(response.data, 'No se pudo crear el movimiento.');
    } on DioException catch (error) {
      throw _mapDioError(error, 'No se pudo crear el movimiento.');
    }
  }

  Future<MovementDto> update(int id, MovementDto dto) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '${ApiConstants.movements}$id',
        data: dto.toUpdateJson(),
      );
      return _parseSingleResponse(
        response.data,
        'No se pudo actualizar el movimiento.',
      );
    } on DioException catch (error) {
      throw _mapDioError(error, 'No se pudo actualizar el movimiento.');
    }
  }

  Future<void> delete(int id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '${ApiConstants.movements}$id',
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('La API devolvió una respuesta vacía.');
      }
      final code = (data['code'] as num?)?.toInt();
      if (code != null && (code < 200 || code >= 300)) {
        throw ApiException(
          data['message'] as String? ?? 'No se pudo eliminar el movimiento.',
          code: code,
        );
      }
    } on DioException catch (error) {
      throw _mapDioError(error, 'No se pudo eliminar el movimiento.');
    }
  }

  List<MovementDto> _parseListResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('La API devolvió una respuesta vacía.');
    }
    final code = (data['code'] as num?)?.toInt();
    if (code != null && (code < 200 || code >= 300)) {
      throw ApiException(
        data['message'] as String? ?? 'No se pudieron obtener los movimientos.',
        code: code,
      );
    }
    final body = data['body'];
    if (body is! List) return const [];
    return body
        .map(
          (item) =>
              MovementDto.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  MovementDto _parseSingleResponse(
    Map<String, dynamic>? data,
    String defaultMessage,
  ) {
    if (data == null) {
      throw ApiException(defaultMessage);
    }
    final code = (data['code'] as num?)?.toInt();
    if (code != null && (code < 200 || code >= 300)) {
      throw ApiException(
        data['message'] as String? ?? defaultMessage,
        code: code,
      );
    }
    final body = data['body'];
    if (body is! Map) {
      throw ApiException(defaultMessage);
    }
    return MovementDto.fromJson(body.cast<String, dynamic>());
  }

  AppException _mapDioError(DioException error, String defaultMessage) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code = (data['code'] as num?)?.toInt() ?? error.response?.statusCode;
      final message = data['message'] as String? ?? error.message;
      if (code == 401) {
        return AuthException(message ?? 'Tu sesión expiró.', code: code);
      }
      if (code == 403) {
        return ApiException(message ?? defaultMessage, code: code);
      }
      return ApiException(message ?? defaultMessage, code: code);
    }
    return NetworkException(
      error.message ?? 'No se pudo conectar con madfinancial_api.',
    );
  }
}
