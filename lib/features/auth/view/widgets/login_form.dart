import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:gistol_dashboard/features/auth/view/widgets/input.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  
  @override
  State<LoginForm> createState() => _LoginForm(); 
}

class _LoginForm extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCont = TextEditingController();
  final _passwordCont = TextEditingController();
  
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _obscurePassword = true; 

@override
  void initState() {
    final authProvider = context.read<AuthProvider>();
    super.initState();
  }


  
  @override
  void dispose() {
    _usernameCont.dispose();
    _passwordCont.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    final authProvider = context.read<AuthProvider>();

    final username = _usernameCont.text.trim();
    final password = _passwordCont.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    await authProvider.login(username, password);
    
    if(!mounted) return;

    if (authProvider.currentError != null ) {
      ErrorHandler.handle(authProvider.currentError!, context: context);
    }else{
      if (context.canPop() ) {
        
        context.pop(); // Возвращаемся на предыдущую страницу
      } else {
        context.go("/home"); // Если истории нет — идем на /home
      }
    }

  }
  
  @override 
  Widget build(BuildContext context) {
    
    final authProvider = context.watch<AuthProvider>();

    return Column( 
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppIcon(size: 120), 
        Input(
          controller: _usernameCont, 
          focusNode: _usernameFocus, 
          label: AppStrings.auth.usernameLabel.tr(),
          hint: AppStrings.auth.usernameHint.tr(),
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Input(
          controller: _passwordCont, 
          focusNode: _passwordFocus, 
          label: AppStrings.auth.passwordLabel.tr(),
          hint: AppStrings.auth.passwordHint.tr(),
          prefixIcon: Icons.lock_outline,
          // Указываем, что это поле пароля, и передаем текущее состояние скрытности
          isPassword: true,
          isObscured: _obscurePassword,
          onToggleVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => handleSubmit(),
        ),
        const SizedBox(height: 16), 
        ElevatedButton(
          onPressed: authProvider.isLoading ? null : handleSubmit, 
          child: authProvider.isLoading ? const SizedBox( 
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white)
          ) : Text(AppStrings.auth.loginBtn.tr()),
        ),

      ],
    );
  }
}
