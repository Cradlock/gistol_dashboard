
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:go_router/go_router.dart';

class ContractMismatchError extends Error {
  final String path;
  final Type targetType;
  final Object originalError;
  final StackTrace? originalStackTrace;

  ContractMismatchError({
    required this.path,
    required this.targetType,
    required this.originalError,
    this.originalStackTrace,
  });

  @override
  String toString() {
    return '🔥 [Contract Mismatch Error]:\n'
           '• Endpoint: $path\n'
           '• Expected Model (Type): $targetType\n'
           '• Reason: $originalError\n'
           '${originalStackTrace != null ? '• StackTrace:\n$originalStackTrace' : ''}';
  }
}

/// Отсутствие интернет-соединения -> Блокирующий Fullscreen Overlay
class NoInternetException extends AppException{
  NoInternetException({super.onErrorAction})
      : super(
          displayType: ExceptDisplayType.overlay,
          localKey: AppStrings.common.error_no_internet,
        );
}

/// Сервер недоступен (500, 502, 503) -> Модальное окно или Тост
class ServerException extends AppException {
  ServerException()
      : super( 
          onErrorAction: (BuildContext context){
            context.go("/");
          },
         displayType: ExceptDisplayType.modal,
          localKey: AppStrings.common.error_server_error,
        );
}

/// Таймаут запроса -> Тост
class TimeoutException extends AppException {
  TimeoutException({super.onErrorAction})
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.common.error_timeout,
        );
}
