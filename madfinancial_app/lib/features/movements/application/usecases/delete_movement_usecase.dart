import '../../domain/repositories/movement_repository.dart';

class DeleteMovementUseCase {
  const DeleteMovementUseCase(this._repository);

  final MovementRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
