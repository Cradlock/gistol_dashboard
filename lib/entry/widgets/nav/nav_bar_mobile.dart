


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/app_router.dart';
import 'package:gistol_dashboard/entry/domains/nav_item.dart';
import 'package:gistol_dashboard/entry/widgets/nav/btn.dart';
import 'package:go_router/go_router.dart';



class NavBarMobile extends StatelessWidget {
  final List<NavItem> routes;
  const NavBarMobile({super.key,required this.routes});

  @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final String currentPath = AppRouter.router.state.uri.path;

      return Drawer( 
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
              Text(
                AppStrings.navigation.menu.tr(),
                style: theme.textTheme.bodyLarge,
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: routes.map((item) {
                    bool isSelected = item.path == currentPath;
                    return ListTile(
                      leading: Icon(isSelected ? item.selectedIcon : item.icon),
                      title: Text(item.label.tr()),
                      selected: isSelected,
                      onTap: (){
                        Navigator.of(context).pop();
                        context.go(item.path);
                      }
                    );
                  }).toList() 
                )
              )
              ]
            ) 
          )
        )
      );
    }

}
