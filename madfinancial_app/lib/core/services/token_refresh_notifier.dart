import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notifyRefreshed() {
    state = state + 1;
  }
}

final tokenRefreshNotifierProvider =
    NotifierProvider<TokenRefreshNotifier, int>(TokenRefreshNotifier.new);
