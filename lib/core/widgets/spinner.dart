


import 'package:flutter/material.dart';

class StandardSpinner extends StatelessWidget {
  const StandardSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 4.0, // Толщина линии
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), // Цвет спиннера
      ),
    );
  }
}
