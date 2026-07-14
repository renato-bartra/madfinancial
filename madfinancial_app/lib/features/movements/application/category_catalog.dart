import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../domain/entities/category.dart';
import 'category_icons.dart';

class CategoryStyle {
  const CategoryStyle({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}

class CategoryCatalog {
  const CategoryCatalog._();

  static const Map<int, Color> _colorById = {
    1: Color(0xFFF48FB1),
    2: Color(0xFFFB8C00),
    3: Color(0xFF43A047),
    4: Color(0xFF42A5F5),
    5: Color(0xFF42A5F5),
    6: Color(0xFF26C6DA),
    7: Color(0xFF5C6BC0),
    8: Color(0xFF5C6BC0),
    9: Color(0xFFFFB74D),
    10: Color(0xFF42A5F5),
    11: Color(0xFF7E57C2),
    12: Color(0xFF7E57C2),
    13: Color(0xFF66BB6A),
    14: Color(0xFFEC407A),
    15: Color(0xFF66BB6A),
    16: Color(0xFFD81B60),
    17: Color(0xFFFB8C00),
    18: Color(0xFFAB47BC),
    19: Color(0xFFEC407A),
    20: Color(0xFFF48FB1),
    21: Color(0xFFFFCA28),
    22: Color(0xFFEF5350),
    23: Color(0xFF26A69A),
    24: Color(0xFF26A69A),
    25: Color(0xFFEF5350),
    26: Color(0xFF66BB6A),
    27: Color(0xFF7E57C2),
    28: Color(0xFF5C6BC0),
    29: Color(0xFF8D6E63),
    30: Color(0xFF66BB6A),
    31: AppColors.income,
    32: AppColors.info,
    33: AppColors.income,
    34: AppColors.income,
    35: AppColors.purple,
  };

  static CategoryStyle lookup(Category category) {
    return CategoryStyle(
      icon: CategoryIcons.resolve(category.iconName),
      color: _colorById[category.id] ?? AppColors.onSurfaceVariant,
    );
  }
}
