import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/settings/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:gistol_dashboard/entry/entry.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';

void main() async {
  

  WidgetsFlutterBinding.ensureInitialized();
  

  await EasyLocalization.ensureInitialized();
  

  await dotenv.load(fileName: ".env");  

  final apiClient = ApiClient();
  apiClient.addInterceptor(AuthInterceptor()); 

  final settingsProvider = SettingsProvider();
  final authProvider = AuthProvider();
  final gropProvider = GroupProvider();
  final studentsProvider = StudentsProvider();

  await settingsProvider.initSettings();

  runApp( 
    MainApp(
      settingsProvider: settingsProvider, 
      authProvider: authProvider,
      groupProvider: gropProvider,
      studentsProvider: studentsProvider,
    )
  );
} 


