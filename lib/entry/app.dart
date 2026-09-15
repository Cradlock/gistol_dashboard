import 'package:flutter/foundation.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/entry.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/features/students/view/provider.dart';
import 'package:gistol_dashboard/features/tasks/view/provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Добавили импорт пакета


class MainApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final AuthProvider authProvider;
  final GroupProvider groupProvider;
  final StudentsProvider studentsProvider;
  final TasksProvider tasksProvider;

  const MainApp({
    super.key,
    required this.settingsProvider,
    required this.authProvider,
    required this.groupProvider,
    required this.studentsProvider,
    required this.tasksProvider,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Слой локализации лежит на самом верху интерфейса
    return EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      child: Builder(
        builder: (context) {
          // 2. Внедряем глобальные провайдеры
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<GroupProvider>.value(value: groupProvider),
              ChangeNotifierProvider<StudentsProvider>.value(value: studentsProvider),
              ChangeNotifierProvider<TasksProvider>.value(value: tasksProvider),
            ],
            // Передаем управление в ядро приложения
            child: const _MaterialAppCore(),
          );
        },
      ),
    );
  }
}

// Выносим сам MaterialApp пониже, чтобы внутри него уже работал .tr(), Provider.of
class _MaterialAppCore extends StatelessWidget {
  const _MaterialAppCore();

  @override
  Widget build(BuildContext context) {
    // Читаем тему из настроек
    final settings = context.watch<SettingsProvider>();
    
    return MaterialApp.router(
          
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }


}
