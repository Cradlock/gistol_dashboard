import 'package:flutter/material.dart';
import 'app_input.dart'; // Твой базовый инпут

class AppDateInput extends StatefulWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? label;
  final String? placeholder;
  final String? errorText;

  const AppDateInput({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.errorText,
  });

  @override
  State<AppDateInput> createState() => _AppDateInputState();
}

class _AppDateInputState extends State<AppDateInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatDate(widget.value));
  }

  @override
  void didUpdateWidget(covariant AppDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем текст, если value изменилось снаружи (например, при сбросе фильтров)
    if (widget.value != oldWidget.value) {
      _controller.text = _formatDate(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    // Здесь можно использовать твою функцию formatDate(context, date)
    // или стандартное форматирование:
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _controller.text = _formatDate(picked);
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: _controller,
      label: widget.label,
      placeholder: widget.placeholder,
      errorText: widget.errorText,
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today, size: 18),
        onPressed: () => _pickDate(context),
      ),
      // Если хочешь по клику на весь инпут открывать календарь:
      onTap: () => _pickDate(context),
    );
  }
}
