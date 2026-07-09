import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_factory.dart';
import '../../../../core/services/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/datasources/auth_remote_data_source.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';
import '../usecases/login_usecase.dart';
import '../usecases/register_usecase.dart';
import '../usecases/refresh_token_usecase.dart';

final publicDioProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(createBaseDio());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(publicDioProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionManagerProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionManagerProvider),
  );
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionManagerProvider),
  );
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
