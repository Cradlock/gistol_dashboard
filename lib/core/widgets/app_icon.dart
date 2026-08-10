import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size; // Размер иконки (и ширина, и высота)

  // Конструктор с обязательным параметром размера
  const AppIcon({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Небольшая подложка на случай прозрачного PNG (берем из темы)
        color: colors.primary.withOpacity(0.1), 
        image: const DecorationImage(
          image: AssetImage('assets/app_icon.png'),
          fit: BoxFit.contain, // Растягивает картинку, чтобы она заполнила весь круг без искажений
        ),
      ),
    );
  }
}
