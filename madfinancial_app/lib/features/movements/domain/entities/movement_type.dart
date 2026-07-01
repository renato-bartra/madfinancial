import 'package:equatable/equatable.dart';

class MovementType extends Equatable {
  const MovementType({required this.id, required this.description});

  final int id;
  final String description;

  bool get isIncome {
    final text = description.toLowerCase();
    return id == 1 || text.contains('ingreso') || text.contains('income');
  }

  @override
  List<Object?> get props => [id, description];
}
