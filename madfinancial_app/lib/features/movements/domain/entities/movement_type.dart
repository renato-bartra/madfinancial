import 'package:equatable/equatable.dart';

class MovementType extends Equatable {
  const MovementType({required this.id, required this.description});

  final int id;
  final String description;

  bool get isIncome {
    final text = description.toLowerCase();
    return id == 1 || text.contains('ingreso') || text.contains('income');
  }

  bool get isExpense {
    final text = description.toLowerCase();
    return id == 2 || text.contains('gasto') || text.contains('expense');
  }

  bool get isTransfer {
    final text = description.toLowerCase();
    return id == 3 || text.contains('transfer');
  }

  @override
  List<Object?> get props => [id, description];
}
