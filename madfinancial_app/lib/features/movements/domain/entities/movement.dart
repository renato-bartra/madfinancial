import 'package:equatable/equatable.dart';

import 'account.dart';
import 'category.dart';
import 'movement_type.dart';
import 'submovement.dart';
import 'tag.dart';

class Movement extends Equatable {
  const Movement({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.accountingDate,
    required this.type,
    required this.category,
    required this.account,
    required this.tags,
    required this.submovements,
    this.transferUuid,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final double amount;
  final DateTime accountingDate;
  final MovementType type;
  final Category category;
  final Account account;
  final List<Tag> tags;
  final List<Submovement> submovements;
  final String? transferUuid;

  bool get isTransfer => transferUuid != null && transferUuid!.isNotEmpty;

  bool get isIncome => type.isIncome;

  bool get isExpense => type.isExpense;

  /// `true` when this movement leaves its account.
  /// For transfers: derived from category (Salida / Ingreso por transferencia).
  /// For normal movements: derived from the expense flag.
  bool get isOutgoing {
    if (isTransfer) return category.isExpenseCategory;
    return !isIncome;
  }

  double get signedAmount {
    if (isTransfer) return isOutgoing ? -amount.abs() : amount.abs();
    return isIncome ? amount.abs() : -amount.abs();
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    amount,
    accountingDate,
    type,
    category,
    account,
    tags,
    submovements,
    transferUuid,
  ];
}
