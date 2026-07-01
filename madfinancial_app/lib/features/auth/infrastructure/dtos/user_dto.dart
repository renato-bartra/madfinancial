import '../../../../core/services/auth_session.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.firstName,
    required this.email,
    required this.dni,
    this.lastName,
    this.image,
  });

  final int id;
  final String firstName;
  final String? lastName;
  final String email;
  final String dni;
  final String? image;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id:(json['user_id'] as num?)?.toInt() ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String?,
      email: json['email'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      image: json['image'] as String?,
    );
  }
}

class LoginResponseDto {
  const LoginResponseDto({required this.token, required this.user});

  final String token;
  final UserDto user;

  factory LoginResponseDto.fromApiResponse(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['message'] as String? ?? '',
      user: UserDto.fromJson((json['body'] as Map).cast<String, dynamic>()),
    );
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
