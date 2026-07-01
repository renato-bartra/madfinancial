import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    required this.amount,
    this.style,
    this.showSign = true,
    super.key,
  });

  final double amount;
  final TextStyle? style;
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'es_PE',
      symbol: 'S/ ',
      decimalDigits: 2,
    );
    final sign = amount > 0 && showSign ? '+' : '';
    final color = amount >= 0 ? AppColors.income : AppColors.expense;

    return Text(
      '$sign${formatter.format(amount)}',
      style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
