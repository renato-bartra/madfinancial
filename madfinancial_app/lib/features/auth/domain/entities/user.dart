import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
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

  @override
  List<Object?> get props => [id, firstName, lastName, email, dni, image];
}

class RegisterUser extends Equatable {
  const RegisterUser({
    required this.firstName,
    required this.lastName,
    required this.dni,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String dni;
  final String email;
  final String password;

  Map<String, Object?> toApiJson() {
    return {
      'user_id': 0,
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'dni': dni.trim(),
      'email': email.trim(),
      'password': password,
      'active': true,
      'image': '',
    };
  }

  @override
  List<Object?> get props => [firstName, lastName, dni, email, password];
}
