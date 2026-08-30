import '../entities/movement.dart';
import '../entities/transfer.dart';

abstract class MovementRepository {
  Future<List<Movement>> getByDate(DateTime date);
  Future<Movement> create(Movement movement);
  Future<Movement> update(int id, Movement movement);
  Future<void> delete(int id);
  Future<TransferPair> createTransfer(int userId, TransferDraft draft);
  Future<TransferPair> updateTransfer(
    String transferUuid,
    int userId,
    TransferDraft draft,
  );
  Future<void> deleteTransfer(String transferUuid);
}
