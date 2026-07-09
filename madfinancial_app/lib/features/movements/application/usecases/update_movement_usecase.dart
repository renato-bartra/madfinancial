import '../../domain/entities/movement.dart';
import '../../domain/repositories/movement_repository.dart';

class UpdateMovementUseCase {
  const UpdateMovementUseCase(this._repository);

  final MovementRepository _repository;

  Future<Movement> call(int oldId, Movement movement) =>
      _repository.update(oldId, movement);
}
