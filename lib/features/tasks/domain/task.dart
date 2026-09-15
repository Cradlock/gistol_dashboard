import 'package:gistol_dashboard/core/core.dart';

enum AnswerStatus {
  pending('pending'),
  positive('positive'),
  negative('negative');

  final String value;
  const AnswerStatus(this.value);

  static AnswerStatus fromJson(String? raw) {
    return AnswerStatus.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => AnswerStatus.pending,
    );
  }
}

class SituationTask {
  final int id;
  final String title;
  final int groupId;
  final DateTime startAt;
  final DateTime endAt;
  final int points;

  SituationTask({
    required this.id,
    required this.title,
    required this.groupId,
    required this.startAt,
    required this.endAt,
    required this.points,
  });

  factory SituationTask.converter(dynamic json) {
    final data = json as Map<String, dynamic>;
    return SituationTask(
      id: data['id'] as int,
      title: data['title'] as String,
      groupId: data['group_id'] as int,
      startAt: DateTime.parse(data['start_at'] as String),
      endAt: DateTime.parse(data['end_at'] as String),
      points: data['points'] as int,
    );
  }
}

class TaskListResponse {
  final int total;
  final List<SituationTask> tasks;

  TaskListResponse({required this.total, required this.tasks});

  factory TaskListResponse.converter(dynamic data) {
    final json = data as Map<String, dynamic>;
    return TaskListResponse(
      total: json['total'] as int? ?? 0,
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map(SituationTask.converter)
          .toList(),
    );
  }
}

class StudentAnswer {
  final int id;
  final int userId;
  final int taskId;
  final String text;
  final AnswerStatus status;

  StudentAnswer({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.text,
    required this.status,
  });

  factory StudentAnswer.converter(dynamic json) {
    final data = json as Map<String, dynamic>;
    return StudentAnswer(
      id: data['id'] as int,
      userId: data['user_id'] as int,
      taskId: data['task_id'] as int,
      text: data['text'] as String,
      status: AnswerStatus.fromJson(data['status'] as String?),
    );
  }
}

class AnswerListResponse {
  final int total;
  final List<StudentAnswer> answers;

  AnswerListResponse({required this.total, required this.answers});

  factory AnswerListResponse.converter(dynamic data) {
    final json = data as Map<String, dynamic>;
    return AnswerListResponse(
      total: json['total'] as int? ?? 0,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map(StudentAnswer.converter)
          .toList(),
    );
  }
}

class TaskWriteRequest implements ToJsonable {
  final String title;
  final int groupId;
  final DateTime startAt;
  final DateTime endAt;
  final int points;

  TaskWriteRequest({
    required this.title,
    required this.groupId,
    required this.startAt,
    required this.endAt,
    required this.points,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'group_id': groupId,
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
      'points': points,
    };
  }
}

class AnswerReviewRequest implements ToJsonable {
  final AnswerStatus status;

  AnswerReviewRequest({required this.status});

  @override
  Map<String, dynamic> toJson() {
    return {'status': status.value};
  }
}

class TaskBulkDelete implements ToJsonable {
  final List<int> ids;

  TaskBulkDelete({required this.ids});

  @override
  Map<String, dynamic> toJson() {
    return {'ids': ids};
  }
}
