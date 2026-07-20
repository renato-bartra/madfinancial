import 'package:auto_size_text/auto_size_text.dart';
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

    return AutoSizeText(
      '$sign${formatter.format(amount)}',
      maxLines: 1,
      minFontSize: 8,
      style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      )
    );
  }
}
