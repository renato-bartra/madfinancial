import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/movement_local_dao.dart';
import '../../../../core/services/settings_service.dart';
import '../../domain/entities/movement.dart';
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
    try {
      final local = await _localDao.getMovementsByMonth(normalizedMonth);
      if (local.isNotEmpty) {
        final carryOver = await _computeCarryOver(normalizedMonth);
        state = state.copyWith(
          movements: local,
          isLoading: false,
          usingDummyData: false,
          carryOver: carryOver,
        );
        return;
      }

      final apiMovements = await ref
          .read(getMovementsByDateUseCaseProvider)
          .call(normalizedMonth);

      if (apiMovements.isEmpty) {
        final carryOver = await _computeCarryOver(normalizedMonth);
        state = state.copyWith(
          movements: const [],
          isLoading: false,
          usingDummyData: false,
          carryOver: carryOver,
        );
        return;
      }

      await _localDao.saveManyMovements(apiMovements);
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
        return !m.accountingDate.isBefore(firstDayOfMonth) &&
            m.accountingDate.isBefore(firstDayOfNextMonth);
      }).toList();
      final carryOver = await _computeCarryOver(normalizedMonth);
      state = state.copyWith(
        movements: forCurrentMonth,
        isLoading: false,
        usingDummyData: false,
        carryOver: carryOver,
      );
    } on AuthException catch (error) {
      final carryOver = await _computeCarryOver(normalizedMonth);
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: error.message,
        carryOver: carryOver,
      );
    } on AppException catch (error) {
      final carryOver = await _computeCarryOver(normalizedMonth);
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: error.message,
        carryOver: carryOver,
      );
    } catch (_) {
      final carryOver = await _computeCarryOver(normalizedMonth);
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: 'No se pudieron cargar los movimientos.',
        carryOver: carryOver,
      );
    }
  }

  Future<double> _computeCarryOver(DateTime month) async {
    final carryOverEnabled = await ref
        .read(settingsServiceProvider)
        .getCarryOverEnabled();
    if (!carryOverEnabled) return 0;
    final prevMonth = DateTime(month.year, month.month - 1);
    final prevMovements = await _localDao.getMovementsByMonth(prevMonth);
    return prevMovements.fold<double>(0, (sum, m) => sum + m.signedAmount);
  }

  Future<void> previousMonth() {
    return loadForMonth(DateTime(state.month.year, state.month.month - 1));
  }

  Future<void> nextMonth() {
    return loadForMonth(DateTime(state.month.year, state.month.month + 1));
  }

  Future<Movement> create(Movement movement) async {
    final created = await ref.read(createMovementUseCaseProvider).call(movement);
    if (_isInCurrentMonth(created)) {
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
    if (_isInCurrentMonth(updated)) {
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

  bool _isInCurrentMonth(Movement movement) {
    return movement.accountingDate.year == state.month.year &&
        movement.accountingDate.month == state.month.month;
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
