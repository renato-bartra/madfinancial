import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/entities/movement.dart';

class MovementListItem extends StatelessWidget {
  const MovementListItem({required this.movement, super.key});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(movement.category.description);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _categoryIcon(movement.category.description),
              color: categoryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${movement.category.description} · ${movement.account.description}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MoneyText(
            amount: movement.signedAmount,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('sueldo') || normalized.contains('ingreso')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (normalized.contains('super')) {
      return Icons.shopping_cart_rounded;
    }
    if (normalized.contains('rest') || normalized.contains('comida')) {
      return Icons.restaurant_rounded;
    }
    if (normalized.contains('trans') || normalized.contains('gas')) {
      return Icons.directions_car_rounded;
    }
    if (normalized.contains('entre')) {
      return Icons.movie_rounded;
    }
    return Icons.payments_rounded;
  }

  Color _categoryColor(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('sueldo') || normalized.contains('ingreso')) {
      return AppColors.income;
    }
    if (normalized.contains('super')) {
      return AppColors.warning;
    }
    if (normalized.contains('rest') || normalized.contains('comida')) {
      return AppColors.expense;
    }
    if (normalized.contains('trans') || normalized.contains('gas')) {
      return AppColors.info;
    }
    if (normalized.contains('entre')) {
      return AppColors.purple;
    }
    return AppColors.primary;
  }
}
