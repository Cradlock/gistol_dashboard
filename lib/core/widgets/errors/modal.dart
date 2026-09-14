
import 'package:flutter/material.dart';

class AppModal extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  
  const AppModal({required this.builder});

  @override
    Widget build(BuildContext context) {
      return Dialog( 
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Скругление углов карточки
          ),
          elevation: 8,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: builder(context)
      );     
    }
}
