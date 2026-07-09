import '../entities/movement.dart';

abstract class MovementRepository {
  Future<List<Movement>> getByDate(DateTime date);
  Future<Movement> create(Movement movement);
  Future<Movement> update(int id, Movement movement);
  Future<void> delete(int id);
}
