


import 'package:gistol_dashboard/core/widgets/errors/modal.dart';
import 'package:gistol_dashboard/core/widgets/errors/overlay.dart';
import 'package:gistol_dashboard/entry/entry.dart';

import './domain.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class ErrorHandler {

  ErrorHandler._();

    
  static void handle(
    Exception error, {
      BuildContext? context
    }
  ){


    if(error is AppException){
      debugPrint('[ErrorHandler]: Caught ${error.runtimeType}., Has on Action: ${error.onErrorAction.toString()}'); 
      
        WidgetsBinding.instance.addPostFrameCallback((_) {
        
         final targetContext = context ?? navigatorKey.currentContext;
         if (targetContext == null || !targetContext.mounted) {
           debugPrint('[ErrorHandler]: Target context is null or unmounted.');
           return;
         }


        switch (error.displayType) {
                  case ExceptDisplayType.modal:
                    showDialog<void>(context: targetContext, 
                      
                      builder: (BuildContext context) { 
                        return AppModal(
                          builder: error.buildCustomDialog
                        );  
                      });

                    break;
                  case ExceptDisplayType.toast:
                    ScaffoldMessenger.of(targetContext) 
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          elevation: 4,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(targetContext).colorScheme.errorContainer,
                          content: error.buildCustomDialog(targetContext)
                        )
                      ); 
                    break;
                  case ExceptDisplayType.overlay:
                    showDialog<void>(
                      context: targetContext, 
                      barrierDismissible: false,
                      useSafeArea: true,
                      builder: (context) => AppOverlay(builder: error.buildCustomDialog)
                    );

                    break;
                  case ExceptDisplayType.redirect:
                    error.onErrorAction?.call(targetContext);
                    break; 
                }
              });

    }
   
    if(error is AppError){
      
      final targetContext = context ?? navigatorKey.currentContext;
      debugPrint('[Error handler - FATAL] :${error.title}');
      if ( targetContext != null){
        _showError(targetContext,error);
      }
    }


  }

  static void _showError(BuildContext context,AppError error){
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (overlayContext) => Material(
        color: const Color(0xFFB00020), // Глубокий красный цвет
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48, // Растягивает на весь экран
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          error.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const Spacer(), // ПРИЖИМАЕТ КНОПКУ К НИЗУ
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red.shade900,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => entry.remove(),
                            child: const Text(
                              'Закрыть',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Вставляем оверлей в глобальное дерево виджетов
    Overlay.of(context).insert(entry);
  }


}

