import 'package:gistol_dashboard/core/core.dart';

class TaskNotFoundError extends AppException {
  TaskNotFoundError()
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.tasks.errorNotFound,
        );
}

class TaskInvalidError extends AppException {
  TaskInvalidError()
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.tasks.errorInvalid,
        );
}
