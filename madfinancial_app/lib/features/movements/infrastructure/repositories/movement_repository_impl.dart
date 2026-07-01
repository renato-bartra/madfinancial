import '../../domain/entities/movement.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_remote_data_source.dart';
import '../mappers/movement_mapper.dart';

class MovementRepositoryImpl implements MovementRepository {
  const MovementRepositoryImpl(this._remoteDataSource);

  final MovementRemoteDataSource _remoteDataSource;

  @override
  Future<List<Movement>> getByDate(DateTime date) async {
    final dtos = await _remoteDataSource.getByDate(date);
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
