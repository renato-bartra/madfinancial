import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({required this.id, required this.description});

  final int id;
  final String description;

  @override
  List<Object?> get props => [id, description];
}
