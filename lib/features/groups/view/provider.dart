


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/app_router.dart';
import 'package:gistol_dashboard/entry/screens/no_internet_screen.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:gistol_dashboard/features/groups/domain/filter.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/groups/services/main.dart';
import 'package:web/web.dart';

class GroupProvider extends ChangeNotifier {
  final _service = GroupService();

  final ValueNotifier<bool> isOperationLoading = ValueNotifier(false);
  final ValueNotifier<bool> isUpdateGroupsLoading = ValueNotifier(false);

  final ValueNotifier<List<Group>> groups = ValueNotifier([]);
  
  final ValueNotifier<List<int>> selectedGroups = ValueNotifier([]);

  List<int> years = [];    
  
  Timer? _debounceTimer;


  // [Filter/Sort parameters] 
  int _currentPage = 1;
  int _pageSize = 16;
  bool _hasMore = true;
  
  FilterParams filterParams = FilterParams(
    sortType: SortOrder.minToMax,
    sortField: SortField.date,
  );
  
  GroupProvider() {}
    
  Future<void> updateFilterParams(FilterParams newP) async {
    filterParams = newP;
    try {
      debugPrint("[GroupProvider] Update filter params");
      await fetchGroups(isRefresh: true);

    } on AppException catch(e) {
      ErrorHandler.handle(e);
    }
  }

  Future<void> initYears() async {
    final yearsRes = await _service.getYears();
    years = yearsRes.data!.years;
  }

  Future<void> initData() async {
    
    isOperationLoading.value = true;
    debugPrint("Start get years:...");
    try {
      await initYears();
     debugPrint("Year gettet: "+years.toString());
      debugPrint("Groups gettet: ");
      await fetchGroups();
    } 
    finally {
      
      isOperationLoading.value = false;
    }
  }
  
  bool isReady(){
    return years.isNotEmpty;
  }

  // Update Groups 
  Future<void> fetchGroups(
    {bool isRefresh = true}    
  ) async {
    if(isRefresh) {
      _currentPage = 1;
      _hasMore = true;
    } 
    
    if(!_hasMore) return;

    try {
      isUpdateGroupsLoading.value = true;
      
      final response = await _service.getGroups(
        _currentPage,
        _pageSize,
        filterParams
      );

      switch (response.statusCode) {
              case 401:
                throw SessionExpired();
      }

      final GroupResponse? newGroups = response.data;
      if(newGroups == null) return;

      if(isRefresh){
        groups.value = newGroups.groups;
      } else {
        groups.value = [...groups.value,...newGroups.groups];
      }
          
      _hasMore = newGroups.total >= _pageSize;
      _currentPage++;
    } finally {
      isUpdateGroupsLoading.value = false;
    }
  }

  
  void onSearchChanged(String query) {
    if(_debounceTimer?.isActive ?? false ) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(seconds: 1), () {
      filterParams.title = query;
      try {
        fetchGroups(isRefresh: true);
      } on AppException catch(e){
        ErrorHandler.handle(e);
      }
      debugPrint("[On onSearchChanged\]");
    });
  }

  void onSortChanged(SortField field,SortOrder order){
    filterParams.sortField = field;
    filterParams.sortType = order;
  }
  
  void updateFilter(FilterParams Function(FilterParams current) updateLogic) {
    // 1. Создаем новые параметры с помощью переданной функции
    filterParams =updateLogic(filterParams);
    
  } 
  
  void updateGroups() {
    fetchGroups(isRefresh: true);
  }
  
  Future<void> resetFilters() async {
    filterParams = FilterParams( sortType: SortOrder.minToMax,sortField: SortField.date );
    await fetchGroups(isRefresh: true);
  }
  

  Future<void> addGroup(BuildContext context,GroupCreate data) async {
      isOperationLoading.value = true;
      try{
      final response = await _service.createGroup(data);
      
      debugPrint("[ADD group] Send create group" + response.statusCode.toString());
      
      switch (response.statusCode) {
          case 409:
            throw GroupDuplicateError();
          case 200:
            groups.value = [...groups.value, response.data!];      
      }

      } finally {

        isOperationLoading.value = false;
      }
  }
  

  void toggleGroupSelect(int id) {
    // Создаем копию текущего списка элементов
  final updatedList = List<int>.from(selectedGroups.value);

  if (updatedList.contains(id)) {
    // Если id уже есть — убираем его (снимаем выделение)
    updatedList.remove(id);
  } else {
    // Если id нет — добавляем (выделяем)
    updatedList.add(id);
  }

  // Обновляем ValueNotifier новым списком
  selectedGroups.value = updatedList; 
  } 
// Установить сразу готовый список выбранных ID (для "Выбрать все")
void setSelectedGroups(List<int> ids) {
  selectedGroups.value = List<int>.from(ids);
}

// Очистить все выбранные элементы
void clearSelectedGroups() {
  selectedGroups.value = [];
}

// Удалить выбранные группы
Future<void> deleteSelectedGroups() async {
  try {
    isOperationLoading.value = true; 
    
    final GroupBulkDelete data = GroupBulkDelete(ids: selectedGroups.value);
    final result = await _service.deleteGroups(data);

    await fetchGroups();
    
    selectedGroups.value = [];

  } finally {
    isOperationLoading.value = false;
  }

}

}

