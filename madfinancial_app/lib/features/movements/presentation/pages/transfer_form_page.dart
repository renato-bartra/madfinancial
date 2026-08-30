import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/transfer.dart';
import '../widgets/account_picker_dialog.dart';
import '../widgets/tag_picker_dialog.dart';

class TransferFormPage extends ConsumerStatefulWidget {
  const TransferFormPage({
    required this.draft,
    required this.amount,
    this.isEditing = false,
    super.key,
  });

  /// Amount coming from the calculator (locked).
  final double amount;

  /// Initial draft. For new transfers, [draft.transferUuid] is null.
  /// For edits, the draft is built from the local pair by [MovementDetailPage].
  final TransferDraft draft;

  /// When true, the page renders the delete icon for transfer deletions.
  final bool isEditing;

  @override
  ConsumerState<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends ConsumerState<TransferFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late Account _accountOut;
  late Account _accountIn;
  late List<Tag> _selectedTags;
  late DateTime _accountingDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _accountOut = widget.draft.accountOut;
    _accountIn = widget.draft.accountIn;
    _selectedTags = List.of(widget.draft.tags);
    _accountingDate = widget.draft.accountingDate;
    _titleController = TextEditingController(text: widget.draft.title);
    _descriptionController =
        TextEditingController(text: widget.draft.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _accountOut.id != _accountIn.id;

  Future<void> _pickOutAccount() async {
    final result = await AccountPickerDialog.show(
      context,
      mode: AccountPickerMode.transferOut,
      selectedAccountId: _accountOut.id,
      excludeAccountId: _accountIn.id,
      title: 'Cuentas',
    );
    if (result?.account != null) {
      setState(() => _accountOut = result!.account!);
    }
  }

  Future<void> _pickInAccount() async {
    final result = await AccountPickerDialog.show(
      context,
      mode: AccountPickerMode.transferIn,
      selectedAccountId: _accountIn.id,
      excludeAccountId: _accountOut.id,
      title: 'Cuentas',
    );
    if (result?.account != null) {
      setState(() => _accountIn = result!.account!);
    }
  }

  Future<void> _pickTags() async {
    final ids = _selectedTags.map((t) => t.id).toList();
    final result = await TagPickerDialog.show(
      context,
      selectedTagIds: ids,
    );
    if (result != null && mounted) {
      setState(() => _selectedTags = result);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _accountingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onSurface,
              surface: AppColors.surface,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _accountingDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final draft = TransferDraft(
      amount: widget.amount.abs(),
      accountingDate: _accountingDate,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      accountOut: _accountOut,
      accountIn: _accountIn,
      tags: _selectedTags,
      transferUuid: widget.draft.transferUuid,
    );
    try {
      final controller = ref.read(movementsControllerProvider.notifier);
      if (widget.draft.transferUuid == null) {
        await controller.createTransfer(draft);
      } else {
        await controller.updateTransfer(widget.draft.transferUuid!, draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountText = widget.amount == 0
        ? '0'
        : (widget.amount == widget.amount.truncateToDouble()
              ? widget.amount.toInt().toString()
              : widget.amount.toStringAsFixed(2));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'PEN',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AccountRow(
              side: _Side.out,
              account: _accountOut,
              onTap: _pickOutAccount,
            ),
            const Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.primary,
              size: 32,
            ),
            _AccountRow(
              side: _Side.in_,
              account: _accountIn,
              onTap: _pickInAccount,
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: AppColors.onSurface, fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Titulo',
                hintStyle: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Descripción',
                hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 14),
            _DateField(date: _accountingDate, onTap: _pickDate),
            const SizedBox(height: 14),
            _TagsField(tags: _selectedTags, onTap: _pickTags),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: (_canSave && !_saving) ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Side { out, in_ }

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.side,
    required this.account,
    required this.onTap,
  });

  final _Side side;
  final Account account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOut = side == _Side.out;
    final label = isOut ? 'Cuenta cargo' : 'Cuenta abono';
    final color = isOut ? AppColors.expense : AppColors.income;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    account.description,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat("EEEE d 'de' MMMM 'de' y", 'es_ES').format(date);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Text(
              'Fecha',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatted,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagsField extends StatelessWidget {
  const _TagsField({required this.tags, required this.onTap});
  final List<Tag> tags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Text(
              'Tags',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (tags.isEmpty)
              const Text(
                'Toca para elegir',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.description,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
