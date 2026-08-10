


import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const MainHeader({super.key,this.title});
  
  ButtonStyle _getBtnStyle(BuildContext context) => IconButton.styleFrom(
                         backgroundColor: Theme.of(context).colorScheme.onSurface,
                         foregroundColor: Theme.of(context).colorScheme.surface,
    );
  

  @override
    Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.path;
    final bool showProfileBtn = currentLocation == '/account';
      
      return AppBar(
            
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            iconTheme: IconThemeData(color:Theme.of(context).colorScheme.onSurface), 
            title: Padding( 
              padding: const EdgeInsetsGeometry.only(right: 16,top: 16),
              child:  
                Text (
                  title ?? "",
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge 
                )
          
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsGeometry.only(right: 16,top: 16),
                child: Row(
                  spacing: 20,
                  children: [
                     
                      FilledButton.icon(onPressed: () {
                          context.go(!showProfileBtn ? "/account" : "/home"); 
                        },
                        label: Text(!showProfileBtn ? "navigation.account_btn".tr() : "navigation.home_btn".tr()),
                        icon: Icon(!showProfileBtn ? Icons.account_circle_sharp : Icons.home , size: 20), 
                        style: _getBtnStyle(context).merge(ButtonStyle(
                        shape:WidgetStatePropertyAll(StadiumBorder()),
                        minimumSize: WidgetStateProperty.all(Size(0,50))
                        ))
                      ),
                     IconButton.filledTonal(
                       onPressed: () => Scaffold.of(context).openEndDrawer(),
                       icon: const Icon(Icons.menu, size: 20),
                       style: _getBtnStyle(context) 
                     ),
                  ] 
                )
              )
            ]
          );
    }

  @override 
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
  
}


