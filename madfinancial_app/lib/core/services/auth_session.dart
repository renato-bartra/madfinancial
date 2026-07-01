import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.token,
    required this.loginAt,
    this.firstName,
    this.lastName,
  });

  final int userId;
  final String email;
  final String token;
  final DateTime loginAt;
  final String? firstName;
  final String? lastName;

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'user_id': userId,
      'email': email,
      'token': token,
      'first_name': firstName,
      'last_name': lastName,
      'login_at': loginAt.millisecondsSinceEpoch,
    };
  }

  factory AuthSession.fromMap(Map<String, Object?> map) {
    return AuthSession(
      userId: (map['user_id'] as num).toInt(),
      email: String.fromCharCodes((map['email'] as String).runes),
      token: String.fromCharCodes((map['token'] as String).runes),
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      loginAt: DateTime.fromMillisecondsSinceEpoch(
        (map['login_at'] as num).toInt(),
      ),
    );
  }

  @override
  List<Object?> get props => [
    userId,
    email,
    token,
    loginAt,
    firstName,
    lastName,
  ];
}
