import 'package:flutter/material.dart';

class CategoryIcons {
  const CategoryIcons._();

  static const IconData _fallback = Icons.category_rounded;

  static const Map<String, IconData> _byName = {
    'kitchen_rounded': Icons.kitchen_rounded,
    'restaurant_rounded': Icons.restaurant_rounded,
    'shopping_cart_rounded': Icons.shopping_cart_rounded,
    'local_gas_station_rounded': Icons.local_gas_station_rounded,
    'directions_car_rounded': Icons.directions_car_rounded,
    'directions_bus_rounded': Icons.directions_bus_rounded,
    'local_taxi_rounded': Icons.local_taxi_rounded,
    'home_rounded': Icons.home_rounded,
    'house_rounded': Icons.house_rounded,
    'bolt_rounded': Icons.bolt_rounded,
    'water_drop_rounded': Icons.water_drop_rounded,
    'wifi_rounded': Icons.wifi_rounded,
    'phone_iphone_rounded': Icons.phone_iphone_rounded,
    'cleaning_services_rounded': Icons.cleaning_services_rounded,
    'medical_services_rounded': Icons.medical_services_rounded,
    'soap_rounded': Icons.soap_rounded,
    'receipt_long_rounded': Icons.receipt_long_rounded,
    'health_and_safety_rounded': Icons.health_and_safety_rounded,
    'school_rounded': Icons.school_rounded,
    'checkroom_rounded': Icons.checkroom_rounded,
    'spa_rounded': Icons.spa_rounded,
    'pets_rounded': Icons.pets_rounded,
    'theater_comedy_rounded': Icons.theater_comedy_rounded,
    'flight_rounded': Icons.flight_rounded,
    'card_giftcard_rounded': Icons.card_giftcard_rounded,
    'subscriptions_rounded': Icons.subscriptions_rounded,
    'sports_soccer_rounded': Icons.sports_soccer_rounded,
    'devices_rounded': Icons.devices_rounded,
    'chair_rounded': Icons.chair_rounded,
    'account_balance_rounded': Icons.account_balance_rounded,
    'trending_up_rounded': Icons.trending_up_rounded,
    'savings_rounded': Icons.savings_rounded,
    'undo_rounded': Icons.undo_rounded,
    'payments_rounded': Icons.payments_rounded,
    'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
    'swap_horiz_rounded': Icons.swap_horiz_rounded,
    'drive_eta_rounded': Icons.drive_eta_rounded
  };

  static IconData resolve(String? name) {
    if (name == null || name.isEmpty) return _fallback;
    return _byName[name] ?? _fallback;
  }
}
