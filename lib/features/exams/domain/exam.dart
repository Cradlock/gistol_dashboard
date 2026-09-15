import 'package:gistol_dashboard/core/api/domain.dart';

enum QuestionType {
  choice('choise'),
  input('input');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromJson(String value) =>
      values.firstWhere((item) => item.value == value);
}

class ExamSummary {
  const ExamSummary({
    required this.id,
    required this.title,
    required this.theme,
    required this.startAt,
    required this.durationMinutes,
    required this.deadline,
  });

  final int id;
  final String title;
  final String theme;
  final DateTime startAt;
  final int durationMinutes;
  final DateTime deadline;

  factory ExamSummary.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return ExamSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      theme: json['theme'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      deadline: DateTime.parse(json['deadline'] as String),
    );
  }
}

class ExamListResponse {
  const ExamListResponse({required this.total, required this.exams});
  final int total;
  final List<ExamSummary> exams;

  factory ExamListResponse.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return ExamListResponse(
      total: json['total'] as int? ?? 0,
      exams: (json['exams'] as List<dynamic>? ?? [])
          .map(ExamSummary.converter)
          .toList(),
    );
  }
}

class ExamTarget {
  const ExamTarget({required this.id, required this.year, this.groupId});
  final int id;
  final int year;
  final int? groupId;

  factory ExamTarget.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return ExamTarget(
      id: json['id'] as int,
      year: json['year'] as int,
      groupId: json['group_id'] as int?,
    );
  }
}

class ExamChoice {
  const ExamChoice({this.id, required this.text, required this.isCorrect});
  final int? id;
  final String text;
  final bool isCorrect;

  factory ExamChoice.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return ExamChoice(
      id: json['id'] as int?,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}

class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.points,
    required this.position,
    required this.choices,
    this.expectedAnswer,
  });
  final int id;
  final String text;
  final QuestionType type;
  final int points;
  final int position;
  final List<ExamChoice> choices;
  final String? expectedAnswer;

  factory ExamQuestion.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return ExamQuestion(
      id: json['id'] as int,
      text: json['text'] as String,
      type: QuestionType.fromJson(json['type'] as String),
      points: json['points'] as int,
      position: json['position'] as int,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map(ExamChoice.converter)
          .toList(),
      expectedAnswer: json['expected_answer'] as String?,
    );
  }
}

class Exam {
  const Exam({
    required this.id,
    required this.title,
    required this.theme,
    required this.startAt,
    required this.durationMinutes,
    required this.targets,
    required this.questions,
  });
  final int id;
  final String title;
  final String theme;
  final DateTime startAt;
  final int durationMinutes;
  final List<ExamTarget> targets;
  final List<ExamQuestion> questions;

  factory Exam.converter(dynamic value) {
    final json = value as Map<String, dynamic>;
    return Exam(
      id: json['id'] as int,
      title: json['title'] as String,
      theme: json['theme'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      targets: (json['targets'] as List<dynamic>? ?? [])
          .map(ExamTarget.converter)
          .toList(),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map(ExamQuestion.converter)
          .toList(),
    );
  }
}

class ExamWriteRequest implements ToJsonable {
  const ExamWriteRequest({
    required this.title,
    required this.theme,
    required this.startAt,
    required this.durationMinutes,
  });
  final String title;
  final String theme;
  final DateTime startAt;
  final int durationMinutes;

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'theme': theme,
    'start_at': startAt.toUtc().toIso8601String(),
    'duration_minutes': durationMinutes,
  };
}

class TargetWriteRequest implements ToJsonable {
  const TargetWriteRequest({required this.year, this.groupId});
  final int year;
  final int? groupId;

  @override
  Map<String, dynamic> toJson() => {'group_id': groupId, 'year': year};
}

class ChoiceWriteRequest {
  const ChoiceWriteRequest({required this.text, required this.isCorrect});
  final String text;
  final bool isCorrect;
  Map<String, dynamic> toJson() => {'text': text, 'is_correct': isCorrect};
}

class QuestionWriteRequest implements ToJsonable {
  const QuestionWriteRequest({
    required this.text,
    required this.type,
    required this.points,
    required this.position,
    this.choices = const [],
    this.expectedAnswer,
  });
  final String text;
  final QuestionType type;
  final int points;
  final int position;
  final List<ChoiceWriteRequest> choices;
  final String? expectedAnswer;

  @override
  Map<String, dynamic> toJson() => {
    'text': text,
    'type': type.value,
    'points': points,
    'position': position,
    'choices': choices.map((item) => item.toJson()).toList(),
    'expected_answer': expectedAnswer,
  };
}
