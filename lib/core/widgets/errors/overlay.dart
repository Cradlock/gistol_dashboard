import 'package:flutter/material.dart';

class AppOverlay extends StatelessWidget {
  
  final Widget Function(BuildContext context) builder;

  const AppOverlay({
    super.key,
    required this.builder
  });
static void hide(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return   PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: Colors.transparent, // Прозрачный фон
        body: SizedBox.expand(
          child: builder(context),
        ),
      ),
    );
  }
}
