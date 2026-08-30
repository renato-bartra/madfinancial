import 'package:equatable/equatable.dart';

import 'account.dart';
import 'movement.dart';
import 'tag.dart';

/// Domain-only draft for the transfer creation / edit flow.
///
/// Lives only in memory; the SQLite cache keeps two `Movement` rows
/// linked by [transferUuid]. No local transfers table is created.
class TransferDraft extends Equatable {
  const TransferDraft({
    required this.amount,
    required this.accountingDate,
    required this.title,
    required this.description,
    required this.accountOut,
    required this.accountIn,
    required this.tags,
    this.transferUuid,
  });

  final double amount;
  final DateTime accountingDate;
  final String title;
  final String description;
  final Account accountOut;
  final Account accountIn;
  final List<Tag> tags;
  final String? transferUuid;

  bool get isEditing => transferUuid != null && transferUuid!.isNotEmpty;

  TransferDraft copyWith({
    double? amount,
    DateTime? accountingDate,
    String? title,
    String? description,
    Account? accountOut,
    Account? accountIn,
    List<Tag>? tags,
    String? transferUuid,
  }) {
    return TransferDraft(
      amount: amount ?? this.amount,
      accountingDate: accountingDate ?? this.accountingDate,
      title: title ?? this.title,
      description: description ?? this.description,
      accountOut: accountOut ?? this.accountOut,
      accountIn: accountIn ?? this.accountIn,
      tags: tags ?? this.tags,
      transferUuid: transferUuid ?? this.transferUuid,
    );
  }

  @override
  List<Object?> get props => [
    amount,
    accountingDate,
    title,
    description,
    accountOut,
    accountIn,
    tags,
    transferUuid,
  ];
}

/// Pair of movements produced by a transfer create/update response.
class TransferPair extends Equatable {
  const TransferPair({required this.outgoing, required this.incoming});

  final Movement outgoing;
  final Movement incoming;

  @override
  List<Object?> get props => [outgoing, incoming];
}
