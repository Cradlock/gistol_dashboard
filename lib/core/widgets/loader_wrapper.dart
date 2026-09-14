


import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/widgets/spinner.dart';

class LocalLoaderWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget Function()? loadingBuilder;

  // 1. Обычный конструктор для локального bool (например, _isLoading)
  const LocalLoaderWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder?.call() ?? const StandardSpinner();
    }
    return child;
  }
}

class LoaderWrapper extends StatelessWidget{
  final ValueNotifier<bool> loading;
  final Widget child;
  final Widget Function()? loadingBuilder;


  const LoaderWrapper({
    super.key,
    required this.loading,
    required this.child,
    this.loadingBuilder,
  });
  
  @override
    Widget build(BuildContext context) {
      return ValueListenableBuilder(
        valueListenable: loading,
        builder: (context,isLoading,cachedChild) {
          if(isLoading) return loadingBuilder?.call() ?? const StandardSpinner();
          
          return cachedChild!;
        },
        child: child,
      ); 
    }

}
