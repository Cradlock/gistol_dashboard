import 'package:gistol_dashboard/core/api/client.dart';
import 'package:gistol_dashboard/core/api/domain.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:gistol_dashboard/features/students/domain/errors.dart';
import 'package:gistol_dashboard/features/students/domain/filter.dart';
import 'package:gistol_dashboard/features/students/domain/student.dart';

class StudentService {
  final _api = ApiClient();

  // Получение студентов
  Future<WrResponse<StudentsResponse>> getUsers(
    int currentPage,
    int pageSize,
    FilterStudentParams params,
  ) async {
    return await _api.get(
      "student/search",
      converter: StudentsResponse.converter,
      queryParameters: {
        "page": currentPage,
        "page_size": pageSize,
        ...params.toQueryParams(),
      },
    );
  }

  Future<WrResponse<StudentBulkOperResponse>> confirmStudents(
    StudentBulkOperRequest data,
  ) async {
    return await _api.post(
      "student/confirm",
      converter: StudentBulkOperResponse.converter,
      data: data,
    );
  }

  Future<WrResponse<StudentBulkOperResponse>> unconfirmStudents(
    StudentBulkOperRequest data,
  ) async {
    return await _api.post(
      "student/unconfirm",
      converter: StudentBulkOperResponse.converter,
      data: data,
    );
  }

  Future<WrResponse<StudentBulkOperResponse>> deleteStudents(
    StudentBulkOperRequest data,
  ) async {
    return await _api.delete(
      "student/delete",
      converter: StudentBulkOperResponse.converter,
      data: data,
    );
  }

  Future<WrResponse<StudentBulkOperResponse>> recoveryStudents(
    StudentBulkOperRequest data,
  ) async {
    return await _api.post(
      "student/recovery",
      converter: StudentBulkOperResponse.converter,
      data: data,
    );
  }

  Future<WrResponse<Student>> editStudent(int id, StudentUpdate data) async {
    final res = await _api.patch(
      "student/$id",
      converter: Student.converter,
      data: data,
    );

    if (res.isSuccess && res.data != null) return res;

    switch (res.statusCode) {
      case 403:
        throw SessionExpired();
      case 404:
        throw NotFoundStudent();
      default:
        throw InvalidStudentUpdate();
    }
  }
}
