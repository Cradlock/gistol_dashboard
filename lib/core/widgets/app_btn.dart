import 'package:flutter/material.dart';

enum AppButtonType { filled, outlined, text }

class AppBtn extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonType type;
  
  // Кастомные параметры
  final EdgeInsetsGeometry? innerPadding;
  final double? borderRadius;
  final double minHeight;
  final double? space;
  
  // Новые параметры цвета
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppBtn({
    super.key,
    this.text = "",
    this.icon,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.innerPadding,
    this.space = 6,
    this.borderRadius,
    this.minHeight = 48.0,
    this.backgroundColor,
    this.foregroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final bool isSquare = icon != null;
    final radius = BorderRadius.circular(borderRadius ?? 16.0);
    final padding = innerPadding ?? EdgeInsets.symmetric(
      horizontal: isSquare ? 0 : 16.0,
      vertical: 0,
    );
    
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20)
        ],
        SizedBox(width:this.text != "" ? this.space : 0),
        Text(
          text!,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minHeight,
        minWidth: isSquare ? minHeight : 0.0,
      ),
      child: _buildButtonByType(context, child, padding, radius),
    );
  }

  Widget _buildButtonByType(BuildContext context, Widget child, EdgeInsetsGeometry padding, BorderRadius radius) {
    final theme = Theme.of(context);
    
    switch (type) {
      case AppButtonType.filled:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor, // Если null, Flutter подставит primary по умолчанию
            foregroundColor: foregroundColor , // Если null, Flutter подставит onPrimary
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: child,
        );
        
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor, // У outlined фон по умолчанию прозрачный, но можно задать кастомный
            foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: child,
        );
        
      case AppButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: child,
        );
    }
  }
}
