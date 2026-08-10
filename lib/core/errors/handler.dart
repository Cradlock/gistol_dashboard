


import './domain.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ErrorHandler {

  ErrorHandler._();

    
  static void handle(
    AppException error, {
      BuildContext? context,
      VoidCallback? onAction
    }
  ){
    debugPrint('[ErrorHandler]: Caught ${error.runtimeType}. Key: ${error.localKey}');
    

    if(onAction != null){
      onAction();
    }

    if (!error.shouldShowToUser || context == null) {
      return;
    }
    
    final String message = error.localKey.tr();
    
    _showSnackBar(context, message);

  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

}

