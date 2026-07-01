import '../entities/movement.dart';

abstract class MovementRepository {
  Future<List<Movement>> getByDate(DateTime date);
}
