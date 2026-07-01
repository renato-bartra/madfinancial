import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.isExpenseCategory,
    required this.description,
  });

  final int id;
  final bool isExpenseCategory;
  final String description;

  @override
  List<Object?> get props => [id, isExpenseCategory, description];
}
