


import 'package:easy_localization/easy_localization.dart';
import 'package:gistol_dashboard/entry/screens/home_screen.dart';
import 'package:gistol_dashboard/entry/screens/layout.dart';
import 'package:gistol_dashboard/entry/screens/no_internet_screen.dart';
import 'package:gistol_dashboard/features/auth/screens/account_screen.dart';
import 'package:gistol_dashboard/features/auth/screens/login_screen.dart';
import 'package:gistol_dashboard/features/auth/screens/splash_screen.dart';
import 'package:gistol_dashboard/features/legal/screens/policy_screen.dart';
import 'package:gistol_dashboard/features/legal/screens/service_screen.dart';
import 'package:gistol_dashboard/features/settings/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context,child) => SplashScreen()),
      GoRoute(path: '/no-internet', builder: (context,child) => NoInternetScreen()),
      ShellRoute(
        builder: (context,state,child) => Mainlayout(child:child,title: state.topRoute?.name ?? "from app router" ),
        routes: [
          GoRoute(path: '/home', name:"pages.main",builder: (context,state) => const HomeScreen()),
          GoRoute(path: '/settings', name: "pages.settings" ,builder: (context,state) => const SettingsScreen()),
          GoRoute(path: '/account', name: "pages.profile", builder: (context,state) => AccountScreen())
       ]
      ),

      GoRoute(path: '/login', builder: (context,state) => const LoginScreen()),
      
      GoRoute(path: '/service',builder: (context,state) => const ServiceScreen()),
      GoRoute(path: '/policy',builder: (context,state) => const PolicyScreen())
          
    ],

  );
}
