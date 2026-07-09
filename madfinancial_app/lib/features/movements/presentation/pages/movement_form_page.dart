import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/category_catalog.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/movement_type.dart';
import '../../domain/entities/submovement.dart';
import '../../domain/entities/tag.dart';
import '../pages/category_picker_page.dart';
import '../widgets/tag_picker_dialog.dart';

class MovementFormPage extends ConsumerStatefulWidget {
  const MovementFormPage({
    super.key,
    this.initial,
    required this.draftAmount,
    required this.isIncome,
    this.initialCategory,
  });

  final Movement? initial;
  final double draftAmount;
  final bool isIncome;
  final Category? initialCategory;

  @override
  ConsumerState<MovementFormPage> createState() => _MovementFormPageState();
}

class _MovementFormPageState extends ConsumerState<MovementFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final FocusNode _titleFocus = FocusNode();
  late Category? _category;
  late DateTime _accountingDate;
  late List<Tag> _selectedTags;
  late List<_SubDraft> _subDrafts;
  bool _saving = false;
  late final int _placeholderId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    _category = initial?.category ?? widget.initialCategory;
    _accountingDate = initial?.accountingDate ?? DateTime.now();
    _selectedTags = List.of(initial?.tags ?? const []);
    _subDrafts = (initial?.submovements ?? const [])
        .map((s) => _SubDraft.fromEntity(s))
        .toList();
    _placeholderId = DateTime.now().millisecondsSinceEpoch;
    _titleController.addListener(_onTitleChanged);
    _titleFocus.addListener(_onTitleFocusChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleFocus.removeListener(_onTitleFocusChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    if (mounted) setState(() {});
  }

  void _onTitleFocusChanged() {
    if (mounted) setState(() {});
  }

  void _selectSuggestion(String title) {
    _titleController.text = title;
    _titleController.selection = TextSelection.fromPosition(
      TextPosition(offset: title.length),
    );
    _titleFocus.requestFocus();
  }

  double get _subSum => _subDrafts.fold(0, (s, d) => s + d.amount);

  bool get _canSave {
    if (widget.draftAmount == 0) return false;
    if (_titleController.text.trim().isEmpty) return false;
    if (_category == null) return false;
    if (_subDrafts.isNotEmpty && _subSum != widget.draftAmount) return false;
    return true;
  }

  Future<void> _pickCategory() async {
    final selected = await CategoryPickerPage.show(
      context,
      isIncome: widget.isIncome,
    );
    if (selected != null && mounted) {
      setState(() => _category = selected);
    }
  }

  Future<void> _pickSubcategory(_SubDraft draft) async {
    final selected = await CategoryPickerPage.show(
      context,
      isIncome: widget.isIncome,
    );
    if (selected != null) {
      setState(() => draft.subcategory = selected);
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

  Future<void> _pickTags() async {
    final initialIds = _selectedTags.map((t) => t.id).toList();
    final result = await TagPickerDialog.show(
      context,
      selectedTagIds: initialIds,
    );
    if (result != null && mounted) {
      setState(() => _selectedTags = result);
    }
  }

  Future<void> _pickSubTags(_SubDraft draft) async {
    final initialIds = draft.tags.map((t) => t.id).toList();
    final result = await TagPickerDialog.show(
      context,
      selectedTagIds: initialIds,
    );
    if (result != null) {
      setState(() => draft.tags = result);
    }
  }

  void _addSubmovement() {
    setState(() {
      _subDrafts.add(_SubDraft.empty(_placeholderId + _subDrafts.length));
    });
  }

  void _removeSubmovement(_SubDraft draft) {
    setState(() => _subDrafts.remove(draft));
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final amount = widget.draftAmount.abs();
    final type = MovementType(
      id: widget.isIncome ? 1 : 2,
      description: widget.isIncome ? 'Ingreso' : 'Gasto',
    );
    final account = widget.initial?.account ??
        const Account(id: 1, description: 'Sueldo');

    final submovements = _subDrafts
        .map(
          (d) => Submovement(
            id: d.id,
            description: d.description.trim(),
            amount: d.amount,
            subcategory: d.subcategory!,
            tags: d.tags,
          ),
        )
        .toList();

    final movement = Movement(
      id: widget.initial?.id ?? 0,
      userId: widget.initial?.userId ?? 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: amount,
      accountingDate: _accountingDate,
      type: type,
      category: _category!,
      account: account,
      tags: _selectedTags,
      submovements: submovements,
    );

    try {
      if (widget.initial == null) {
        final userId = await ref
            .read(currentUserIdProvider.future);
        if (userId == null) {
          throw const _NoSessionException();
        }
        final withUserId = Movement(
          id: movement.id,
          userId: userId,
          title: movement.title,
          description: movement.description,
          amount: movement.amount,
          accountingDate: movement.accountingDate,
          type: movement.type,
          category: movement.category,
          account: movement.account,
          tags: movement.tags,
          submovements: movement.submovements,
        );
        await ref
            .read(movementsControllerProvider.notifier)
            .create(withUserId);
      } else {
        await ref
            .read(movementsControllerProvider.notifier)
            .update(widget.initial!.id, movement);
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
    final amountColor = widget.isIncome ? AppColors.income : AppColors.expense;
    final amountText = widget.draftAmount == 0
        ? '0'
        : (widget.draftAmount == widget.draftAmount.truncateToDouble()
            ? widget.draftAmount.toInt().toString()
            : widget.draftAmount.toStringAsFixed(2));
    final showSuggestions = _titleFocus.hasFocus &&
        _category != null &&
        _titleController.text.trim().isNotEmpty;
    final suggestionsAsync = showSuggestions
        ? ref.watch(titleSuggestionsProvider(_category!.id))
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amountText,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
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
            const SizedBox(height: 18),
            _CategoryChip(
              category: _category,
              onTap: _pickCategory,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 18,
              ),
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
            if (showSuggestions)
              _TitleSuggestions(
                async: suggestionsAsync!,
                exclude: _titleController.text.trim(),
                onSelect: _selectSuggestion,
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
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
            _TagsField(
              tags: _selectedTags,
              onTap: _pickTags,
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text(
                'Sub movimientos',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: _AddButton(onPressed: _addSubmovement),
            ),
            const SizedBox(height: 12),
            for (final draft in _subDrafts) ...[
              _SubmovementCard(
                draft: draft,
                isIncome: widget.isIncome,
                movementAmount: widget.draftAmount,
                onPickCategory: () => _pickSubcategory(draft),
                onPickTags: () => _pickSubTags(draft),
                onRemove: () => _removeSubmovement(draft),
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 12),
            ],
            if (_subDrafts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _subSum == widget.draftAmount
                      ? 'Subtotal: S/ ${_subSum.toStringAsFixed(2)} ✓'
                      : 'Subtotal: S/ ${_subSum.toStringAsFixed(2)} / S/ ${widget.draftAmount.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _subSum == widget.draftAmount
                        ? AppColors.primary
                        : AppColors.warning,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 8),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCategory = category != null;
    final style = hasCategory ? CategoryCatalog.lookup(category!) : null;
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.35),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasCategory) ...[
                Icon(style!.icon, color: style.color, size: 26),
                const SizedBox(width: 8),
                Text(
                  category!.description,
                  style: TextStyle(
                    color: style.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ] else
                const Text(
                  'Elegir categoría',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
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
    final formatted = DateFormat("EEEE d 'de' MMMM 'de' y",'es_ES').format(date);
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          side: const BorderSide(
            color: AppColors.onSurfaceVariant,
            width: 1.4,
          ),
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.onSurface,
          size: 28,
        ),
      ),
    );
  }
}

class _SubmovementCard extends StatefulWidget {
  const _SubmovementCard({
    required this.draft,
    required this.isIncome,
    required this.movementAmount,
    required this.onPickCategory,
    required this.onPickTags,
    required this.onRemove,
    required this.onChanged,
  });

  final _SubDraft draft;
  final bool isIncome;
  final double movementAmount;
  final VoidCallback onPickCategory;
  final VoidCallback onPickTags;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  State<_SubmovementCard> createState() => _SubmovementCardState();
}

class _SubmovementCardState extends State<_SubmovementCard> {
  late final TextEditingController _amountController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.draft.amount == 0
          ? ''
          : (widget.draft.amount == widget.draft.amount.truncateToDouble()
              ? widget.draft.amount.toInt().toString()
              : widget.draft.amount.toStringAsFixed(2)),
    );
    _descController =
        TextEditingController(text: widget.draft.description);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountColor =
        widget.isIncome ? AppColors.income : AppColors.expense;
    final hasCategory = widget.draft.subcategory != null;
    final style = hasCategory
        ? CategoryCatalog.lookup(widget.draft.subcategory!)
        : null;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v) ?? 0;
                    widget.draft.amount = parsed;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: widget.onPickCategory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.3),
                        width: 1.1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasCategory) ...[
                          Icon(style!.icon, color: style.color, size: 22),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.draft.subcategory!.description,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: style.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ] else
                          const Flexible(
                            child: Text(
                              'Categoría',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(
                  Icons.delete_rounded,
                  color: AppColors.onSurface,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Descripción',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            onChanged: (v) => widget.draft.description = v,
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Sub Tags',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (widget.draft.tags.isEmpty)
            Center(
              child: TextButton(
                onPressed: widget.onPickTags,
                child: const Text(
                  'Toca para elegir',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.draft.tags
                  .map(
                    (t) => GestureDetector(
                      onTap: widget.onPickTags,
                      child: Container(
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
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _NoSessionException implements Exception {
  const _NoSessionException();
  @override
  String toString() => 'No hay sesión activa.';
}

class _SubDraft {
  _SubDraft({
    required this.id,
    required this.subcategory,
    required this.amount,
    required this.description,
    required this.tags,
  });

  factory _SubDraft.fromEntity(Submovement s) {
    return _SubDraft(
      id: s.id,
      subcategory: s.subcategory,
      amount: s.amount,
      description: s.description,
      tags: List.of(s.tags),
    );
  }

  factory _SubDraft.empty(int id) {
    return _SubDraft(
      id: id,
      subcategory: null,
      amount: 0,
      description: '',
      tags: const [],
    );
  }

  final int id;
  Category? subcategory;
  double amount;
  String description;
  List<Tag> tags;
}

class _TitleSuggestions extends StatelessWidget {
  const _TitleSuggestions({
    required this.async,
    required this.exclude,
    required this.onSelect,
  });

  final AsyncValue<List<String>> async;
  final String exclude;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 1),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (titles) {
        final filtered = titles
            .where((t) => t.toLowerCase() != exclude.toLowerCase())
            .take(3)
            .toList();
        if (filtered.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: filtered
                .map(
                  (title) => InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onSelect(title),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.onSurfaceVariant
                              .withValues(alpha: 0.25),
                          width: 1.1,
                        ),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
