import 'package:gistol_dashboard/core/api/domain.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';

enum SessionStatus {
  started('started'),
  submitted('submitted'),
  expired('expired');

  const SessionStatus(this.value);
  final String value;

  static SessionStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value);
}

/// Краткая информация о попытке студента (список на вкладке «Результаты»).
class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.studentName,
    this.submittedAt,
    this.reviewedAt,
    this.score,
  });

  final int id;
  final int userId;
  final String? studentName;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final int? score;

  /// Попытка сдана, но итоговый балл ещё не посчитан:
  /// остались текстовые ответы без решения преподавателя.
  bool get needsReview => status == SessionStatus.submitted && score == null;

  factory SessionSummary.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return SessionSummary(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      studentName: json['student_name'] as String?,
      status: SessionStatus.fromJson(json['status'] as String),
      startedAt: DateTime.parse(json['started_at'] as String),
      submittedAt: _parseDate(json['submitted_at']),
      reviewedAt: _parseDate(json['reviewed_at']),
      score: json['score'] as int?,
    );
  }
}

class SessionListResponse {
  const SessionListResponse({required this.total, required this.sessions});
  final int total;
  final List<SessionSummary> sessions;

  factory SessionListResponse.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return SessionListResponse(
      total: json['total'] as int? ?? 0,
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map(SessionSummary.converter)
          .toList(),
    );
  }
}

/// Ответ студента на один вопрос (вид для преподавателя).
class TeacherAnswer {
  const TeacherAnswer({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.questionPoints,
    required this.choices,
    this.choiceId,
    this.choiceText,
    this.text,
    this.awardedPoints,
    this.reviewedAt,
  });

  final int id;
  final int questionId;
  final String questionText;
  final QuestionType questionType;
  final int questionPoints;
  final int? choiceId;
  final String? choiceText;
  final String? text;
  final int? awardedPoints;
  final DateTime? reviewedAt;
  final List<ExamChoice> choices;

  bool get isInput => questionType == QuestionType.input;

  /// Студент вообще ответил на вопрос.
  bool get isAnswered => isInput ? text != null : choiceId != null;

  /// Текстовый ответ, который преподаватель может принять или отклонить.
  bool get isReviewable => isInput && text != null;

  bool get isReviewed => awardedPoints != null;
  bool get isAccepted => isReviewed && awardedPoints! > 0;
  bool get isRejected => isReviewed && awardedPoints! == 0;

  factory TeacherAnswer.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return TeacherAnswer(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      questionText: json['question_text'] as String,
      questionType: QuestionType.fromJson(json['question_type'] as String),
      questionPoints: json['question_points'] as int,
      choiceId: json['choice_id'] as int?,
      choiceText: json['choice_text'] as String?,
      text: json['text'] as String?,
      awardedPoints: json['awarded_points'] as int?,
      reviewedAt: _parseDate(json['reviewed_at']),
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map(ExamChoice.converter)
          .toList(),
    );
  }
}

class TeacherSessionDetail {
  const TeacherSessionDetail({
    required this.id,
    required this.userId,
    required this.examId,
    required this.examTitle,
    required this.examTheme,
    required this.status,
    required this.startedAt,
    required this.answers,
    this.studentName,
    this.submittedAt,
    this.reviewedAt,
    this.score,
  });

  final int id;
  final int userId;
  final String? studentName;
  final int examId;
  final String examTitle;
  final String examTheme;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final int? score;
  final List<TeacherAnswer> answers;

  bool get needsReview => status == SessionStatus.submitted && score == null;

  /// Проверять ответы можно только в сданной попытке (иначе сервер вернёт 409).
  bool get canReview => status == SessionStatus.submitted;

  List<TeacherAnswer> get reviewableAnswers =>
      answers.where((answer) => answer.isReviewable).toList();

  int get reviewedCount =>
      reviewableAnswers.where((answer) => answer.isReviewed).length;

  factory TeacherSessionDetail.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return TeacherSessionDetail(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      studentName: json['student_name'] as String?,
      examId: json['exam_id'] as int,
      examTitle: json['exam_title'] as String,
      examTheme: json['exam_theme'] as String,
      status: SessionStatus.fromJson(json['status'] as String),
      startedAt: DateTime.parse(json['started_at'] as String),
      submittedAt: _parseDate(json['submitted_at']),
      reviewedAt: _parseDate(json['reviewed_at']),
      score: json['score'] as int?,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map(TeacherAnswer.converter)
          .toList(),
    );
  }
}

/// Решение преподавателя по текстовому ответу: принять (полный балл) или нет (0).
class ExamAnswerReviewRequest implements ToJsonable {
  const ExamAnswerReviewRequest({required this.accepted});
  final bool accepted;

  @override
  Map<String, dynamic> toJson() => {'accepted': accepted};
}

DateTime? _parseDate(dynamic value) =>
    value == null ? null : DateTime.parse(value as String);
