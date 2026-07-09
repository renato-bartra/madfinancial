import '../../domain/entities/movement.dart';
import '../../domain/repositories/movement_repository.dart';

class CreateMovementUseCase {
  const CreateMovementUseCase(this._repository);

  final MovementRepository _repository;

  Future<Movement> call(Movement movement) => _repository.create(movement);
}
