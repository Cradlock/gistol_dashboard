import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/tasks/domain/errors.dart';
import 'package:gistol_dashboard/features/tasks/domain/task.dart';

class TasksService {
  final _api = ApiClient();

  Future<WrResponse<TaskListResponse>> getTasks({int? groupId}) {
    return _api.get(
      'task/',
      converter: TaskListResponse.converter,
      queryParameters: {
        if (groupId != null) 'group_id': groupId,
      },
    );
  }

  Future<WrResponse<SituationTask>> createTask(TaskWriteRequest data) {
    return _api.post(
      'task/',
      converter: SituationTask.converter,
      data: data,
    );
  }

  Future<WrResponse<SituationTask>> updateTask(int id, TaskWriteRequest data) {
    return _api.patch(
      'task/$id',
      converter: SituationTask.converter,
      data: data,
    );
  }

  Future<WrResponse<bool>> deleteTask(int id) {
    return _api.delete(
      'task/$id',
      converter: (_) => true,
    );
  }

  Future<WrResponse<AnswerListResponse>> getAnswers(int taskId) {
    return _api.get(
      'task/$taskId/answers',
      converter: AnswerListResponse.converter,
    );
  }

  Future<WrResponse<StudentAnswer>> reviewAnswer(
    int answerId,
    AnswerReviewRequest data,
  ) async {
    final res = await _api.patch(
      'task/answers/$answerId',
      converter: StudentAnswer.converter,
      data: data,
    );

    switch (res.statusCode) {
      case 404:
        throw TaskNotFoundError();
      case 400:
      case 422:
        throw TaskInvalidError();
    }

    return res;
  }
}
