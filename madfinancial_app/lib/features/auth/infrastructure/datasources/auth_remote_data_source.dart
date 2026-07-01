import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserDto> register(RegisterUser user) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.users,
        data: user.toApiJson(),
      );
      final data = _readApiResponse(response.data);
      _ensureSuccess(data);
      return UserDto.fromJson((data['body'] as Map).cast<String, dynamic>());
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.usersLogin,
        data: {'email': email.trim(), 'password': password},
      );
      final data = _readApiResponse(response.data);
      _ensureSuccess(data);
      final dto = LoginResponseDto.fromApiResponse(data);
      if (dto.token.isEmpty) {
        throw const AuthException('La API no devolvió el token de sesión.');
      }
      return dto;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Map<String, dynamic> _readApiResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('La API devolvió una respuesta vacía.');
    }
    return data;
  }

  void _ensureSuccess(Map<String, dynamic> data) {
    final code = (data['code'] as num?)?.toInt();
    if (code != null && code >= 200 && code < 300) return;

    throw ApiException(
      data['message'] as String? ?? 'La API devolvió un error inesperado.',
      code: code,
    );
  }

  AppException _mapDioException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final code =
          (data['code'] as num?)?.toInt() ?? error.response?.statusCode;
      final message = data['message'] as String? ?? error.message;
      if (code == 401 || code == 403 || code == 404) {
        return AuthException(
          message ?? 'No se pudo validar la sesión.',
          code: code,
        );
      }
      return ApiException(message ?? 'Error de API.', code: code);
    }

    return NetworkException(
      error.message ?? 'No se pudo conectar con madfinancial_api.',
    );
  }
}
