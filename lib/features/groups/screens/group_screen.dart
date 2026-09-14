

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/features/groups/view/provider.dart';
import 'package:gistol_dashboard/features/groups/view/widgets/group_list.dart';
import 'package:gistol_dashboard/features/groups/view/widgets/navBar.dart';
import 'package:provider/provider.dart';


class GroupScreen extends StatefulWidget {  
  const GroupScreen({super.key});
  
  @override
    State<StatefulWidget> createState() {
      return _GroupScreenState();
    }
} 


class _GroupScreenState extends State<GroupScreen> {
    
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _initData();
    });
  }
  
  Future<void> _initData() async {
    final provider = context.read<GroupProvider>();
    if (!provider.isReady()){
      try{
        await provider.initData();
      } on AppException catch (e){
        ErrorHandler.handle(e);
      }
    }
  }

  @override 
  Widget build(BuildContext context) {
      final provider = context.watch<GroupProvider>();

    return Padding( 
    padding: EdgeInsets.all(32),
    child: Column( 
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(AppStrings.groups.title.tr(),style: Theme.of(context).textTheme.displayLarge),
    Expanded(  
    child:LoaderWrapper(loading: provider.isOperationLoading, child:  BlockContainer(
      maxWidth: 1200,
      maxHeight: 700,
      navBar: GroupNavbar(), 
      content: GroupList()
    )))
    ]
    ));
  }
}

