import 'package:equatable/equatable.dart';

import 'category.dart';
import 'tag.dart';

class Submovement extends Equatable {
  const Submovement({
    required this.id,
    required this.description,
    required this.amount,
    required this.subcategory,
    required this.tags,
  });

  final int id;
  final String description;
  final double amount;
  final Category subcategory;
  final List<Tag> tags;

  @override
  List<Object?> get props => [id, description, amount, subcategory, tags];
}
