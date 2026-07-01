import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  const Tag({required this.id, required this.description});

  final int id;
  final String description;

  @override
  List<Object?> get props => [id, description];
}
