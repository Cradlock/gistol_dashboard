
 import 'package:flutter/material.dart';

class NavItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
