import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
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

  double get balance => totalIncome - totalExpense;

  MovementsState copyWith({
    DateTime? month,
    List<Movement>? movements,
    bool? isLoading,
    bool? usingDummyData,
    String? errorMessage,
  }) {
    return MovementsState(
      month: month ?? this.month,
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
      usingDummyData: usingDummyData ?? this.usingDummyData,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    month,
    movements,
    isLoading,
    usingDummyData,
    errorMessage,
  ];
}

class MovementsController extends Notifier<MovementsState> {
  @override
  MovementsState build() => MovementsState.initial();

  Future<void> loadCurrentMonth() => loadForMonth(state.month);

  Future<void> loadForMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    state = state.copyWith(
      month: normalizedMonth,
      isLoading: true,
      errorMessage: null,
    );
    try {
      final apiMovements = await ref
          .read(getMovementsByDateUseCaseProvider)
          .call(normalizedMonth);
      final movements = apiMovements.isEmpty
          ? buildDummyMovements(normalizedMonth)
          : apiMovements;
      state = state.copyWith(
        movements: movements,
        isLoading: false,
        usingDummyData: apiMovements.isEmpty,
      );
    } on AuthException catch (error) {
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: error.message,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        movements: buildDummyMovements(normalizedMonth),
        isLoading: false,
        usingDummyData: true,
        errorMessage: 'No se pudieron cargar los movimientos.',
      );
    }
  }

  Future<void> previousMonth() {
    return loadForMonth(DateTime(state.month.year, state.month.month - 1));
  }

  Future<void> nextMonth() {
    return loadForMonth(DateTime(state.month.year, state.month.month + 1));
  }
}
