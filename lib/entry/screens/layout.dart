


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/entry/entry.dart';

class Mainlayout extends StatelessWidget{
  final String? title;

  final Widget child;

  const Mainlayout({super.key,required this.child,required this.title});
  
    

  @override
    Widget build(BuildContext context) {
      final String localTitle = (title ?? "").tr(); 
      return Scaffold( 
        appBar: MainHeader(title: localTitle),
        endDrawer: MainDrawer(),
        body: child
      );
    }

} 
