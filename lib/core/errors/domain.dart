




import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/strings.dart';


enum ExceptDisplayType {
  modal,
  toast,
  overlay,
  redirect
}

// Ошибка клиента
@immutable
abstract class AppException implements Exception {
  final ExceptDisplayType displayType;
  final String localKey;
  final void Function(BuildContext context)? onErrorAction;

  const AppException({
    this.onErrorAction,
    required this.displayType,
    required this.localKey,
  });

  /// Чистая верстка контента под каждый тип отображения
  Widget buildCustomDialog(BuildContext context) {
    final theme = Theme.of(context);

    switch (displayType) {
      case ExceptDisplayType.redirect:
        // Редирект не имеет UI-представления
        return const SizedBox.shrink();

      case ExceptDisplayType.modal:
        return Padding( 
        padding: const EdgeInsets.all(16),
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localKey.tr(), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            if (onErrorAction != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onErrorAction?.call(context);
                },
                child: Text(AppStrings.common.retry.tr()),
              ),
          ],
        ));

      case ExceptDisplayType.toast:
        return Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localKey.tr(),
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        );

      case ExceptDisplayType.overlay:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(localKey.tr(), style: theme.textTheme.titleMedium),
            ],
          ),
        );
    }
  }
}





// Ошибка разработчика
class AppError implements Exception {
  final String title;
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.title,
    required this.message,
    this.originalError,
    this.stackTrace,
  });
}



