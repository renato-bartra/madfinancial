import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/auth_session.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_providers.dart';

enum AuthStatus { initial, loading, authenticated, registered, error }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.session,
    this.registeredUser,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final AuthSession? session;
  final User? registeredUser;
  final String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    User? registeredUser,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      registeredUser: registeredUser ?? this.registeredUser,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, registeredUser, errorMessage];
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final session = await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, session: session);
      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No se pudo iniciar sesión.',
      );
      return false;
    }
  }

  Future<bool> register(RegisterUser user) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final registeredUser = await ref.read(registerUseCaseProvider).call(user);
      state = AuthState(
        status: AuthStatus.registered,
        registeredUser: registeredUser,
      );
      return true;
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No se pudo crear el usuario.',
      );
      return false;
    }
  }
}
