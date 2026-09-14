



import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/errors/domain.dart';
import 'package:gistol_dashboard/core/errors/handler.dart';
import 'package:gistol_dashboard/features/auth/domain/user.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';
import 'package:gistol_dashboard/features/students/domain/filter.dart';
import 'package:gistol_dashboard/features/students/domain/student.dart';
import 'package:gistol_dashboard/features/students/services/students_service.dart';
import 'package:provider/provider.dart';

class StudentsProvider extends ChangeNotifier {
  

  final StudentService _service = StudentService();

  // Пагинация 
  bool hasMore = false;
  int pageSize = 20;
  int currentPage = 1; 
  
  // Фильтрауия 
  FilterStudentParams filterParams = FilterStudentParams(
    sortType: SortStudentsOrder.minToMax, 
    sortField: SortStudentsField.year
  );
  
  
  
  // Хранилище
  List<Student> students = [];
  List<int> selectedStudents = [];
  List<int> years = [];

  // Таймер 
  Timer? _debounceTimer;

  // Флаги
  bool isLoadingMore = false;
  
  // Инициализация
  Future<void> init() async {
    await fetchStudents(isRefresh: true); 
  }
  
  // Получение студентов
  Future<void> fetchStudents({bool isRefresh = false}) async {
    if(isRefresh){
      currentPage = 1;
      hasMore = true;
    } 

    if(!hasMore) return;
    if(isLoadingMore) return;
    isLoadingMore = true;   
    notifyListeners();
    try{
      final res = await _service.getUsers(currentPage, pageSize, filterParams);   
      if(res.data != null){ 
      final newStudents = res.data!.students;
      if(isRefresh){
        students = newStudents;
      } else {
        students.addAll(newStudents);
      }
      
      hasMore = (currentPage * pageSize) < res.data!.total;
      if(hasMore){
        currentPage++;
      }
      }

    } on AppException catch(error) {
      ErrorHandler.handle(error);
    } finally{
      isLoadingMore = false;
      notifyListeners();
    }
  }

  FilterStudentParams _defaultFilter() {
    return FilterStudentParams(
      sortType: SortStudentsOrder.minToMax,
      sortField: SortStudentsField.year,
    );
  }

  Future<void> updateFilterParams(FilterStudentParams newParams) async {
    filterParams = newParams;
    selectedStudents.clear();
    await fetchStudents(isRefresh: true);
  }

  Future<void> resetFilterParams() async {
    filterParams = _defaultFilter();
    selectedStudents.clear();
    await fetchStudents(isRefresh: true);
  }

  void onFioChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      filterParams = filterParams.copyWith(fio: query.trim());
      selectedStudents.clear();
      await fetchStudents(isRefresh: true);
    });
  }

  Future<void> loadMoreOnScroll(ScrollController controller) async {
    if (!hasMore || isLoadingMore) return;
    if (!controller.hasClients) return;

    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - 80) {
      await fetchStudents();
    }
  }

  Future<void> showNewStudents() async {
    await updateFilterParams(FilterStudentParams(
      sortType: filterParams.sortType,
      sortField: filterParams.sortField,
      fio: filterParams.fio,
      minYear: filterParams.minYear,
      maxYear: filterParams.maxYear,
      groupId: filterParams.groupId,
      confirmed: false,
      deleted: false,
    ));
  }

  Future<void> showDeletedStudents() async {
    await updateFilterParams(FilterStudentParams(
      sortType: filterParams.sortType,
      sortField: filterParams.sortField,
      fio: filterParams.fio,
      minYear: filterParams.minYear,
      maxYear: filterParams.maxYear,
      groupId: filterParams.groupId,
      confirmed: filterParams.confirmed,
      deleted: true,
    ));
  }

  Future<void> showConfirmedStudents() async {
    await updateFilterParams(FilterStudentParams(
      sortType: filterParams.sortType,
      sortField: filterParams.sortField,
      fio: filterParams.fio,
      minYear: filterParams.minYear,
      maxYear: filterParams.maxYear,
      groupId: filterParams.groupId,
      confirmed: true,
      deleted: false,
    ));
  }

  void toggleStudentSelect(int id) {
    final updated = List<int>.from(selectedStudents);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    selectedStudents = updated;
    notifyListeners();
  }

  void setSelectedStudents(List<int> ids) {
    selectedStudents = List<int>.from(ids);
    notifyListeners();
  }

  void clearSelectedStudents() {
    selectedStudents = [];
    notifyListeners();
  }

  // Потверждение аккаунтов
  Future<void> confirmStudents() async {
    if(selectedStudents.isNotEmpty){
      try{
      final res = await _service.confirmStudents(StudentBulkOperRequest(ids: selectedStudents));  
      if(res.data != null){
        final completed = res.data!.completed.toSet();
        final faileds = res.data!.faileds.toSet();
        
        students = students.map((student) {
          if (completed.contains(student.id)) {
            return student.copyWith(confirmed: true); 
          }
          return student;
        }).toList();
        selectedStudents.removeWhere((id) => completed.contains(id));
        
      } 
      } finally {
        notifyListeners();
      }
    }
  }

  // Удаление аккаунтов
  Future<void> deleteStudents() async {
    if(selectedStudents.isNotEmpty) {
      try{
        final res = await _service.deleteStudents(StudentBulkOperRequest(ids: selectedStudents));
        
        if(res.data != null){
          final completed = res.data!.completed.toSet();

          if(!filterParams.deleted){
            students.removeWhere((item) => completed.contains(item.id));
          } 

          selectedStudents.clear();
        }

      } finally {
        notifyListeners();
      }
    }
  } 
  
  // Отмена подтверждения аккаунтов
  Future<void> unconfirmStudents() async {
    if(selectedStudents.isEmpty) return;
    try{
      final res = await _service.unconfirmStudents(StudentBulkOperRequest(ids: selectedStudents));
      if(res.data != null){
        final completed = res.data!.completed.toSet();

        if(filterParams.confirmed){
          students.removeWhere((item) => completed.contains(item.id));
        } else {
          students = students.map((student) {
            if (completed.contains(student.id)) {
              return student.copyWith(confirmed: false);
            }
            return student;
          }).toList();
        }

        selectedStudents.removeWhere((id) => completed.contains(id));
      }
    } on AppException catch(error) {
      ErrorHandler.handle(error);
    } finally {
      notifyListeners();
    }
  }

  // Восстановление аккаунтов
  Future<void> recoveryStudents() async {
    if(selectedStudents.isEmpty) return;
    try{
      final res = await _service.recoveryStudents(StudentBulkOperRequest(ids: selectedStudents));
      if(res.data != null){
        final completed = res.data!.completed.toSet();

        if(filterParams.deleted){
          students.removeWhere((item) => completed.contains(item.id));
        } else {
          students = students.map((student) {
            if (completed.contains(student.id)) {
              return student.copyWith(deleted: false);
            }
            return student;
          }).toList();
        }

        selectedStudents.removeWhere((id) => completed.contains(id));
      }
    } on AppException catch(error) {
      ErrorHandler.handle(error);
    } finally {
      notifyListeners();
    }
  }


  // Изменение данных студента
  Future<void> editStudent(int id,StudentUpdate data) async {
    final res = await _service.editStudent(id, data);
    
    final newStudent = res.data!;
  
    final index = students.indexWhere((it) => it.id == id);

    if(index != -1){
      students[index] = newStudent;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

}
