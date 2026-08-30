import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_constants.dart';
import 'local_storage_service.dart';
import 'session_manager.dart';

class SettingsService {
  const SettingsService(this._storage);

  final LocalStorageService _storage;

  Future<bool> getCarryOverEnabled() => _storage.getCarryOverEnabled();

  Future<void> setCarryOverEnabled(bool value) =>
      _storage.setCarryOverEnabled(value);

  Future<int> getDefaultAccountId() => _storage.getDefaultAccountId();

  Future<void> setDefaultAccountId(int id) => _storage.setDefaultAccountId(id);

  Future<List<int>> getHomeAccountIds() => _storage.getHomeAccountIds();

  Future<void> setHomeAccountIds(List<int> ids) =>
      _storage.setHomeAccountIds(ids);
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(localStorageServiceProvider));
});

class CarryOverEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> hydrate() async {
    final value = await ref.read(settingsServiceProvider).getCarryOverEnabled();
    state = value;
  }

  Future<void> setEnabled(bool value) async {
    await ref.read(settingsServiceProvider).setCarryOverEnabled(value);
    state = value;
  }
}

final carryOverEnabledProvider =
    NotifierProvider<CarryOverEnabledNotifier, bool>(
      CarryOverEnabledNotifier.new,
    );

class DefaultAccountIdNotifier extends Notifier<int> {
  @override
  int build() => StorageConstants.defaultSueldoAccountId;

  Future<void> hydrate() async {
    state = await ref.read(settingsServiceProvider).getDefaultAccountId();
  }

  Future<void> setAccountId(int id) async {
    await ref.read(settingsServiceProvider).setDefaultAccountId(id);
    state = id;
  }
}

final defaultAccountIdProvider =
    NotifierProvider<DefaultAccountIdNotifier, int>(
      DefaultAccountIdNotifier.new,
    );

class HomeAccountIdsNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => List.of(StorageConstants.defaultHomeAccountIds);

  Future<void> hydrate() async {
    state = await ref.read(settingsServiceProvider).getHomeAccountIds();
  }

  Future<void> setAccountIds(List<int> ids) async {
    final deduped = List<int>.from(ids.toSet());
    await ref.read(settingsServiceProvider).setHomeAccountIds(deduped);
    state = deduped;
  }
}

final homeAccountIdsProvider =
    NotifierProvider<HomeAccountIdsNotifier, List<int>>(
      HomeAccountIdsNotifier.new,
    );
