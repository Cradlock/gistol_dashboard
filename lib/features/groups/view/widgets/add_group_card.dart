import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:provider/provider.dart'; // если используешь Provider

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AddGroupCard extends StatefulWidget {
  const AddGroupCard({super.key});

  @override
  State<AddGroupCard> createState() => _AddGroupCardState();
}

class _AddGroupCardState extends State<AddGroupCard> {
  final _nameController = TextEditingController();
  int? _selectedYear;
  bool _isSubmitted = false;
  bool _isLoading = false; 

  @override
    void initState() {
      super.initState();
    }
  
  

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Геттеры для проверки на ошибки
  String? get _nameError {
    if (!_isSubmitted) return null;
    if (_nameController.text.trim().isEmpty) {
      return AppStrings.common.errorBlankInput.tr(); 
    }
    return null;
  }

  String? get _yearError {
    if (!_isSubmitted) return null;
    if (_selectedYear == null) {
      return AppStrings.common.errorBlankInput.tr(); 
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _isSubmitted = true; // Включаем показ ошибок, если что-то не заполнено
    });

    // Если есть хотя бы одна ошибка — прерываем отправку
    if (_nameError != null || _yearError != null) return;

    final provider = context.read<GroupProvider>();
    final data = GroupCreate(
      title: _nameController.text.toUpperCase().trim(),
      year: _selectedYear!,
    );

    try {
      await provider.addGroup(context, data);
      if (!context.mounted) return;
      Navigator.pop(context); // Закрываем при успехе
    } on AppException catch (e) {
      if (!context.mounted) return;
      ErrorHandler.handle(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final years = groupProvider.years;
   return 
       Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(context, DateTime.now()),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16),

              AppInput(
                 formatters: [
                 FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ0-9\s-]')),
                  _UpperCaseTextFormatter()
                 ],
                 controller: _nameController,
                 placeholder: AppStrings.groups.addPlaceholderTitle.tr(),
                 errorText: _nameError, // Подсветит поле красным и выведет текст ошибки
                 onChanged: (_) => setState(() { }), // Убирает ошибку при вводе текста
              ),

              const SizedBox(height: 16),

              AppDropdown<int>(
              items: years,
              itemAsString: (year) => year.toString(), 
              placeholder: AppStrings.groups.addPlaceholderCourse.tr(),
              errorText: _yearError,
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;                  
                });
              }
              ),
                
              const SizedBox(height: 16),
              
              // Кнопки
              
              LoaderWrapper( 
              loading: groupProvider.isOperationLoading,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppBtn(
                    onPressed: () => Navigator.pop(context),
                    type: AppButtonType.text,
                    text: AppStrings.common.cancel.tr(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _submit(context),
                    child: Text(AppStrings.common.create.tr()),
                  ),
                ],
              )
              ) 


            ],
          ),
        ),
    );
  }
}
