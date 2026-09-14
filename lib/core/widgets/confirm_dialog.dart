

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/strings.dart';
import 'package:gistol_dashboard/core/widgets/spinner.dart';

// Универсальная функция для вызова диалога
Future<bool?> showActionConfirmDialog({
  required BuildContext context,
  required String message,
  void Function()? onConfirm, // Сделали функцию необязательной (void)
  bool isCancel = true,
  bool isOk = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // Запрещаем закрывать тапом мимо во время загрузки
    builder: (context) => _ConfirmDialogWidget(
      message: message,
      onConfirm: onConfirm,
      isCancel: isCancel,
      isOk: isOk,
    ),
  );
}

class _ConfirmDialogWidget extends StatefulWidget {
  final String message;
  final void Function()? onConfirm;
  final bool isCancel;
  final bool isOk;

  const _ConfirmDialogWidget({
    required this.message,
    this.onConfirm,
    required this.isCancel,
    required this.isOk,
  });

  @override
  State<_ConfirmDialogWidget> createState() => _ConfirmDialogWidgetState();
}

class _ConfirmDialogWidgetState extends State<_ConfirmDialogWidget> {
  // Внутренний флаг загрузки, который рисует спиннер только внутри этого окна
  bool _isLoading = false;

Future<void> _handleOk() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Выполняем функцию, поддерживая и обычные void, и async функции без ошибок компиляции
      if (widget.onConfirm != null) {
        await Future.sync(widget.onConfirm!);
      }
      
      if (!mounted) return;
      
      // Закрываем диалог и возвращаем true при успешном выполнении
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(false);
    }
  }  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading, // Запрещаем системную кнопку «Назад», пока идет загрузка
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? const SizedBox(
                  height: 80,
                  child: Center(
                    child: StandardSpinner(), // Ваш кастомный спиннер
                  ),
                )
              : Text(widget.message),
        ),
        actions: _isLoading
            ? [] // Скрываем кнопки во время загрузки
            : [
                if (widget.isCancel)
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(AppStrings.common.cancel.tr()),
                  ),
                if (widget.isOk)
                  TextButton(
                    onPressed: _handleOk,
                    child: Text(AppStrings.common.ok.tr()),
                  ),
              ],
      ),
    );
  }
}
