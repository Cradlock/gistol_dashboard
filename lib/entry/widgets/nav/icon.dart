

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gistol_dashboard/core/widgets/app_icon.dart';

class NavAppIcon extends StatelessWidget {

  NavAppIcon();

  @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context); 
      return Container( 
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 12),

        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppIcon(size: 50),
            const SizedBox(width: 15),
            Text("Gistology",style: theme.textTheme.titleLarge)
          ]
        )
      )
      );
    }

} 
