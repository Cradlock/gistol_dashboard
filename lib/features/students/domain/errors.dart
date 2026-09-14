


import 'package:gistol_dashboard/core/core.dart';

class NotFoundStudent extends AppException {
  NotFoundStudent() : super(
    displayType: ExceptDisplayType.modal,
    localKey: AppStrings.students.error_student_not_found
  );
}
