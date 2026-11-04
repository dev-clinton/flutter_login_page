import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../services/auth_service.dart';
import '../theme/cee_theme.dart';
import '../widgets/cee_widgets.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  UserAccount? _currentUser;
  bool _isLoading = true;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await AuthService.instance.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _isLoading = false;
        _initializationError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _initializationError = 'CEE could not open its account storage.';
      });
    }
  }

  void _onAuthenticated(UserAccount user) {
    setState(() => _currentUser = user);
  }

  Future<void> _onLogout() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: CeeTheme.accent),
        ),
      );
    }

    if (_initializationError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CeeLogo(size: 78),
                const SizedBox(height: 22),
                Text(
                  _initializationError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () {
                    setState(() => _isLoading = true);
                    _restoreSession();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _currentUser;
    if (user != null) {
      return HomeScreen(user: user, onLogout: _onLogout);
    }

    return LoginScreen(onAuthenticated: _onAuthenticated);
  }
}
