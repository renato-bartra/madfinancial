import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/tag.dart';

class TagPickerDialog extends ConsumerStatefulWidget {
  const TagPickerDialog({super.key, required this.selectedTagIds});

  final List<int> selectedTagIds;

  static Future<List<Tag>?> show(
    BuildContext context, {
    required List<int> selectedTagIds,
  }) {
    return showDialog<List<Tag>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => TagPickerDialog(selectedTagIds: selectedTagIds),
    );
  }

  @override
  ConsumerState<TagPickerDialog> createState() => _TagPickerDialogState();
}

class _TagPickerDialogState extends ConsumerState<TagPickerDialog> {
  final _controller = TextEditingController();
  final Set<int> _selected = {};
  List<Tag> _availableTags = const [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.selectedTagIds);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(int id) {
    setState(() {
      if (!_selected.add(id)) {
        _selected.remove(id);
      }
    });
  }

  void _confirm() {
    final picked = _availableTags
        .where((tag) => _selected.contains(tag.id))
        .toList();
    Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tags',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: tagsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'No se pudieron cargar los tags: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  data: (raw) {
                    final tags = raw.cast<Tag>();
                    _availableTags = tags;
                    if (tags.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aún no hay tags. Crea uno abajo.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          final isSelected = _selected.contains(tag.id);
                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _toggle(tag.id),
                            child: _TagChip(
                              label: tag.description,
                              selected: isSelected,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Nuevo tag',
                        hintStyle: TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _createTag(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _createTag,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onSurface,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Crear tag',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  Future<void> _createTag() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    try {
      final tag = await ref.read(createTagUseCaseProvider).call(text);
      ref.invalidate(tagsProvider);
      setState(() {
        _selected.add(tag.id);
        _controller.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el tag: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected});

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
