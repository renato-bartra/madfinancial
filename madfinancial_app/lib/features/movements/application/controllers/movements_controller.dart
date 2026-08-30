import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/movement_local_dao.dart';
import '../../../../core/services/settings_service.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/transfer.dart';
import '../providers/movements_providers.dart';
import '../usecases/dummy_movements.dart';

class MovementsState extends Equatable {
  const MovementsState({
    required this.month,
    this.movements = const [],
    this.isLoading = false,
    this.usingDummyData = false,
    this.errorMessage,
    this.carryOver = 0,
  });

  factory MovementsState.initial() {
    final now = DateTime.now();
    return MovementsState(month: DateTime(now.year, now.month));
  }

  final DateTime month;
  final List<Movement> movements;
  final bool isLoading;
  final bool usingDummyData;
  final String? errorMessage;
  final double carryOver;

  double get totalIncome {
    return movements
        .where((movement) => movement.signedAmount > 0)
        .fold(0, (sum, movement) => sum + movement.signedAmount);
  }

  double get totalExpense {
    return movements
        .where((movement) => movement.signedAmount < 0)
        .fold(0, (sum, movement) => sum + movement.signedAmount.abs());
  }

  double get balance => totalIncome - totalExpense + carryOver;

  MovementsState copyWith({
    DateTime? month,
    List<Movement>? movements,
    bool? isLoading,
    bool? usingDummyData,
    String? errorMessage,
    bool clearError = false,
    double? carryOver,
  }) {
    return MovementsState(
      month: month ?? this.month,
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
      usingDummyData: usingDummyData ?? this.usingDummyData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      carryOver: carryOver ?? this.carryOver,
    );
  }

  @override
  List<Object?> get props => [
    month,
    movements,
    isLoading,
    usingDummyData,
    errorMessage,
    carryOver,
  ];
}

class MovementsController extends Notifier<MovementsState> {
  late final MovementLocalDao _localDao;

  @override
  MovementsState build() {
    _localDao = ref.read(movementLocalDaoProvider);
    return MovementsState.initial();
  }

  Future<void> loadCurrentMonth() => loadForMonth(state.month);

