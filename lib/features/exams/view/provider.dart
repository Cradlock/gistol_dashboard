import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/services/exams_service.dart';

class ExamsProvider extends ChangeNotifier {
  ExamsProvider({ExamsService? service}) : _service = service ?? ExamsService();
  final ExamsService _service;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> isUpdating = ValueNotifier(false);
  final ValueNotifier<List<ExamSummary>> exams = ValueNotifier([]);
  final ValueNotifier<List<int>> selectedExams = ValueNotifier([]);

  int page = 1;
  final int pageSize = 20;
  int total = 0;
  String search = '';
  int? groupIdFilter;
  Timer? _debounce;

  bool get hasPrevious => page > 1;
  bool get hasNext => page * pageSize < total;

  Future<void> initData() => fetchExams(showMainLoader: true);

  Future<void> fetchExams({bool showMainLoader = false}) async {
    (showMainLoader ? isLoading : isUpdating).value = true;
    try {
      final response = await _service.getExams(
        page: page,
        pageSize: pageSize,
        search: search,
        groupId: groupIdFilter,
      );
      _service.ensureSuccess(response);
      exams.value = response.data?.exams ?? [];
      selectedExams.value = [];
      total = response.data?.total ?? 0;
      notifyListeners();
    } finally {
      (showMainLoader ? isLoading : isUpdating).value = false;
    }
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      search = value.trim();
      page = 1;
      await fetchExams();
    });
  }

  Future<void> applyGroupFilter(int? groupId) async {
    groupIdFilter = groupId;
    page = 1;
    await fetchExams();
  }

  Future<void> nextPage() async {
    if (!hasNext) return;
    page++;
    await fetchExams();
  }

  Future<void> previousPage() async {
    if (!hasPrevious) return;
    page--;
    await fetchExams();
  }

  void toggleExamSelect(int id) {
    final updated = List<int>.from(selectedExams.value);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    selectedExams.value = updated;
  }

  void setSelectedExams(List<int> ids) {
    selectedExams.value = List<int>.from(ids);
  }

  void clearSelectedExams() {
    selectedExams.value = [];
  }

  Future<Exam> getExam(int id) async {
    final response = await _service.getExam(id);
    _service.ensureSuccess(response);
    return response.data!;
  }

  Future<Exam> createExam(ExamWriteRequest request) async {
    final response = await _service.createExam(request);
    _service.ensureSuccess(response);
    await fetchExams();
    return response.data!;
  }

  Future<Exam> updateExam(int id, ExamWriteRequest request) async {
    final response = await _service.updateExam(id, request);
    _service.ensureSuccess(response);
    await fetchExams();
    return response.data!;
  }

  Future<void> deleteExam(int id) async {
    final response = await _service.deleteExam(id);
    _service.ensureSuccess(response);
    if (exams.value.length == 1 && page > 1) page--;
    await fetchExams();
  }

  Future<void> deleteSelectedExams() async {
    final ids = List<int>.from(selectedExams.value);
    isLoading.value = true;
    try {
      for (final id in ids) {
        final response = await _service.deleteExam(id);
        _service.ensureSuccess(response);
      }
      if (exams.value.length <= ids.length && page > 1) page--;
      await fetchExams();
    } finally {
      isLoading.value = false;
    }
  }

  Future<Exam> saveTarget(
    Exam exam,
    TargetWriteRequest request, {
    int? targetId,
  }) async {
    final response = targetId == null
        ? await _service.createTarget(exam.id, request)
        : await _service.updateTarget(exam.id, targetId, request);
    _service.ensureSuccess(response);
    return getExam(exam.id);
  }

  Future<Exam> deleteTarget(Exam exam, int targetId) async {
    final response = await _service.deleteTarget(exam.id, targetId);
    _service.ensureSuccess(response);
    return getExam(exam.id);
  }

  Future<Exam> saveQuestion(
    Exam exam,
    QuestionWriteRequest request, {
    int? questionId,
  }) async {
    final response = questionId == null
        ? await _service.createQuestion(exam.id, request)
        : await _service.updateQuestion(exam.id, questionId, request);
    _service.ensureSuccess(response);
    return getExam(exam.id);
  }

  Future<Exam> deleteQuestion(Exam exam, int questionId) async {
    final response = await _service.deleteQuestion(exam.id, questionId);
    _service.ensureSuccess(response);
    return getExam(exam.id);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    isLoading.dispose();
    isUpdating.dispose();
    exams.dispose();
    selectedExams.dispose();
    super.dispose();
  }
}
