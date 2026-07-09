import '../../../../core/services/movement_local_dao.dart';
import '../../domain/entities/movement.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_remote_data_source.dart';
import '../mappers/movement_mapper.dart';

class MovementRepositoryImpl implements MovementRepository {
  const MovementRepositoryImpl(this._remoteDataSource, this._localDao);

  final MovementRemoteDataSource _remoteDataSource;
  final MovementLocalDao _localDao;

  @override
  Future<List<Movement>> getByDate(DateTime date) async {
    final dtos = await _remoteDataSource.getByDate(date);
    final movements = dtos.map((dto) => dto.toEntity()).toList();
    return movements;
  }

  @override
  Future<Movement> create(Movement movement) async {
    final dto = await _remoteDataSource.create(movement.toDto());
    final saved = dto.toEntity();
    await _localDao.saveMovement(saved);
    return saved;
  }

  @override
  Future<Movement> update(int id, Movement movement) async {
    final dto = await _remoteDataSource.update(id, movement.toDto());
    final saved = dto.toEntity();
    await _localDao.replaceMovement(id, saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    await _remoteDataSource.delete(id);
    await _localDao.deleteMovement(id);
  }
}
