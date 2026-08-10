import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/core/widgets/app_icon.dart';
import 'package:gistol_dashboard/core/widgets/responsive_layout.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gistol_dashboard/features/auth/view/widgets/login_form.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  

  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему и цветовую схему
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
      
    final authProvider = context.watch<AuthProvider>();


    return Scaffold(
      backgroundColor: colors.surface, // Автоматически адаптируется под тему
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea( 
        child: ResponsiveLayout(
          desktop: Center( 
            child: SingleChildScrollView( 
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card( 
                  elevation: 4,
                  shadowColor: colors.shadow.withOpacity(0.2),
                  shape: RoundedRectangleBorder( 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: LoginForm(),
                  )
                )
              )
                
            )
          ),
          mobile: Center( 
            child: SingleChildScrollView( 
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
              child: LoginForm()
            )
          )
        )
      )
    );
  }
}
