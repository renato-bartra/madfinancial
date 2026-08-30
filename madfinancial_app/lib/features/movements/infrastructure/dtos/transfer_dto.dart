import '../../../../core/constants/api_constants.dart';

class TransferRequestDto {
  const TransferRequestDto({
    required this.userId,
    required this.amount,
    required this.accountingDate,
    required this.title,
    required this.description,
    required this.accountOutId,
    required this.accountOutDescription,
    required this.accountInId,
    required this.accountInDescription,
    required this.tags,
  });

  final int userId;
  final double amount;
  final String accountingDate;
  final String title;
  final String description;
  final int accountOutId;
  final String accountOutDescription;
  final int accountInId;
  final String accountInDescription;
  final List<Map<String, dynamic>> tags;

  Map<String, dynamic> toJson() {
    return {
      'movement_id': 0,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'accounting_date': accountingDate,
      'type': <String, dynamic>{},
      'category': <String, dynamic>{},
      'account_out': {
        'account_id': accountOutId,
        'description': accountOutDescription,
      },
      'account_in': {
        'account_id': accountInId,
        'description': accountInDescription,
      },
      'tags': tags,
      'submovements': const <Map<String, dynamic>>[],
    };
  }
}

class TransferEndpointPaths {
  const TransferEndpointPaths._();
  static const String transfers = '${ApiConstants.movements}transfers/';
  static String transferByUuid(String uuid) =>
      '${ApiConstants.movements}transfers/$uuid';
}
