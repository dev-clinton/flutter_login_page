import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../services/auth_service.dart';
import '../theme/cee_theme.dart';
import '../widgets/cee_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onRegistered});

  final ValueChanged<UserAccount> onRegistered;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await AuthService.instance.register(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      widget.onRegistered(user);
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Your account could not be created. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter your full name.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CeeLogo(size: 72)),
                    const SizedBox(height: 20),
                    const CeeScreenHeading(
                      title: 'Create your account',
                      subtitle: 'A few details and your CEE account is ready.',
                    ),
                    const SizedBox(height: 28),
                    CeeTextField(
                      controller: _nameController,
                      label: 'Full name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: _validateName,
                    ),
                    const SizedBox(height: 15),
                    CeeTextField(
                      controller: _emailController,
                      label: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 15),
                    CeeTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixTap: () => setState(() => _hidePassword = !_hidePassword),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 15),
                    CeeTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      icon: Icons.lock_reset_outlined,
                      obscureText: _hideConfirmation,
                      textInputAction: TextInputAction.done,
                      suffixIcon: _hideConfirmation
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixTap: () => setState(
                        () => _hideConfirmation = !_hideConfirmation,
                      ),
                      validator: _validateConfirmation,
                    ),
                    const SizedBox(height: 23),
                    CeePrimaryButton(
                      label: 'Create account',
                      isLoading: _isLoading,
                      onPressed: _createAccount,
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'By creating an account, your details are saved on this device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CeeTheme.secondaryText,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
