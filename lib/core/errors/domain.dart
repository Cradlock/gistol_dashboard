

import 'package:flutter/foundation.dart';

@immutable
abstract class AppException implements Exception {
  
  final String localKey;
  final bool shouldShowToUser;

  const AppException(
    this.localKey,{this.shouldShowToUser = false});
  
}



