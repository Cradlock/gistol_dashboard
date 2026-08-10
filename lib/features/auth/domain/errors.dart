


import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
// =============================================================================
// SYSTEM ERRORS ("system")
// =============================================================================

abstract class SystemException extends AppException {
  const SystemException(
    super.localKey, {
    super.shouldShowToUser = false,
  });
}

/// "User not authorized (not tokens)"
class NoAuthException extends SystemException {
  const NoAuthException()
      : super('system.no_auth', shouldShowToUser: false);
}



/// "Server error"
class ServerTroubleException extends SystemException {
  const ServerTroubleException()
      : super('system.server_trouble', shouldShowToUser: true);
}

// =============================================================================
// NETWORK ERRORS ("network")
// =============================================================================
abstract class NetworkException extends AppException {
  const NetworkException(
    super.localKey, {
    super.shouldShowToUser = true, // Ошибки сети обычно показывают пользователю
  });
}

/// "Not internet connections"
class NoConnectionException extends NetworkException {
  const NoConnectionException() : super('network.no_connection');
}



// =============================================================================
// AUTH ERRORS ("auth")
// =============================================================================

abstract class AuthException extends AppException {
  const AuthException(
    super.localKey, {
    super.shouldShowToUser = true, // Ошибки ввода авторизации показывают пользователю
  });
}

/// "Incorrect password or code"
class InvalidSignDataException extends AuthException {
  const InvalidSignDataException() : super('errors.auth.invalid_sign_data');
}

