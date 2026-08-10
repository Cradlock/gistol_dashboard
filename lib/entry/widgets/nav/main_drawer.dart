



import 'package:gistol_dashboard/core/widgets/responsive_layout.dart';
import 'package:gistol_dashboard/entry/entry.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget{
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
      

      return ResponsiveLayout(
        desktop: SizedBox(
          width: 500,
          child: DrawerBlock() 
        ),
        mobile: SizedBox( 
          width: double.infinity,
          child: DrawerBlock(),
        )
      );

  }  

}
