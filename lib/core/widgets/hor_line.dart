import 'package:flutter/material.dart';

class RangeDivider extends StatelessWidget {
  const RangeDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 16,
        height: 2,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
