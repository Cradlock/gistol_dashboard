import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/domain/group.dart';

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
  final String content;
  final List<int> groupIds;
  final List<Group> groups;
  final DateTime startAt;
  final DateTime endAt;
  final int points;

  SituationTask({
    required this.id,
    required this.title,
    required this.content,
    required this.groupIds,
    required this.groups,
    required this.startAt,
    required this.endAt,
    required this.points,
  });

  factory SituationTask.converter(dynamic json) {
    final data = json as Map<String, dynamic>;
    final groups = (data['groups'] as List<dynamic>? ?? [])
        .map(Group.converter)
        .toList();
    final rawIds = data['group_ids'] as List<dynamic>?;
    final groupIds = rawIds != null
        ? rawIds.map((item) => (item as num).toInt()).toList()
        : [
            if (data['group_id'] is num) (data['group_id'] as num).toInt(),
            ...groups.map((group) => group.id),
          ];
    return SituationTask(
      id: data['id'] as int,
      title: data['title'] as String,
      content: data['content'] as String,
      groupIds: groupIds.toSet().toList(),
      groups: groups,
      startAt: DateTime.parse(data['start_at'] as String),
      endAt: DateTime.parse(data['end_at'] as String),
      points: data['points'] as int,
    );
  }

  String groupTitles({List<Group> catalog = const []}) {
    if (groups.isNotEmpty) {
      return groups.map((group) => group.title).join(', ');
    }
    if (groupIds.isEmpty) return '';
    return groupIds
        .map((id) {
          for (final group in catalog) {
            if (group.id == id) return group.title;
          }
          return '#$id';
        })
        .join(', ');
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
  final String studentName;
  final String? groupTitle;

  StudentAnswer({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.text,
    required this.status,
    required this.studentName,
    this.groupTitle,
  });

  factory StudentAnswer.converter(dynamic json) {
    final data = json as Map<String, dynamic>;
    final userId = data['user_id'] as int;
    final rawName = (data['student_name'] as String?)?.trim();
    final rawGroup = (data['group_title'] as String?)?.trim();
    return StudentAnswer(
      id: data['id'] as int,
      userId: userId,
      taskId: data['task_id'] as int,
      text: data['text'] as String,
      status: AnswerStatus.fromJson(data['status'] as String?),
      studentName: (rawName != null && rawName.isNotEmpty)
          ? rawName
          : '#$userId',
      groupTitle: (rawGroup != null && rawGroup.isNotEmpty) ? rawGroup : null,
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
  final String content;
  final List<int> groupIds;
  final DateTime startAt;
  final DateTime endAt;
  final int points;

  TaskWriteRequest({
    required this.title,
    required this.content,
    required this.groupIds,
    required this.startAt,
    required this.endAt,
    required this.points,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'group_ids': groupIds,
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
