




import 'package:flutter/material.dart';

class AppToast extends StatelessWidget {

  final Widget Function(BuildContext context) builder;
  final Duration duration;

  const AppToast({
    required this.builder,
    this.duration = const Duration(seconds: 3)
  });

  @override
    Widget build(BuildContext context) {
      return  SnackBar(
        duration: duration,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        content: builder(context) 
      );
 
 
    }

}
