import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/money_text.dart';

class DayGroupHeader extends StatelessWidget {
  const DayGroupHeader({required this.date, required this.total, super.key});

  final DateTime date;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          MoneyText(
            amount: total,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
