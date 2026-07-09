import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TagPill extends StatelessWidget {
  const TagPill({required this.label, required this.seed, super.key});

  final String label;
  final int seed;

  static const List<Color> _palette = [
    Color(0xFFF48FB1),
    Color(0xFFFB8C00),
    Color(0xFF43A047),
    Color(0xFF42A5F5),
    Color(0xFF26C6DA),
    Color(0xFF5C6BC0),
    Color(0xFFFFB74D),
    Color(0xFF7E57C2),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
    AppColors.info,
    AppColors.purple,
    AppColors.warning,
  ];

  Color get _color {
    final idx = seed.abs() % _palette.length;
    return _palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
