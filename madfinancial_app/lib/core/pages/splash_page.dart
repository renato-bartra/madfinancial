import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/session_manager.dart';
import '../theme/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_redirect);
  }

  Future<void> _redirect() async {
    final sessionManager = ref.read(sessionManagerProvider);
    final session = await sessionManager.getCurrentSession();
    if (!mounted) return;

    if (session != null && session.token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    final hasEverRegistered = await sessionManager.hasEverRegistered();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacementNamed(hasEverRegistered ? '/login' : '/register');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
              size: 72,
            ),
            SizedBox(height: 18),
            Text(
              'MadFinancial',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
