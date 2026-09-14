


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

class GroupFilterCard extends StatefulWidget {
 
  @override
    State<StatefulWidget> createState() {
      return _GroupFilterCard();
    }
}


class _GroupFilterCard extends State<GroupFilterCard>{
  bool _isLoading = false;

  late FilterParams _params;

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
          _params = provider.filterParams;
      });
  }

  Future<void> _submit(BuildContext context) async {
    final provider = context.read<GroupProvider>();
    setState(() {
          
    _isLoading = true;
        });

    try{
      final newParams = provider.filterParams.copyWith(
      );
      await provider.updateFilterParams(newParams);

    } on AppException catch (e) {
      ErrorHandler.handle(e);
    } finally {
      setState(() {
              _isLoading = false;
      });
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
                  Text(AppStrings.groups.filters.tr()),
                  AppBtn( 
                    text: AppStrings.groups.resetFilters.tr(),
                    type: AppButtonType.text,
                    onPressed: () async => _reset(context)
                  )
                ]
            ),
            const SizedBox(height: 16),
            // Course
            LabelWrapper(
              label: AppStrings.groups.filterCourseRangeLabel.tr(), 
              child: Row( 
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child:AppDropdown<int>(
                    value: _params.minYear,
                    items: provider.years, 
                    itemAsString: (i) => i.toString(), 
                    onChanged: (i) => setState(() => _params.minYear = i)  
                  )),
                  RangeDivider(),
                  Expanded(child: AppDropdown(
                    value: _params.maxYear,
                    items: provider.years, 
                    itemAsString: (i) => i.toString(), 
                    onChanged: (i) => setState(() => _params.maxYear = i)
                  ))
                ]
              )
            ),

            const SizedBox(height: 16),
            // Date 
            LabelWrapper(
              label: AppStrings.groups.filterDateRangeLabel.tr(), 
              child: Row( 
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                 Expanded(
                     child: AppDateInput(
                       value: _params.minDate,
                       placeholder: AppStrings.common.from.tr(),
                       onChanged: (date) => setState(() {
                         _params.minDate = date;
                       }),
                     ),
                  ),
                  const RangeDivider(),
                  Expanded(
                    child: AppDateInput(
                      value: _params.maxDate,
                      placeholder: AppStrings.common.to.tr(),
                      onChanged: (date) => setState(() {
                        _params.maxDate = date;
                      }),
                    ),
                  ),                
                ]
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
