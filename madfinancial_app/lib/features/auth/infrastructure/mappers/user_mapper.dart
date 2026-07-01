import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';

extension UserMapper on UserDto {
  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      dni: dni,
      image: image,
    );
  }
}
