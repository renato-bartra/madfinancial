import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../../../../core/services/session_manager.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/token_refresh_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/movement.dart';
import '../pages/category_picker_page.dart';
import '../pages/movement_detail_page.dart';
import '../widgets/calculator_sheet.dart';
import '../widgets/day_group_header.dart';
import '../widgets/month_summary_header.dart';
import '../widgets/movement_list_item.dart';
import '../widgets/settings_side_menu.dart';
import 'movement_form_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const String _refreshSnackBar =
      'Renovamos tu sesión automáticamente para que no interrumpas tu trabajo. '
      'Sigue usando la aplicación con normalidad.';

  bool _consumedInitialRefresh = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(carryOverEnabledProvider.notifier).hydrate();
      await ref.read(movementsControllerProvider.notifier).loadCurrentMonth();
    });
    // Consume a refresh that may have happened during the splash probe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_consumedInitialRefresh &&
          ref.read(tokenRefreshNotifierProvider) > 0) {
        _consumedInitialRefresh = true;
      }
    });
  }

  void _showRefreshSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_refreshSnackBar)),
    );
  }

  Future<void> _openCreateFlow({required bool isIncome}) async {
    final amount = await CalculatorSheet.show(context, isIncome: isIncome);
    if (amount == null || !mounted) return;
    if (amount == 0) return;

    final category = await CategoryPickerPage.show(
      context,
      isIncome: isIncome,
    );
    if (category == null || !mounted) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MovementFormPage(
          draftAmount: amount,
          isIncome: isIncome,
          initialCategory: category,
        ),
        fullscreenDialog: true,
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isIncome ? 'Ingreso guardado' : 'Gasto guardado'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movementsControllerProvider);
    final groupedMovements = _groupByDay(state.movements);

    ref.listen<int>(tokenRefreshNotifierProvider, (prev, next) {
      if (prev != null && next > prev) {
        _consumedInitialRefresh = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('MadFinancial'),
        leading: IconButton(
          tooltip: 'Ajustes',
          onPressed: () => SettingsSideMenu.show(context),
          icon: const Icon(Icons.settings_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(sessionManagerProvider).clearSession();
              ref.invalidate(currentUserIdProvider);
              ref.invalidate(categoriesProvider);
              ref.invalidate(tagsProvider);
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        pos: ExpandableFabPos.right,
        distance: 70,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.white.withValues(alpha: 0.7),
        ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
        ),
        children: [
          Row(
            children: [
              const Text(
                "Transferencia",
                style: TextStyle(color: AppColors.background),
              ),
              const SizedBox(width: 30),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.purple,
                child: const Icon(Icons.currency_exchange),
                onPressed: () {},
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Ingreso",
                style: TextStyle(color: AppColors.background),
              ),
              const SizedBox(width: 30),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.income,
                child: const Icon(Icons.paid),
                onPressed: () => _openCreateFlow(isIncome: true),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Salida",
                style: TextStyle(color: AppColors.background),
              ),
              const SizedBox(width: 30),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.expense,
                child: const Icon(Icons.money_off),
                onPressed: () => _openCreateFlow(isIncome: false),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(movementsControllerProvider.notifier).loadCurrentMonth(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MonthSummaryHeader(
                month: state.month,
                balance: state.balance,
                income: state.totalIncome,
                expense: state.totalExpense,
                usingDummyData: state.usingDummyData,
                carryOver: state.carryOver,
                onPreviousMonth: () => ref
                    .read(movementsControllerProvider.notifier)
                    .previousMonth(),
                onNextMonth: () =>
                    ref.read(movementsControllerProvider.notifier).nextMonth(),
              ),
            ),
            if (state.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${state.errorMessage} Mostrando datos de ejemplo.',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (groupedMovements.isEmpty && !state.usingDummyData)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 72,
                          color: AppColors.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No hay movimientos este mes.',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = groupedMovements[index];
                  if (item is _DayHeaderItem) {
                    return DayGroupHeader(date: item.date, total: item.total);
                  }
                  if (item is _MovementItem) {
                    return MovementListItem(
                      movement: item.movement,
                      onTap: () => MovementDetailPage.show(
                        context,
                        item.movement,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }, childCount: groupedMovements.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }

  List<Object> _groupByDay(List<Movement> movements) {
    final sorted = [...movements]..sort(_compareMovements);

    final grouped = <DateTime, List<Movement>>{};
    for (final movement in sorted) {
      final key = DateTime(
        movement.accountingDate.year,
        movement.accountingDate.month,
        movement.accountingDate.day,
      );
      grouped.putIfAbsent(key, () => []).add(movement);
    }

    final items = <Object>[];
    for (final entry in grouped.entries) {
      final dayList = [...entry.value]..sort(_compareMovements);
      final total = dayList.fold<double>(
        0,
        (sum, movement) => sum + movement.signedAmount,
      );
      items.add(_DayHeaderItem(entry.key, total));
      items.addAll(dayList.map(_MovementItem.new));
    }
    return items;
  }

  int _compareMovements(Movement a, Movement b) {
    final byDate = b.accountingDate.compareTo(a.accountingDate);
    if (byDate != 0) return byDate;
    return b.id.compareTo(a.id);
  }
}

class _DayHeaderItem {
  const _DayHeaderItem(this.date, this.total);

  final DateTime date;
  final double total;
}

class _MovementItem {
  const _MovementItem(this.movement);

  final Movement movement;
}
