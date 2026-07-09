import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/category_catalog.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/category.dart';

class CategoryPickerPage extends ConsumerWidget {
  const CategoryPickerPage({super.key, required this.isIncome});

  final bool isIncome;

  static Future<Category?> show(
    BuildContext context, {
    required bool isIncome,
  }) {
    return Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (_) => CategoryPickerPage(isIncome: isIncome),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categoría'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudieron cargar las categorías: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
        data: (rawCategories) {
          final categories = (rawCategories.cast<Category>())
              .where((c) => isIncome ? !c.isExpenseCategory : c.isExpenseCategory)
              .toList();
          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'No hay categorías disponibles.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            );
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final style = CategoryCatalog.lookup(cat);
                  return _CategoryTile(
                    category: cat,
                    icon: style.icon,
                    color: style.color,
                    onTap: () => Navigator.of(context).pop(cat),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final Category category;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.25),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Icon(icon, color: color, size: 56),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
