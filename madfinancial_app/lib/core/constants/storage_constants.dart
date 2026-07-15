class StorageConstants {
  const StorageConstants._();

  static const String databaseName = 'madfinancial_app.db';
  static const int databaseVersion = 4;

  static const String authSessionsTable = 'auth_sessions';
  static const String appFlagsTable = 'app_flags';
  static const String hasEverRegisteredKey = 'has_ever_registered';
  static const String carryOverEnabledKey = 'carry_over_enabled';

  static const String movementsTable = 'movements';
  static const String movementTagsTable = 'movement_tags';
  static const String submovementsTable = 'submovements';
  static const String submovementTagsTable = 'submovement_tags';
  static const String categoriesTable = 'categories';
  static const String tagsTable = 'tags';
}
