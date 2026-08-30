import '../../../../core/services/movement_local_dao.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../mappers/movement_mapper.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._remoteDataSource, this._localDao);

  final AccountRemoteDataSource _remoteDataSource;
  final MovementLocalDao _localDao;

  @override
  Future<List<Account>> getAll(int userId) async {
    final local = await _localDao.getAllAccounts();
    if (local.isNotEmpty) {
      return local;
    }

    final dtos = await _remoteDataSource.getAll(userId);
    final accounts = dtos.map((dto) => dto.toEntity()).toList();
    if (accounts.isNotEmpty) {
      await _localDao.saveAllAccounts(accounts);
    }
    return accounts;
  }

  @override
  Future<Account> create(int userId, String description) async {
    final dto = await _remoteDataSource.create(
      userId: userId,
      description: description,
    );
    final account = dto.toEntity();
    await _localDao.saveAccount(account);
    return account;
  }
}
