


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

class SessionExpired extends AppException {
  SessionExpired() : super(
    displayType: ExceptDisplayType.redirect,
    onErrorAction: (BuildContext context) => context.go("/login"),
    localKey: ""
  );
}



