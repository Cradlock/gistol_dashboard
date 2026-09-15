


import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/domains/nav_item.dart';
import 'package:gistol_dashboard/entry/entry.dart';
import 'package:gistol_dashboard/entry/widgets/nav/nav_bar_mobile.dart';
import 'package:gistol_dashboard/entry/widgets/nav/nav_bar_desktop.dart';
import 'package:gistol_dashboard/entry/widgets/nav/nav_bar_mobile.dart';

class Mainlayout extends StatelessWidget{
  
  final List<NavItem> appRoutes = [
  NavItem(
    path: "/home", 
    label: AppStrings.navigation.home, 
    selectedIcon: Icons.home_outlined, 
    icon: Icons.home,
  ),
  NavItem(
    path: "/groups", 
    label: AppStrings.groups.title, 
    selectedIcon: Icons.group_outlined, 
    icon: Icons.group,
  ),
  NavItem(
    path: "/settings", 
    label: AppStrings.settings.title, 
    selectedIcon: Icons.settings_outlined, 
    icon: Icons.settings,
  ),
  NavItem(
    path: "/students", 
    label: AppStrings.students.title, 
    icon: Icons.school, 
    selectedIcon: Icons.school_outlined 
  ),
  NavItem(
    path: "/tasks",
    label: AppStrings.tasks.title,
    icon: Icons.assignment,
    selectedIcon: Icons.assignment_outlined,
  ),
];

  final Widget child;

  Mainlayout({required this.child});
  
    

  @override
    Widget build(BuildContext context) {
      return ResponsiveLayout(
        desktop: Scaffold( 
          body: Row(
            children: [
              NavBarDesktop(routes: appRoutes),
              Expanded(child: child)
            ]
          )
        ),
        mobile: Scaffold(
          body: child,
          
          endDrawer: NavBarMobile(routes: appRoutes),
        )
      );
    }

} 
