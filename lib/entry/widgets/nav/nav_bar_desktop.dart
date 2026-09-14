

import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/widgets/app_icon.dart';
import 'package:gistol_dashboard/entry/domains/nav_item.dart';
import 'package:gistol_dashboard/entry/entry.dart';
import 'package:gistol_dashboard/entry/widgets/nav/btn.dart';
import 'package:gistol_dashboard/entry/widgets/nav/icon.dart';
import 'package:go_router/go_router.dart';


class NavBarDesktop extends StatefulWidget {
  final List<NavItem> routes;
   
  const NavBarDesktop({required this.routes});
  
  @override
    State<StatefulWidget> createState() {
      return _NavBarDesktop();
    }
}

class _NavBarDesktop extends State<NavBarDesktop> {
    @override
    Widget build(BuildContext context) {
      final colors = Theme.of(context).colorScheme;

      return Container( 
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavAppIcon(),
            const SizedBox(height: 16),
            Expanded(child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: widget.routes.map((item) {

                final bool isSelected = AppRouter.router.state.uri.path.startsWith(item.path);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0), // Отступ между кнопками
                  child: NavBtn(
                    icon: Icon(item.icon),      
                    label: item.label,      
                    path: item.path,      
                    isSelected: isSelected,      
                    selectedIcon: Icon(item.selectedIcon),
                  ),
                );

              }).toList()
            ))
          ]   
        )
      ); 

    }

}
