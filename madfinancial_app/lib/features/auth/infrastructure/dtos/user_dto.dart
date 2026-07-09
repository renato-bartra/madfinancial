import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/auth_session.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.firstName,
    required this.email,
    required this.dni,
    this.lastName,
    this.image = '',
  });

  final int id;
  final String firstName;
  final String? lastName;
  final String email;
  final String dni;
  final String? image;

  factory UserDto.fromLoginJson(Map<String, dynamic> json) {
    final id = (json['user_id'] as num?)?.toInt();
    if (id == null) {
      throw const AuthException(
        'La respuesta de login no incluye el user_id.',
      );
    }
    final firstName = json['first_name'] as String?;
    final email = json['email'] as String?;
    final dni = json['dni'] as String?;
    if (firstName == null || email == null || dni == null) {
      throw const AuthException(
        'La respuesta de login no incluye los datos del usuario.',
      );
    }
    return UserDto(
      id: id,
      firstName: firstName,
      lastName: json['last_name'] as String?,
      email: email,
      dni: dni,
    );
  }

  factory UserDto.fromRegisterJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    if (id == null) {
      throw const AuthException(
        'La respuesta de registro no incluye el id del usuario.',
      );
    }
    final firstName = json['first_name'] as String?;
    final email = json['email'] as String?;
    final dni = json['dni'] as String?;
    if (firstName == null || email == null || dni == null) {
      throw const AuthException(
        'La respuesta de registro no incluye los datos del usuario.',
      );
    }
    return UserDto(
      id: id,
      firstName: firstName,
      lastName: json['last_name'] as String?,
      email: email,
      dni: dni,
    );
  }
}

class LoginResponseDto {
  const LoginResponseDto({required this.token, required this.user});

  final String token;
  final UserDto user;

  factory LoginResponseDto.fromApiResponse(Map<String, dynamic> json) {
    final token = json['message'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthException('La API no devolvió el token de sesión.');
    }
    final body = json['body'];
    if (body is! Map) {
      throw const AuthException(
        'La respuesta de login no incluye los datos del usuario.',
      );
    }
    final user = UserDto.fromLoginJson(body.cast<String, dynamic>());
    return LoginResponseDto(token: token, user: user);
  }

  AuthSession toSession() {
    return AuthSession(
      userId: user.id,
      email: user.email,
      token: token,
      firstName: user.firstName,
      lastName: user.lastName,
      loginAt: DateTime.now(),
    );
  }
}
