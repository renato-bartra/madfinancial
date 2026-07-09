import 'dart:convert';

class MovementTypeDto {
  const MovementTypeDto({required this.id, required this.description});

  final int id;
  final String description;

  factory MovementTypeDto.fromJson(Map<String, dynamic> json) {
    return MovementTypeDto(
      id: (json['type_id'] as num).toInt(),
      description: json['description'] as String? ?? '',
    );
  }
}

class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.isExpenseCategory,
    required this.description,
  });

  final int id;
  final bool isExpenseCategory;
  final String description;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: (json['category_id'] as num).toInt(),
      isExpenseCategory: json['category_type'] as bool? ?? true,
      description: json['description'] as String? ?? '',
    );
  }
}

class AccountDto {
  const AccountDto({required this.id, required this.description});

  final int id;
  final String description;

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      id: (json['account_id'] as num).toInt(),
      description: json['description'] as String? ?? '',
    );
  }
}

class TagDto {
  const TagDto({required this.id, required this.description});

  final int id;
  final String description;

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: (json['tag_id'] as num).toInt(),
      description: json['description'] as String? ?? '',
    );
  }
}

class SubmovementDto {
  const SubmovementDto({
    required this.id,
    required this.description,
    required this.amount,
    required this.subcategory,
    required this.tags,
  });

  final int id;
  final String description;
  final double amount;
  final CategoryDto subcategory;
  final List<TagDto> tags;

  factory SubmovementDto.fromJson(Map<String, dynamic> json) {
    return SubmovementDto(
      id: (json['submovement_id'] as num).toInt(),
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      subcategory: CategoryDto.fromJson(_readMap(json['subcategory'])),
      tags: _readList(json['tags']).map((item) => TagDto.fromJson(_readMap(item))).toList(),
    );
  }
}

class MovementDto {
  const MovementDto({
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
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final double amount;
  final DateTime accountingDate;
  final MovementTypeDto type;
  final CategoryDto category;
  final AccountDto account;
  final List<TagDto> tags;
  final List<SubmovementDto> submovements;

  factory MovementDto.fromJson(Map<String, dynamic> json) {
    return MovementDto(
      id: (json['movement_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      accountingDate: _readDate(json['accounting_date']),
      type: MovementTypeDto.fromJson(_readMap(json['type'])),
      category: CategoryDto.fromJson(_readMap(json['category'])),
      account: AccountDto.fromJson(_readMap(json['account'])),
      tags: _readList(
        json['tags'],
      ).map((item) => TagDto.fromJson(_readMap(item))).toList(),
      submovements: _readList(
        json['submovements'],
      ).map((item) => SubmovementDto.fromJson(_readMap(item))).toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'movement_id': 1,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'accounting_date': _dateToString(accountingDate),
      'type': type.toJson(),
      'category': category.toJson(),
      'account': account.toJson(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'submovements': submovements.map((s) => s.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'movement_id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'accounting_date': _dateToString(accountingDate),
      'type': type.toJson(),
      'category': category.toJson(),
      'account': account.toJson(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'submovements': submovements.map((s) => s.toJson()).toList(),
    };
  }
}

extension MovementTypeDtoJson on MovementTypeDto {
  Map<String, dynamic> toJson() => {
    'type_id': id,
    'description': description,
  };
}

extension CategoryDtoJson on CategoryDto {
  Map<String, dynamic> toJson() => {
    'category_id': id,
    'category_type': isExpenseCategory,
    'description': description,
  };
}

extension AccountDtoJson on AccountDto {
  Map<String, dynamic> toJson() => {
    'account_id': id,
    'description': description,
  };
}

extension TagDtoJson on TagDto {
  Map<String, dynamic> toJson() => {
    'tag_id': id,
    'description': description,
  };
}

extension SubmovementDtoJson on SubmovementDto {
  Map<String, dynamic> toJson() => {
    'submovement_id': id,
    'description': description,
    'amount': amount,
    'subcategory': subcategory.toJson(),
    'tags': tags.map((t) => t.toJson()).toList(),
  };
}

String _dateToString(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic> && value.isNotEmpty) return value;
  if (value is Map) return value.cast<String, dynamic>();
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return decoded.cast<String, dynamic>();
  }
  return <String, dynamic>{};
}

List<Object?> _readList(Object? value) {
  if (value is List && value.isNotEmpty) return value;
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is List) return decoded;
  }
  return const [];
}

DateTime _readDate(Object? value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.parse(value);
  return DateTime.now();
}
