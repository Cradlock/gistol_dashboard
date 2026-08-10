

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/features/settings/settings.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget{
  const SettingsScreen({super.key});
  

  void _showLangDialog(BuildContext context){
    final settingsProvider = Provider.of<SettingsProvider>(context,listen: false);
  
    final List<Locale> supported = context.supportedLocales;
    
    showDialog(
      context:context, 
      builder: (BuildContext context) {
        return AlertDialog( 
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supported.map((locale) {
              final String code = locale.languageCode;
              
              final Map<String,String>? details = SettingsProvider.langDetails[code];
              final String name = details?['name'] ?? code.toUpperCase(); 
              final String flag = details?['flag'] ?? 'assets/nothging.png';
              final bool isSelected = context.locale.languageCode == code;

              return ListTile(
                leading: ClipRRect( borderRadius: BorderRadius.circular(16),
                child: Image.asset(flag,width: 32,height: 32,fit: BoxFit.cover)),
                trailing: isSelected ? const Icon(Icons.check) : null,
                title: Text(name),
                onTap: () {
                  settingsProvider.changeLanguage(context, locale);
                  Navigator.pop(context);
                },
              );
              }).toList()   
          )
        );
      }
    );

  }

  @override
  Widget build(BuildContext context) {
      final settingsProvider = Provider.of<SettingsProvider>(context);
      
      final String currentCode = context.locale.languageCode;

      final String currentLanguageName = SettingsProvider.langDetails[currentCode]?['name'] ?? currentCode.toUpperCase();

      return SingleChildScrollView( 
        padding: const EdgeInsets.all(16),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            

            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 5,
              child: Column( 
                children: [
                  
                  SwitchListTile(
                    title: Text("settings.settings_darkmode".tr()),
                    secondary: const Icon(Icons.dark_mode),
                    value: settingsProvider.isDarkMode, 
                    onChanged: (val) => settingsProvider.toggleTheme(val)
                  ),
                  
                  ListTile(
                    title: Text("settings.settings_langmode".tr()),
                    leading: const Icon(Icons.language),
                    trailing: Text( currentLanguageName,style: Theme.of(context).textTheme.titleMedium ),
                    onTap: () {
                      _showLangDialog(context);
                    },
                  )

                ]
              ) 
            )

          ],
        ),
      );
    }

}

