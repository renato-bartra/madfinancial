import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';
import '../../domain/entities/account.dart';
import '../widgets/account_picker_dialog.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  late int _defaultAccountId;
  late List<int> _homeAccountIds;
  bool _initialized = false;
  bool _saving = false;
  final _newAccountController = TextEditingController();
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _defaultAccountId = StorageConstants.defaultSueldoAccountId;
    _homeAccountIds = List.of(StorageConstants.defaultHomeAccountIds);
  }

  @override
  void dispose() {
    _newAccountController.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    await ref.read(defaultAccountIdProvider.notifier).hydrate();
    await ref.read(homeAccountIdsProvider.notifier).hydrate();
    if (!mounted) return;
    setState(() {
      _defaultAccountId = ref.read(defaultAccountIdProvider);
      _homeAccountIds = List.of(ref.read(homeAccountIdsProvider));
      _initialized = true;
    });
  }

  Future<void> _pickDefaultAccount() async {
    final result = await AccountPickerDialog.show(
      context,
      mode: AccountPickerMode.single,
      selectedAccountId: _defaultAccountId,
      title: 'Cuentas',
    );
    if (result?.account != null) {
      setState(() => _defaultAccountId = result!.account!.id);
    }
  }

  Future<void> _pickHomeAccounts() async {
    final result = await AccountPickerDialog.show(
      context,
      mode: AccountPickerMode.multi,
      selectedAccountIds: _homeAccountIds,
      title: 'Cuentas',
    );
    if (result != null && result.accounts.isNotEmpty) {
      setState(
        () => _homeAccountIds = result.accounts.map((a) => a.id).toList(),
      );
    }
  }

  Future<void> _createAccount() async {
    final text = _newAccountController.text.trim();
    if (text.isEmpty) return;
    setState(() => _creating = true);
    try {
      await ref.read(createAccountUseCaseProvider).call(text);
      ref.invalidate(accountsProvider);
      _newAccountController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la cuenta: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(defaultAccountIdProvider.notifier)
          .setAccountId(_defaultAccountId);
      await ref
          .read(homeAccountIdsProvider.notifier)
          .setAccountIds(_homeAccountIds);
      await ref.read(movementsControllerProvider.notifier).loadCurrentMonth();
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

  Account? _findAccount(List<Account> accounts, int id) {
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hydrate();
      });
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Cuentas'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Puedes crear tantas cuentas como necesites.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Después de crear una cuenta, deberás recargar la pantalla para que aparezca en las listas de cuentas de la aplicación.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Una vez creada una cuenta, no podrás cambiar su nombre.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newAccountController,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 28),
            const Text(
              'Puedes seleccionar una cuenta como predeterminada. Esta será la cuenta que la aplicación utilizará automáticamente al crear nuevos movimientos.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 12),
            accountsAsync.when(
              loading: () => const _SingleAccountShimmer(),
              error: (e, _) => _SingleAccountShimmer(label: '$e'),
              data: (raw) {
                final accounts = raw.cast<Account>();
                final selected = _findAccount(accounts, _defaultAccountId);
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _pickDefaultAccount,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selected?.description ?? 'Seleccionar',
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'Puedes seleccionar varias cuentas para mostrar sus movimientos en conjunto en la página principal.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 12),
            accountsAsync.when(
              loading: () => const _MultiAccountShimmer(),
              error: (e, _) => _MultiAccountShimmer(label: '$e'),
              data: (raw) {
                final accounts = raw.cast<Account>();
                final labels = _homeAccountIds
                    .map((id) => _findAccount(accounts, id)?.description ?? '#$id')
                    .toList();
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _pickHomeAccounts,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (labels.isEmpty)
                        const _PillPlaceholder(text: 'Seleccionar')
                      else
                        ...labels.map(
                          (label) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _saving ? null : _save,
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

class _PillPlaceholder extends StatelessWidget {
  const _PillPlaceholder({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SingleAccountShimmer extends StatelessWidget {
  const _SingleAccountShimmer({this.label});
  final String? label;
  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return _PillPlaceholder(text: label!);
    }
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _MultiAccountShimmer extends StatelessWidget {
  const _MultiAccountShimmer({this.label});
  final String? label;
  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return _PillPlaceholder(text: label!);
    }
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
