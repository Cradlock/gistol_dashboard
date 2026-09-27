import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:gistol_dashboard/features/auth/view/widgets/input.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _loginC = TextEditingController();
  final _loginPasswordC = TextEditingController();
  final _currentPasswordC = TextEditingController();
  final _newPasswordC = TextEditingController();
  final _repeatPasswordC = TextEditingController();

  final _loginFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _repeatPasswordFocus = FocusNode();

  bool _hideLoginPassword = true;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideRepeatPassword = true;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _loginC.dispose();
    _loginPasswordC.dispose();
    _currentPasswordC.dispose();
    _newPasswordC.dispose();
    _repeatPasswordC.dispose();
    _loginFocus.dispose();
    _loginPasswordFocus.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _repeatPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final provider = context.read<AuthProvider>();
    try {
      await provider.loadAdminProfile();
      if (!mounted) return;
      _loginC.text = provider.adminProfile?.code ?? '';
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveLogin() async {
    final code = _loginC.text.trim();
    final password = _loginPasswordC.text;
    if (code.length < 3 || password.isEmpty) return;

    try {
      await context.read<AuthProvider>().updateAdminCode(
            currentPassword: password,
            code: code,
          );
      if (!mounted) return;
      _loginPasswordC.clear();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(AppStrings.auth.loginUpdated.tr())));
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    }
  }

  Future<void> _savePassword() async {
    final currentPassword = _currentPasswordC.text;
    final newPassword = _newPasswordC.text;
    final repeatPassword = _repeatPasswordC.text;

    if (newPassword.length < 8) {
      ErrorHandler.handle(WeakPasswordException(), context: context);
      return;
    }
    if (newPassword != repeatPassword) {
      ErrorHandler.handle(PasswordMismatchException(), context: context);
      return;
    }

    try {
      await context.read<AuthProvider>().updateAdminPassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      if (!mounted) return;
      _currentPasswordC.clear();
      _newPasswordC.clear();
      _repeatPasswordC.clear();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppStrings.auth.passwordUpdated.tr())),
        );
    } on AppException catch (error) {
      if (mounted) ErrorHandler.handle(error, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = context.watch<AuthProvider>().isLoading;

    return SafeArea(
      child: LocalLoaderWrapper(
        isLoading: _loadingProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.profile.title.tr(),
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.profile.subtitle.tr(),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.profile.loginSection.tr(),
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          controller: _loginC,
                          focusNode: _loginFocus,
                          label: AppStrings.auth.newLogin.tr(),
                          hint: AppStrings.auth.usernameHint.tr(),
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          controller: _loginPasswordC,
                          focusNode: _loginPasswordFocus,
                          label: AppStrings.auth.currentPassword.tr(),
                          hint: AppStrings.auth.passwordHint.tr(),
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isObscured: _hideLoginPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _hideLoginPassword = !_hideLoginPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppBtn(
                          text: AppStrings.auth.saveLogin.tr(),
                          onPressed: isLoading ? null : _saveLogin,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.profile.passwordSection.tr(),
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          controller: _currentPasswordC,
                          focusNode: _currentPasswordFocus,
                          label: AppStrings.auth.currentPassword.tr(),
                          hint: AppStrings.auth.passwordHint.tr(),
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          isObscured: _hideCurrentPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _hideCurrentPassword = !_hideCurrentPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Input(
                          controller: _newPasswordC,
                          focusNode: _newPasswordFocus,
                          label: AppStrings.auth.newPassword.tr(),
                          hint: AppStrings.auth.passwordHint.tr(),
                          prefixIcon: Icons.lock_reset,
                          isPassword: true,
                          isObscured: _hideNewPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _hideNewPassword = !_hideNewPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Input(
                          controller: _repeatPasswordC,
                          focusNode: _repeatPasswordFocus,
                          label: AppStrings.auth.repeatPassword.tr(),
                          hint: AppStrings.auth.passwordHint.tr(),
                          prefixIcon: Icons.lock_reset,
                          isPassword: true,
                          isObscured: _hideRepeatPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _hideRepeatPassword = !_hideRepeatPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppBtn(
                          text: AppStrings.auth.savePassword.tr(),
                          onPressed: isLoading ? null : _savePassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
