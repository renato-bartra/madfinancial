import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> getAll(int userId);
  Future<Account> create(int userId, String description);
}
