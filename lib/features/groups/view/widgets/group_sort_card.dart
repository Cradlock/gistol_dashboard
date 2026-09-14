

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/core/widgets/app_btn.dart';
import 'package:gistol_dashboard/core/widgets/app_dropdown.dart';
import 'package:gistol_dashboard/core/widgets/label_wrapper.dart';
import 'package:gistol_dashboard/core/widgets/loader_wrapper.dart';
import 'package:gistol_dashboard/features/groups/domain/filter.dart';
import 'package:gistol_dashboard/features/groups/view/provider.dart';
import 'package:provider/provider.dart';

class GroupSortCard extends StatefulWidget {
 
  @override
    State<StatefulWidget> createState() {
      return _GroupSortCard();
    }
}


class _GroupSortCard extends State<GroupSortCard>{
  
  late SortOrder _sortOrder;
  late SortField _sortField;

  bool _isLoading = false;

  @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _init();
      });
    }

  void _init(){
      final provider = context.read<GroupProvider>();
      setState(() {
        _sortField = provider.filterParams.sortField;
        _sortOrder = provider.filterParams.sortType;
      });
  }

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<GroupProvider>();
    setState(() {
          
    _isLoading = true;
        });

    try{
      final newParams = provider.filterParams.copyWith(
        sortType: _sortOrder,
        sortField: _sortField
      );
      await provider.updateFilterParams(newParams);

    } on AppException catch (e) {
      ErrorHandler.handle(e);
    } finally {
      setState(() {
              _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  Future<void> _reset(BuildContext context) async {
     final provider = context.read<GroupProvider>();
    setState(() {
          
    _isLoading = true;
        });

    try{
      await provider.resetFilters();
    } on AppException catch (e) {
      ErrorHandler.handle(e);
    } finally {
      setState(() {
              _isLoading = false;
            });
      Navigator.pop(context);
    }
  }


  @override
    Widget build(BuildContext context) {
      final provider = context.watch<GroupProvider>();

      return PopScope( 
      canPop: !_isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Row( 
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.groups.sort.tr()),
                  AppBtn( 
                    text: AppStrings.groups.resetSort.tr(),
                    type: AppButtonType.text,
                    onPressed: () async => _reset(context)
                  )
                ]
            ),
            const SizedBox(height: 16),
            // Sort Order 
            LabelWrapper( 
            label: AppStrings.groups.sortOrder.tr(),
            child: AppDropdown<SortOrder>( 
              items: SortOrder.values ,
              value: _sortOrder,
              itemAsString: (value) => value.trKey.tr(), 
              onChanged: (value) => setState(() {
                if(value != null){
                  _sortOrder = value;
                }
              })
            )),
            const SizedBox(height: 16),
            // Sort Field 
            LabelWrapper(
              label: AppStrings.groups.sortField.tr(), 
              child: AppDropdown<SortField>(
                value: _sortField, 
                items: SortField.values, 
                itemAsString:(item) => item.trKey.tr(), 
                onChanged: (value) => setState(() {
                  if(value != null){
                      _sortField = value;
                  }
                })
              )
            ),


            const SizedBox(height: 16),
            LocalLoaderWrapper( 
              isLoading: _isLoading,
              child: Row( 
                children: [
                  AppBtn(
                    type: AppButtonType.outlined,
                    text: AppStrings.common.cancel.tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  AppBtn(
                    type: AppButtonType.filled,
                    text: AppStrings.common.save.tr(),
                    onPressed: () => _submit(context)

                  )
                ]
              )
            )
        ]
      )
      );
    }
}
