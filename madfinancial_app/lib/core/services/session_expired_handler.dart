import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/app_navigation.dart';
import 'session_manager.dart';

class SessionExpiredHandler {
  const SessionExpiredHandler(this._sessionManager);

  final SessionManager _sessionManager;

  static const String message =
      'El token a expirado, por favor volver a ingresar al app';

  Future<void> handle() async {
    await _sessionManager.clearSession();

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil('/login', (_) => false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = appScaffoldMessengerKey.currentState;
      if (messenger == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(message),
            duration: Duration(seconds: 6),
          ),
        );
    });
  }
}

final sessionExpiredHandlerProvider = Provider<SessionExpiredHandler>((ref) {
  return SessionExpiredHandler(ref.watch(sessionManagerProvider));
});
