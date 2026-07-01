import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../../../../core/services/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/movement.dart';
import '../widgets/day_group_header.dart';
import '../widgets/month_summary_header.dart';
import '../widgets/movement_list_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(movementsControllerProvider.notifier).loadCurrentMonth(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movementsControllerProvider);
    final groupedMovements = _groupByDay(state.movements);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MadFinancial'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(sessionManagerProvider).clearSession();
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
          color: Colors.white.withOpacity(0.7),
        ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
        ),
        children: [
          Row(
            children: [
              Text("Transferencia", style: TextStyle(color: AppColors.surface)),
              SizedBox(width: 30),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.purple,
                child: const Icon(Icons.currency_exchange),
                onPressed: () {}
              )
            ]
          ),
          Row(
            children: [
              Text("Ingreso", style: TextStyle(color: AppColors.surface)),
              SizedBox(width: 30),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.income,
                child: const Icon(Icons.paid),
                onPressed: () {}
              ),
            ]
          ),
          Row(
            children: [
              Text("Salida", style: TextStyle(color: AppColors.surface)),
              SizedBox(width: 30),
              FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.expense,
                child: const Icon(Icons.money_off),
                onPressed: () {}
              ),
            ]
          )
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
            else if (groupedMovements.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No hay movimientos este mes.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
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
                    return MovementListItem(movement: item.movement);
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
    final grouped = <DateTime, List<Movement>>{};
    final sorted = [...movements]
      ..sort((a, b) => b.accountingDate.compareTo(a.accountingDate));

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
      final total = entry.value.fold<double>(
        0,
        (sum, movement) => sum + movement.signedAmount,
      );
      items.add(_DayHeaderItem(entry.key, total));
      items.addAll(entry.value.map(_MovementItem.new));
    }
    return items;
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
