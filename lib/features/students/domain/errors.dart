import 'package:gistol_dashboard/core/core.dart';

class NotFoundStudent extends AppException {
  NotFoundStudent()
    : super(
        displayType: ExceptDisplayType.modal,
        localKey: AppStrings.students.error_student_not_found,
      );
}

class InvalidStudentUpdate extends AppException {
  InvalidStudentUpdate()
    : super(
        displayType: ExceptDisplayType.toast,
        localKey: AppStrings.students.errorInvalidUpdate,
      );
}
