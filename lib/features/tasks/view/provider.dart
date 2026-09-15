import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gistol_dashboard/features/tasks/domain/errors.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';
import 'package:gistol_dashboard/features/tasks/services/tasks_service.dart';

class TasksProvider extends ChangeNotifier {
  final _service = TasksService();

  final ValueNotifier<bool> isOperationLoading = ValueNotifier(false);
  final ValueNotifier<bool> isUpdateLoading = ValueNotifier(false);
  final ValueNotifier<List<SituationTask>> tasks = ValueNotifier([]);
  final ValueNotifier<List<int>> selectedTasks = ValueNotifier([]);
  final ValueNotifier<List<StudentAnswer>> answers = ValueNotifier([]);
  final ValueNotifier<bool> isAnswersLoading = ValueNotifier(false);

  int? groupIdFilter;
  String searchQuery = '';
  Timer? _debounceTimer;

  List<SituationTask> get visibleTasks {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return tasks.value;
    return tasks.value
        .where((task) => task.title.toLowerCase().contains(query))
        .toList();
  }

  Future<void> initData() async {
    isOperationLoading.value = true;
    try {
      await fetchTasks();
    } finally {
      isOperationLoading.value = false;
    }
  }

  Future<void> fetchTasks() async {
    isUpdateLoading.value = true;
    try {
      final response = await _service.getTasks(groupId: groupIdFilter);
      tasks.value = response.data?.tasks ?? [];
      selectedTasks.value = [];
    } finally {
      isUpdateLoading.value = false;
    }
  }

  Future<void> applyGroupFilter(int? groupId) async {
    groupIdFilter = groupId;
    await fetchTasks();
    notifyListeners();
  }

  void onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      searchQuery = query;
      notifyListeners();
    });
  }

  Future<void> addTask(TaskWriteRequest data) async {
    isOperationLoading.value = true;
    try {
      final response = await _service.createTask(data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        tasks.value = [...tasks.value, response.data!];
        return;
      }
      if (response.statusCode == 404) throw TaskNotFoundError();
      if (response.statusCode == 422 || response.statusCode == 400) {
        throw TaskInvalidError();
      }
    } finally {
      isOperationLoading.value = false;
    }
  }

  Future<void> deleteSelectedTasks() async {
    isOperationLoading.value = true;
    try {
      for (final id in List<int>.from(selectedTasks.value)) {
        await _service.deleteTask(id);
      }
      selectedTasks.value = [];
      await fetchTasks();
    } finally {
      isOperationLoading.value = false;
    }
  }

  void toggleTaskSelect(int id) {
    final updated = List<int>.from(selectedTasks.value);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    selectedTasks.value = updated;
  }

  void setSelectedTasks(List<int> ids) {
    selectedTasks.value = List<int>.from(ids);
  }

  void clearSelectedTasks() {
    selectedTasks.value = [];
  }

  Future<void> loadAnswers(int taskId) async {
    isAnswersLoading.value = true;
    try {
      final response = await _service.getAnswers(taskId);
      if (response.statusCode == 404) throw TaskNotFoundError();
      answers.value = response.data?.answers ?? [];
    } finally {
      isAnswersLoading.value = false;
    }
  }

  Future<void> reviewAnswer(int answerId, AnswerStatus status) async {
    isAnswersLoading.value = true;
    try {
      final response = await _service.reviewAnswer(
        answerId,
        AnswerReviewRequest(status: status),
      );
      if (!response.isSuccess || response.data == null) {
        throw TaskInvalidError();
      }
      answers.value = answers.value
          .map((item) => item.id == answerId ? response.data! : item)
          .toList();
    } finally {
      isAnswersLoading.value = false;
    }
  }
}
