import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../domain/entities/category.dart';

class CategoryStyle {
  const CategoryStyle({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}

class CategoryCatalog {
  const CategoryCatalog._();

  static const Map<int, CategoryStyle> _byId = {
    1: CategoryStyle(icon: Icons.local_drink_rounded, color: Color(0xFFF48FB1)),
    2: CategoryStyle(icon: Icons.restaurant_rounded, color: Color(0xFFFB8C00)),
    3: CategoryStyle(icon: Icons.shopping_cart_rounded, color: Color(0xFF43A047)),
    4: CategoryStyle(icon: Icons.local_gas_station_rounded, color: Color(0xFF42A5F5)),
    5: CategoryStyle(icon: Icons.directions_car_rounded, color: Color(0xFF42A5F5)),
    6: CategoryStyle(icon: Icons.directions_bus_rounded, color: Color(0xFF26C6DA)),
    7: CategoryStyle(icon: Icons.home_rounded, color: Color(0xFF5C6BC0)),
    8: CategoryStyle(icon: Icons.house_rounded, color: Color(0xFF5C6BC0)),
    9: CategoryStyle(icon: Icons.bolt_rounded, color: Color(0xFFFFB74D)),
    10: CategoryStyle(icon: Icons.water_drop_rounded, color: Color(0xFF42A5F5)),
    11: CategoryStyle(icon: Icons.wifi_rounded, color: Color(0xFF7E57C2)),
    12: CategoryStyle(icon: Icons.phone_iphone_rounded, color: Color(0xFF7E57C2)),
    13: CategoryStyle(icon: Icons.cleaning_services_rounded, color: Color(0xFF66BB6A)),
    14: CategoryStyle(icon: Icons.medical_services_rounded, color: Color(0xFFEC407A)),
    15: CategoryStyle(icon: Icons.soap_rounded, color: Color(0xFF66BB6A)),
    16: CategoryStyle(icon: Icons.receipt_long_rounded, color: Color(0xFFD81B60)),
    17: CategoryStyle(icon: Icons.shield_rounded, color: Color(0xFFFB8C00)),
    18: CategoryStyle(icon: Icons.school_rounded, color: Color(0xFFAB47BC)),
    19: CategoryStyle(icon: Icons.checkroom_rounded, color: Color(0xFFEC407A)),
    20: CategoryStyle(icon: Icons.spa_rounded, color: Color(0xFFF48FB1)),
    21: CategoryStyle(icon: Icons.pets_rounded, color: Color(0xFFFFCA28)),
    22: CategoryStyle(icon: Icons.theaters_rounded, color: Color(0xFFEF5350)),
    23: CategoryStyle(icon: Icons.flight_rounded, color: Color(0xFF26A69A)),
    24: CategoryStyle(icon: Icons.card_giftcard_rounded, color: Color(0xFF26A69A)),
    25: CategoryStyle(icon: Icons.subscriptions_rounded, color: Color(0xFFEF5350)),
    26: CategoryStyle(icon: Icons.sports_soccer_rounded, color: Color(0xFF66BB6A)),
    27: CategoryStyle(icon: Icons.devices_rounded, color: Color(0xFF7E57C2)),
    28: CategoryStyle(icon: Icons.chair_rounded, color: Color(0xFF5C6BC0)),
    29: CategoryStyle(icon: Icons.account_balance_rounded, color: Color(0xFF8D6E63)),
    30: CategoryStyle(icon: Icons.trending_up_rounded, color: Color(0xFF66BB6A)),
    31: CategoryStyle(icon: Icons.savings_rounded, color: AppColors.income),
    32: CategoryStyle(icon: Icons.undo_rounded, color: AppColors.info),
    33: CategoryStyle(icon: Icons.payments_rounded, color: AppColors.income),
    34: CategoryStyle(icon: Icons.account_balance_wallet_rounded, color: AppColors.income),
    35: CategoryStyle(icon: Icons.swap_horiz_rounded, color: AppColors.purple),
  };

  static CategoryStyle lookup(Category category) {
    return _byId[category.id] ??
        const CategoryStyle(
          icon: Icons.category_rounded,
          color: AppColors.onSurfaceVariant,
        );
  }
}
