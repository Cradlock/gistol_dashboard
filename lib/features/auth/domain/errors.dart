


import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/entry.dart';
import 'package:go_router/go_router.dart';

// =============================================================================
// AUTH ERRORS ("auth")
// =============================================================================


/// "Incorrect password or code"
class InvalidSignDataException extends AppException {
  InvalidSignDataException() : 
    super(
      displayType: ExceptDisplayType.toast,
      localKey: AppStrings.auth.error_incorrect_password_or_code
    );
}

class InvalidCurrentPasswordException extends AppException {
  InvalidCurrentPasswordException()
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.auth.errorWrongPassword,
        );
}

class DuplicateAdminLoginException extends AppException {
  DuplicateAdminLoginException()
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.auth.errorDuplicateLogin,
        );
}

class PasswordMismatchException extends AppException {
  PasswordMismatchException()
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.auth.errorPasswordMismatch,
        );
}

class WeakPasswordException extends AppException {
  WeakPasswordException()
      : super(
          displayType: ExceptDisplayType.toast,
          localKey: AppStrings.auth.errorWeakPassword,
        );
}

class SessionExpired extends AppException {
  SessionExpired() : super(
    displayType: ExceptDisplayType.redirect,
    onErrorAction: (BuildContext context) => context.go("/login"),
    localKey: ""
  );
}



