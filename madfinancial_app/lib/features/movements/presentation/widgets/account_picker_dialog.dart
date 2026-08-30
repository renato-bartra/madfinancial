import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/account.dart';

class AccountPickerResult {
  const AccountPickerResult({this.account, this.accounts = const []});
  final Account? account;
  final List<Account> accounts;
}

enum AccountPickerMode { single, multi, transferOut, transferIn }

class AccountPickerDialog extends ConsumerStatefulWidget {
  const AccountPickerDialog({
    required this.mode,
    this.selectedAccountId,
    this.selectedAccountIds = const [],
    this.excludeAccountId,
    this.title = 'Cuentas',
    super.key,
  });

  final AccountPickerMode mode;
  final int? selectedAccountId;
  final List<int> selectedAccountIds;
  final int? excludeAccountId;
  final String title;

  static Future<AccountPickerResult?> show(
    BuildContext context, {
    required AccountPickerMode mode,
    int? selectedAccountId,
    List<int> selectedAccountIds = const [],
    int? excludeAccountId,
    String title = 'Cuentas',
  }) {
    return showDialog<AccountPickerResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => AccountPickerDialog(
        mode: mode,
        selectedAccountId: selectedAccountId,
        selectedAccountIds: selectedAccountIds,
        excludeAccountId: excludeAccountId,
        title: title,
      ),
    );
  }

  @override
  ConsumerState<AccountPickerDialog> createState() => _AccountPickerDialogState();
}

class _AccountPickerDialogState extends ConsumerState<AccountPickerDialog> {
  final _controller = TextEditingController();
  final Set<int> _multi = <int>{};
  int? _single;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _single = widget.selectedAccountId;
    _multi.addAll(widget.selectedAccountIds);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _allowCreate =>
      widget.mode == AccountPickerMode.transferOut ||
      widget.mode == AccountPickerMode.transferIn;

  bool get _isSingle =>
      widget.mode == AccountPickerMode.single ||
      widget.mode == AccountPickerMode.transferOut ||
      widget.mode == AccountPickerMode.transferIn;

  void _toggleMulti(int id) {
    setState(() {
      if (!_multi.add(id)) {
        _multi.remove(id);
      }
    });
  }

  void _confirm(List<Account> accounts) {
    if (_isSingle) {
      if (_single == null) return;
      final picked = accounts.firstWhere((a) => a.id == _single);
      Navigator.of(context).pop(AccountPickerResult(account: picked));
      return;
    }
    final picked = accounts.where((a) => _multi.contains(a.id)).toList();
    Navigator.of(context).pop(AccountPickerResult(accounts: picked));
  }

  Future<void> _createAccount() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _creating = true);
    try {
      final created = await ref
          .read(createAccountUseCaseProvider)
          .call(text);
      ref.invalidate(accountsProvider);
      setState(() {
        _controller.clear();
        if (_isSingle) {
          _single = created.id;
        } else {
          _multi.add(created.id);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la cuenta: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: accountsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'No se pudieron cargar las cuentas: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  data: (raw) {
                    final accounts = raw
                        .cast<Account>()
                        .where((a) => a.id != widget.excludeAccountId)
                        .toList();
                    if (accounts.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aún no hay cuentas. Crea una abajo.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: accounts.map((account) {
                          final selected = _isSingle
                              ? _single == account.id
                              : _multi.contains(account.id);
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (_isSingle) {
                                setState(() => _single = account.id);
                              } else {
                                _toggleMulti(account.id);
                              }
                            },
                            child: _AccountChip(
                              label: account.description,
                              selected: selected,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              if (_allowCreate) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: AppColors.onSurface),
                        decoration: const InputDecoration(
                          hintText: 'Nueva cuenta',
                          hintStyle: TextStyle(
                            color: AppColors.onSurfaceVariant,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _createAccount(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _creating ? null : _createAccount,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Crear',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: accountsAsync.maybeWhen(
                  data: (raw) {
                    final accounts = raw
                        .cast<Account>()
                        .where((a) => a.id != widget.excludeAccountId)
                        .toList();
                    final canSave = _isSingle
                        ? (_single != null &&
                              accounts.any((a) => a.id == _single))
                        : _multi.isNotEmpty;
                    return FilledButton(
                      onPressed: canSave
                          ? () => _confirm(accounts.cast<Account>())
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Elegir',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                  orElse: () => FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Elegir',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : AppColors.onSurfaceVariant.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            const Icon(
              Icons.check_rounded,
              size: 16,
              color: AppColors.onSurface,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
