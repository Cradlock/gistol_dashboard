

import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/widgets/responsive_layout.dart';

class BlockContainer extends StatelessWidget {
  final double? maxWidth;
  final double? minWidth;
  final double? maxHeight;
  final double? minHeight;

  final Widget navBar;
  final Widget content;
  
  const BlockContainer({super.key,
    required this.navBar,
    required this.content,
    this.maxWidth , 
    this.minWidth , 
    this.maxHeight ,
    this.minHeight
  });


  @override
    Widget build(BuildContext context) {
      Widget innerContent = content;

      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints( 
            minWidth: minWidth ?? 0.0,
            maxWidth: maxWidth ?? double.infinity,
            minHeight: minHeight ?? 0.0,
            maxHeight: maxHeight ?? double.infinity
          ),
          child: Container( 
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding( 
            padding: EdgeInsets.all(16),
            child:Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                navBar,
                const SizedBox(height:12),
                Flexible(child: ClipRRect(
                  borderRadius: const BorderRadius.vertical( 
                    bottom: Radius.circular(24)
                  ),
                  child: innerContent,
                ))
              ]
            )
            ),
          )
        )
      ); 
    }
}
