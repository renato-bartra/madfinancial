import '../../domain/entities/movement.dart';
import '../../domain/repositories/movement_repository.dart';

class GetMovementsByDateUseCase {
  const GetMovementsByDateUseCase(this._repository);

  final MovementRepository _repository;

  Future<List<Movement>> call(DateTime date) => _repository.getByDate(date);
}
