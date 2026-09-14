

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBtn extends StatelessWidget {
  final Widget icon;
  final String label;
  final String path;
  final bool isSelected;
  final Widget selectedIcon;
  final bool isExtend;

  const NavBtn({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
    required this.selectedIcon,
    this.isExtend = false
  });

  @override
    Widget build(BuildContext context) {
      final colors = Theme.of(context).colorScheme;
      final fonts = Theme.of(context).textTheme;


      return Material( 
        color: isSelected ? colors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell( 
          onTap: ()=> context.go(path),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 16),
            child: Row(
              children: [ 
                isSelected ? selectedIcon : icon, 
                const SizedBox(width: 16),
                Expanded(child: Text(label.tr(),style: fonts.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colors.primary : colors.onSurface,
                ))),
                if(isSelected)Icon(Icons.arrow_right_outlined)
              ] 
            ),
          )
        )
      );
    }


  }
