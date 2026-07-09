import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CalculatorSheet extends StatefulWidget {
  const CalculatorSheet({super.key, required this.isIncome});

  final bool isIncome;

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();

  static Future<double?> show(
    BuildContext context, {
    required bool isIncome,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 250),
      ),
      builder: (_) => CalculatorSheet(isIncome: isIncome),
    );
  }
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _display = '0';

  double get _value {
    if (_display.isEmpty || _display == '.') return 0;
    return double.tryParse(_display) ?? 0;
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_display == '0') {
        _display = digit;
      } else if (_display.contains('.') && _display.split('.').last.length >= 2) {
        return;
      } else {
        _display = '$_display$digit';
      }
    });
  }

  void _appendDot() {
    setState(() {
      if (_display.contains('.')) return;
      if (_display.isEmpty) {
        _display = '0.';
      } else {
        _display = '$_display.';
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = widget.isIncome ? AppColors.income : AppColors.expense;
    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = mediaQuery.size.height * 0.75;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            20 + mediaQuery.viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _value == 0 ? '0' : _formatValue(_value),
                              style: TextStyle(
                                color: amountColor,
                                fontSize: 84,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'PEN',
                            style: TextStyle(
                              color: amountColor.withValues(alpha: 0.7),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _Numpad(
                onDigit: _appendDigit,
                onDot: _appendDot,
                onBackspace: _backspace,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _value == 0
                      ? null
                      : () => Navigator.of(context).pop(_value),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Elegir categoría',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(double v) {
    if (v == v.truncateToDouble()) {
      return v.toInt().toString();
    }
    return v.toStringAsFixed(2);
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(['7', '8', '9']),
        const SizedBox(height: 10),
        _row(['4', '5', '6']),
        const SizedBox(height: 10),
        _row(['1', '2', '3']),
        const SizedBox(height: 10),
        _row(['.', '0', 'back']),
      ],
    );
  }

  Widget _row(List<String> keys) {
    return Row(
      children: keys
          .map(
            (key) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _Key(
                  key,
                  onDigit: onDigit,
                  onDot: onDot,
                  onBackspace: onBackspace,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key(
    this.label, {
    required this.onDigit,
    required this.onDot,
    required this.onBackspace,
  });

  final String label;
  final ValueChanged<String> onDigit;
  final VoidCallback onDot;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    if (label == 'back') {
      return _Box(
        child: IconButton(
          onPressed: onBackspace,
          icon: const Icon(
            Icons.backspace_outlined,
            color: AppColors.expense,
            size: 28,
          ),
        ),
      );
    }
    if (label == '.') {
      return _Box(
        child: TextButton(
          onPressed: onDot,
          child: const Text(
            '.',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return _Box(
      child: TextButton(
        onPressed: () => onDigit(label),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
