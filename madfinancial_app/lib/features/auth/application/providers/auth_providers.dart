import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/session_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/datasources/auth_remote_data_source.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';
import '../usecases/login_usecase.dart';
import '../usecases/register_usecase.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
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

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
