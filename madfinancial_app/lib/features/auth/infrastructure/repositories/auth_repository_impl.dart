import '../../../../core/services/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<User> register(RegisterUser user) async {
    final dto = await _remoteDataSource.register(user);
    return dto.toEntity();
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final dto = await _remoteDataSource.login(email: email, password: password);
    return dto.toSession();
  }
}
