import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_storage_service.dart';
import 'session_manager.dart';

class SettingsService {
  const SettingsService(this._storage);

  final LocalStorageService _storage;

  Future<bool> getCarryOverEnabled() => _storage.getCarryOverEnabled();

  Future<void> setCarryOverEnabled(bool value) =>
      _storage.setCarryOverEnabled(value);
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
