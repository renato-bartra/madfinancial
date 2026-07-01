import '../../../../core/services/auth_session.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register(RegisterUser user);

  Future<AuthSession> login({required String email, required String password});
}
