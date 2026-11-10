import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';
import 'package:gistol_dashboard/features/exams/domain/errors.dart';
import 'package:gistol_dashboard/features/exams/domain/session.dart';

class ExamsService {
  final ApiClient _api;
  ExamsService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<WrResponse<ExamListResponse>> getExams({
    required int page,
    required int pageSize,
    String? search,
    int? groupId,
  }) => _api.get(
    'exams/',
    converter: ExamListResponse.converter,
    queryParameters: {
      'page': page,
      'page_size': pageSize,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (groupId != null) 'group_id': groupId,
    },
  );

  Future<WrResponse<Exam>> getExam(int id) =>
      _api.get('exams/$id', converter: Exam.converter);

  Future<WrResponse<Exam>> createExam(ExamWriteRequest data) =>
      _api.post('exams/', converter: Exam.converter, data: data);

  Future<WrResponse<Exam>> updateExam(int id, ExamWriteRequest data) =>
      _api.patch('exams/$id', converter: Exam.converter, data: data);

  Future<WrResponse<bool>> deleteExam(int id) =>
      _api.delete('exams/$id', converter: (_) => true);

  Future<WrResponse<ExamTarget>> createTarget(
    int examId,
    TargetWriteRequest data,
  ) => _api.post(
    'exams/$examId/targets',
    converter: ExamTarget.converter,
    data: data,
  );

  Future<WrResponse<ExamTarget>> updateTarget(
    int examId,
    int targetId,
    TargetWriteRequest data,
  ) => _api.patch(
    'exams/$examId/targets/$targetId',
    converter: ExamTarget.converter,
    data: data,
  );

  Future<WrResponse<bool>> deleteTarget(int examId, int targetId) =>
      _api.delete('exams/$examId/targets/$targetId', converter: (_) => true);

  Future<WrResponse<ExamQuestion>> createQuestion(
    int examId,
    QuestionWriteRequest data,
  ) => _api.post(
    'exams/$examId/questions',
    converter: ExamQuestion.converter,
    data: data,
  );

  Future<WrResponse<ExamQuestion>> updateQuestion(
    int examId,
    int questionId,
    QuestionWriteRequest data,
  ) => _api.put(
    'exams/$examId/questions/$questionId',
    converter: ExamQuestion.converter,
    data: data,
  );

  Future<WrResponse<bool>> deleteQuestion(int examId, int questionId) => _api
      .delete('exams/$examId/questions/$questionId', converter: (_) => true);

  Future<WrResponse<SessionListResponse>> getSessions(int examId) => _api.get(
    'exams/$examId/sessions',
    converter: SessionListResponse.converter,
  );

  Future<WrResponse<TeacherSessionDetail>> getSession(int sessionId) =>
      _api.get(
        'exams/sessions/$sessionId',
        converter: TeacherSessionDetail.converter,
      );

  Future<WrResponse<TeacherSessionDetail>> reviewAnswer(
    int sessionId,
    int answerId,
    ExamAnswerReviewRequest data,
  ) => _api.patch(
    'exams/sessions/$sessionId/answers/$answerId',
    converter: TeacherSessionDetail.converter,
    data: data,
  );

  /// [onConflict] позволяет подставить свою ошибку для 409
  /// (по умолчанию — «содержимое экзамена заблокировано»).
  void ensureSuccess(
    WrResponse<dynamic> response, {
    AppException Function()? onConflict,
  }) {
    if (response.isSuccess) return;
    switch (response.statusCode) {
      case 404:
        throw ExamNotFoundError();
      case 409:
        throw onConflict?.call() ?? ExamConflictError();
      default:
        throw ExamInvalidError();
    }
  }
}
