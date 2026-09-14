import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/entry/screens/home_screen.dart';
import 'package:gistol_dashboard/entry/screens/layout.dart';
import 'package:gistol_dashboard/entry/screens/no_connection.dart';
import 'package:gistol_dashboard/entry/screens/no_internet_screen.dart';
import 'package:gistol_dashboard/features/auth/screens/login_screen.dart';
import 'package:gistol_dashboard/features/auth/screens/splash_screen.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/legal/screens/policy_screen.dart';
import 'package:gistol_dashboard/features/legal/screens/service_screen.dart';
import 'package:gistol_dashboard/features/settings/screens/settings_screen.dart';
import 'package:gistol_dashboard/features/students/screens/students_main_screen.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context,child) => SplashScreen()),
      GoRoute(path: '/no-internet', builder: (context,child) => NoInternetScreen()),
      GoRoute(path: '/no-connection', builder: (context,child) => NoConnectiontScreen()),
      ShellRoute(
        builder: (context,state,child) => Mainlayout(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context,state) => const HomeScreen()),
          GoRoute(path: '/settings',builder: (context,state) => const SettingsScreen()),
          GoRoute(path: '/groups',  builder: (context,state) => GroupScreen()),
          GoRoute(path: '/students',  builder: (context,state) => StudentsScreen())
       ]
      ),

      GoRoute(path: '/login', builder: (context,state) => const LoginScreen()),
      
      GoRoute(path: '/service',builder: (context,state) => const ServiceScreen()),
      GoRoute(path: '/policy',builder: (context,state) => const PolicyScreen())
          
    ],

  );
}
