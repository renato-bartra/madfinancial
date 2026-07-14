import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.isExpenseCategory,
    required this.description,
    this.iconName,
  });

  final int id;
  final bool isExpenseCategory;
  final String description;
  final String? iconName;

  @override
  List<Object?> get props => [id, isExpenseCategory, description, iconName];
}
