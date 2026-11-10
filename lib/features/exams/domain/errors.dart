import 'package:gistol_dashboard/core/core.dart';

class ExamNotFoundError extends AppException {
  ExamNotFoundError()
    : super(
        displayType: ExceptDisplayType.toast,
        localKey: AppStrings.exams.errorNotFound,
      );
}

class ExamInvalidError extends AppException {
  ExamInvalidError()
    : super(
        displayType: ExceptDisplayType.toast,
        localKey: AppStrings.exams.errorInvalid,
      );
}

class ExamConflictError extends AppException {
  ExamConflictError()
    : super(
        displayType: ExceptDisplayType.toast,
        localKey: AppStrings.exams.errorConflict,
      );
}

/// 409 при проверке ответа: попытка ещё не сдана студентом.
class ExamReviewConflictError extends AppException {
  ExamReviewConflictError()
    : super(
        displayType: ExceptDisplayType.toast,
        localKey: AppStrings.exams.errorReviewConflict,
      );
}
