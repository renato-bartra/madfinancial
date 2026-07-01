import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_constants.dart';
import 'auth_session.dart';
import 'local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(ref.watch(localStorageServiceProvider));
});

class SessionManager {
  const SessionManager(this._storage);

  final LocalStorageService _storage;

  Future<AuthSession?> getCurrentSession() => _storage.getSession();

  Future<String?> getToken() async {
    final session = await _storage.getSession();
    return session?.token;
  }

  Future<void> saveSession(AuthSession session) =>
      _storage.saveSession(session);

  Future<void> clearSession() => _storage.clearSession();

  Future<void> markEverRegistered() {
    return _storage.setFlag(StorageConstants.hasEverRegisteredKey, 'true');
  }

  Future<bool> hasEverRegistered() async {
    final value = await _storage.getFlag(StorageConstants.hasEverRegisteredKey);
    return value == 'true';
  }
}
