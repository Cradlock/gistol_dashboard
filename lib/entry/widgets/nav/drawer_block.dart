import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DrawerBlock extends StatelessWidget{

  const DrawerBlock({super.key});
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(                   
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero 
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close,size: 20,color: colors.onSurface))
                    ]
                  ),     
                  

                  const SizedBox(height: 20),
                  
                  ListTile(
                    title:Text("navigation.menu_title".tr(),style: Theme.of(context).textTheme.titleLarge),
                  ),
                   
                 ListTile( 
                    leading: const Icon(Icons.home),
                    title: Text("navigation.home_btn".tr(), style: Theme.of(context).textTheme.titleMedium),
                    onTap: () {
                      context.push("/home");
                      Navigator.pop(context);
                    },
                  ),

                  ListTile( 
                    leading: const Icon(Icons.settings),
                    title: Text("navigation.settings_btn".tr(), style: Theme.of(context).textTheme.titleMedium ),
                    onTap: () {
                      context.push("/settings");
                      Navigator.pop(context);
                    }
                  ),

                  const Spacer(),

                  ListTile(
                    dense: true, // Делает элемент чуть компактнее
                    title: Text("documents.terms_title".tr(), style: Theme.of(context).textTheme.bodyMedium ),
                    onTap: () => context.push('/service'),
                  ),
                  ListTile(
                    dense: true,
                    title: Text("documents.privacy_title".tr(), style: Theme.of(context).textTheme.bodyMedium),
                    onTap: () => context.push('/policy'),
                  )
                ],
            ),
    
          )

        )
      );

  }
}