  Future<void> loadForMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    state = state.copyWith(
      month: normalizedMonth,
      isLoading: true,
      clearError: true,
    );
    final homeIds = ref.read(homeAccountIdsProvider).toSet();
    try {
      final local = await _localDao.getMovementsByMonth(
        normalizedMonth,
        accountIds: homeIds,
      );
      if (local.isNotEmpty) {
        final carryOver = await _computeCarryOver(
          normalizedMonth,
          accountIds: homeIds,
        );
        state = state.copyWith(
          movements: local,
          isLoading: false,
          usingDummyData: false,
          carryOver: carryOver,
        );
        return;
      }

      if (homeIds.isEmpty) {
        final carryOver = await _computeCarryOver(
          normalizedMonth,
          accountIds: homeIds,
        );
        state = state.copyWith(
          movements: const [],
          isLoading: false,
          usingDummyData: false,
          carryOver: carryOver,
        );
        return;
      }

      final apiMovements = await ref
          .read(getMovementsByDateUseCaseProvider)
          .call(normalizedMonth);

      if (apiMovements.isNotEmpty) {
        await _localDao.saveManyMovements(apiMovements);
      }

      final firstDayOfMonth = DateTime(
        normalizedMonth.year,
        normalizedMonth.month,
        1,
      );
      final firstDayOfNextMonth = DateTime(
        normalizedMonth.year,
        normalizedMonth.month + 1,
        1,
      );
      final forCurrentMonth = apiMovements.where((m) {
        if (m.accountingDate.isBefore(firstDayOfMonth) ||
            !m.accountingDate.isBefore(firstDayOfNextMonth)) {
          return false;
        }
        return homeIds.contains(m.account.id);
      }).toList();
      final carryOver = await _computeCarryOver(
        normalizedMonth,
        accountIds: homeIds,
      );
      state = state.copyWith(
        movements: forCurrentMonth,
        isLoading: false,
        usingDummyData: false,
        carryOver: carryOver,
      );
    } on AuthException catch (error) {
      final carryOver = await _computeCarryOver(
        normalizedMonth,
        accountIds: homeIds,
      );
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: error.message,
        carryOver: carryOver,
      );
    } on AppException catch (error) {
      final carryOver = await _computeCarryOver(
        normalizedMonth,
        accountIds: homeIds,
      );
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: error.message,
        carryOver: carryOver,
      );
    } catch (_) {
      final carryOver = await _computeCarryOver(
        normalizedMonth,
        accountIds: homeIds,
      );
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: 'No se pudieron cargar los movimientos.',
        carryOver: carryOver,
      );
    }
  }

  Future<double> _computeCarryOver(
    DateTime month, {
    required Set<int> accountIds,
  }) async {
    final carryOverEnabled = await ref
        .read(settingsServiceProvider)
        .getCarryOverEnabled();
    if (!carryOverEnabled) return 0;
    if (accountIds.isEmpty) return 0;
    return _localDao.getBalanceBeforeMonth(
      month,
      accountIds: accountIds,
    );
  }

  Future<void> previousMonth() {
    return loadForMonth(DateTime(state.month.year, state.month.month - 1));
  }

  Future<void> nextMonth() {
    return loadForMonth(DateTime(state.month.year, state.month.month + 1));
  }

  Future<Movement> create(Movement movement) async {
    final created = await ref.read(createMovementUseCaseProvider).call(movement);
    if (_isInCurrentMonth(created) &&
        _isInHomeFilter(created.account.id)) {
      _insertInOrder(created);
    }
    return created;
  }

  Future<Movement> update(int oldId, Movement movement) async {
    final updated = await ref
        .read(updateMovementUseCaseProvider)
        .call(oldId, movement);
    final filtered = state.movements
        .where((m) => m.id != oldId)
        .toList();
    if (_isInCurrentMonth(updated) &&
        _isInHomeFilter(updated.account.id)) {
      filtered.add(updated);
      filtered.sort(_compareMovements);
    }
    state = state.copyWith(movements: filtered);
    return updated;
  }

  Future<void> delete(int id) async {
    await ref.read(deleteMovementUseCaseProvider).call(id);
    final filtered = state.movements.where((m) => m.id != id).toList();
    state = state.copyWith(movements: filtered);
  }

  Future<TransferPair> createTransfer(TransferDraft draft) async {
    final pair = await ref.read(createTransferUseCaseProvider).call(draft);
    final homeIds = ref.read(homeAccountIdsProvider).toSet();
    if (homeIds.isEmpty) {
      return pair;
    }
    final homeMembers = <Movement>[];
    if (homeIds.contains(pair.outgoing.account.id) &&
        _isInCurrentMonth(pair.outgoing)) {
      homeMembers.add(pair.outgoing);
    }
    if (homeIds.contains(pair.incoming.account.id) &&
        _isInCurrentMonth(pair.incoming)) {
      homeMembers.add(pair.incoming);
    }
    if (homeMembers.isEmpty) return pair;
    final merged = [...state.movements, ...homeMembers]..sort(_compareMovements);
    state = state.copyWith(movements: merged);
    return pair;
  }

  Future<TransferPair> updateTransfer(
    String transferUuid,
    TransferDraft draft,
  ) async {
    final pair = await ref
        .read(updateTransferUseCaseProvider)
        .call(transferUuid, draft);
    final filtered = state.movements
        .where((m) => m.transferUuid != transferUuid)
        .toList();
    final homeIds = ref.read(homeAccountIdsProvider).toSet();
    if (homeIds.isEmpty) {
      state = state.copyWith(movements: filtered);
      return pair;
    }
    final members = <Movement>[];
    if (homeIds.contains(pair.outgoing.account.id) &&
        _isInCurrentMonth(pair.outgoing)) {
      members.add(pair.outgoing);
    }
    if (homeIds.contains(pair.incoming.account.id) &&
        _isInCurrentMonth(pair.incoming)) {
      members.add(pair.incoming);
    }
    filtered.addAll(members);
    filtered.sort(_compareMovements);
    state = state.copyWith(movements: filtered);
    return pair;
  }

  Future<void> deleteTransfer(String transferUuid) async {
    await ref.read(deleteTransferUseCaseProvider).call(transferUuid);
    final filtered = state.movements
        .where((m) => m.transferUuid != transferUuid)
        .toList();
    state = state.copyWith(movements: filtered);
  }

  Future<List<Movement>> loadTransferPair(String transferUuid) async {
    return _localDao.getMovementsByTransferUuid(transferUuid);
  }

  bool _isInCurrentMonth(Movement movement) {
    return movement.accountingDate.year == state.month.year &&
        movement.accountingDate.month == state.month.month;
  }

  bool _isInHomeFilter(int accountId) {
    final homeIds = ref.read(homeAccountIdsProvider).toSet();
    return homeIds.contains(accountId);
  }

  void _insertInOrder(Movement movement) {
    final updated = [...state.movements, movement]..sort(_compareMovements);
    state = state.copyWith(movements: updated);
  }

  int _compareMovements(Movement a, Movement b) {
    final byDate = b.accountingDate.compareTo(a.accountingDate);
    if (byDate != 0) return byDate;
    return b.id.compareTo(a.id);
  }
}
