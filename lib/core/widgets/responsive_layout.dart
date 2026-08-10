import 'package:flutter/material.dart';

abstract class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget desktop;
  
  final Widget? tablet;
  final Widget? mobile;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    this.tablet,
    this.mobile,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.mobile &&
      MediaQuery.sizeOf(context).width < Breakpoints.tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return desktop;
        }
        if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? desktop; // Если планшет не задан, показываем десктоп
        }
        return mobile ?? tablet ?? desktop; // Fallback на десктоп
      },
    );
  }
}
