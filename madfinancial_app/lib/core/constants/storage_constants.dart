class StorageConstants {
  const StorageConstants._();

  static const String databaseName = 'madfinancial_app.db';
  static const int databaseVersion = 5;

  static const String authSessionsTable = 'auth_sessions';
  static const String appFlagsTable = 'app_flags';
  static const String hasEverRegisteredKey = 'has_ever_registered';
  static const String carryOverEnabledKey = 'carry_over_enabled';
  static const String defaultAccountIdKey = 'default_account_id';
  static const String homeAccountIdsKey = 'home_account_ids';

  static const String movementsTable = 'movements';
  static const String movementTagsTable = 'movement_tags';
  static const String submovementsTable = 'submovements';
  static const String submovementTagsTable = 'submovement_tags';
  static const String categoriesTable = 'categories';
  static const String tagsTable = 'tags';
  static const String accountsTable = 'accounts';

  static const int defaultSueldoAccountId = 1;
  static const int defaultAhorrosAccountId = 2;

  static const List<int> defaultHomeAccountIds = [
    defaultSueldoAccountId,
    defaultAhorrosAccountId,
  ];
}
