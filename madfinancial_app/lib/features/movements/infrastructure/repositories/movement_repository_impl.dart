import 'package:intl/intl.dart';

import '../../../../core/services/movement_local_dao.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/repositories/movement_repository.dart';
import '../datasources/movement_remote_data_source.dart';
import '../dtos/movement_dto.dart';
import '../dtos/transfer_dto.dart';
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

  @override
  Future<TransferPair> createTransfer(int userId, TransferDraft draft) async {
    final dtos = await _remoteDataSource.createTransfer(_toRequest(userId, draft));
    if (dtos.length < 2) {
      throw const _TransferResponseException();
    }
    final pair = _pair(dtos);
    await _localDao.saveManyMovements([pair.outgoing, pair.incoming]);
    return pair;
  }

  @override
  Future<TransferPair> updateTransfer(
    String transferUuid,
    int userId,
    TransferDraft draft,
  ) async {
    final dtos = await _remoteDataSource.updateTransfer(
      transferUuid,
      _toRequest(userId, draft),
    );
    if (dtos.length < 2) {
      throw const _TransferResponseException();
    }
    final pair = _pair(dtos);
    await _localDao.replaceTransferByUuid(transferUuid, [pair.outgoing, pair.incoming]);
    return pair;
  }

  @override
  Future<void> deleteTransfer(String transferUuid) async {
    await _remoteDataSource.deleteTransfer(transferUuid);
    await _localDao.deleteMovementsByTransferUuid(transferUuid);
  }

  TransferRequestDto _toRequest(int userId, TransferDraft draft) {
    return TransferRequestDto(
      userId: userId,
      amount: draft.amount.abs(),
      accountingDate: DateFormat('yyyy-MM-dd').format(draft.accountingDate),
      title: draft.title,
      description: draft.description,
      accountOutId: draft.accountOut.id,
      accountOutDescription: draft.accountOut.description,
      accountInId: draft.accountIn.id,
      accountInDescription: draft.accountIn.description,
      tags: draft.tags
          .map((t) => {'tag_id': t.id, 'description': t.description})
          .toList(),
    );
  }

  TransferPair _pair(List<MovementDto> dtos) {
    final movements = dtos.map((d) => d.toEntity()).toList();
    final outgoing = movements.firstWhere(
      (m) => m.isOutgoing,
      orElse: () => movements.first,
    );
    final incoming = movements.firstWhere(
      (m) => !m.isOutgoing,
      orElse: () => movements.last,
    );
    return TransferPair(outgoing: outgoing, incoming: incoming);
  }
}

class _TransferResponseException implements Exception {
  const _TransferResponseException();
  @override
  String toString() => 'La API devolvió una respuesta inválida para la transferencia.';
}
