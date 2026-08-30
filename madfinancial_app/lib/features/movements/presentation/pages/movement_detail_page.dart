import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/transfer.dart';
import 'movement_form_page.dart';
import 'transfer_form_page.dart';

class MovementDetailPage extends ConsumerWidget {
  const MovementDetailPage({super.key, required this.movement});

  final Movement movement;

  static Future<bool?> show(BuildContext context, Movement movement) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MovementDetailPage(movement: movement),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (movement.isTransfer) {
      return _TransferDetailPage(movement: movement);
    }
    final isIncome = movement.isIncome;
    final amount = movement.amount;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _TrashButton(
              onPressed: () => _confirmDeleteNormal(context, ref),
            ),
          ),
        ],
      ),
      body: MovementFormPage(
        initial: movement,
        draftAmount: amount,
        isIncome: isIncome,
      ),
    );
  }

  Future<void> _confirmDeleteNormal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Eliminar movimiento',
            style: TextStyle(color: AppColors.onSurface),
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este movimiento?',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.expense),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(movementsControllerProvider.notifier)
          .delete(movement.id);
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }
}

class _TransferDetailPage extends ConsumerWidget {
  const _TransferDetailPage({required this.movement});
  final Movement movement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _TrashButton(
              onPressed: () => _confirmDeleteTransfer(context, ref),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Movement>>(
        future: ref
            .read(movementsControllerProvider.notifier)
            .loadTransferPair(movement.transferUuid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No se pudo cargar la transferencia: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            );
          }
          final pair = snapshot.data ?? const [];
          if (pair.length < 2) {
            return const Center(
              child: Text(
                'No se encontró la transferencia.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            );
          }
          final outgoing = pair.firstWhere(
            (m) => m.isOutgoing,
            orElse: () => pair.first,
          );
          final incoming = pair.firstWhere(
            (m) => !m.isOutgoing,
            orElse: () => pair.last,
          );
          final draft = TransferDraft(
            amount: outgoing.amount.abs(),
            accountingDate: outgoing.accountingDate,
            title: outgoing.title,
            description: outgoing.description,
            accountOut: outgoing.account,
            accountIn: incoming.account,
            tags: outgoing.tags,
            transferUuid: outgoing.transferUuid,
          );
          return TransferFormPage(
            draft: draft,
            amount: outgoing.amount.abs(),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteTransfer(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Eliminar transferencia',
            style: TextStyle(color: AppColors.onSurface),
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar esta transferencia? Se eliminarán los dos movimientos asociados.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.expense),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(movementsControllerProvider.notifier)
          .deleteTransfer(movement.transferUuid!);
      if (!context.mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }
}

class _TrashButton extends StatelessWidget {
  const _TrashButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: AppColors.expense,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(
            Icons.delete_rounded,
            color: AppColors.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}
