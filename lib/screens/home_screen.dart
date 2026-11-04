import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../theme/cee_theme.dart';
import '../widgets/cee_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final UserAccount user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final firstName = user.fullName.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CEE',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: CeeLogo(size: 88)),
                  const SizedBox(height: 30),
                  Text(
                    'You’re signed in, $firstName.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Welcome to your CEE account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CeeTheme.secondaryText, fontSize: 14),
                  ),
                  const SizedBox(height: 34),
                  Container(
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171817),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF292B28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCOUNT DETAILS',
                          style: TextStyle(
                            color: CeeTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _DetailRow(label: 'Full name', value: user.fullName),
                        const SizedBox(height: 17),
                        _DetailRow(label: 'Email address', value: user.email),
                        const SizedBox(height: 17),
                        _DetailRow(
                          label: 'Member since',
                          value: _formatDate(user.createdAt.toLocal()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF464943)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: CeeTheme.secondaryText, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
