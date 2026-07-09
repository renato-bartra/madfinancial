import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api/v1';
    }
    return 'http://localhost:4000/api/v1';
  }

  static const String users = '/users';
  static const String usersLogin = '/users/login';
  static const String usersRefresh = '/users/refresh';
  static const String movements = '/movements/';
  static const String categories = '/categories/';
  static const String tags = '/tags/';
  static const String accounts = '/accounts/';
}
