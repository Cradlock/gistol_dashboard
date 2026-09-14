



import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:gistol_dashboard/features/groups/domain/group.dart';

class Student {
  final int id;
  final String? name;
  final String? surname;
  final int scores;
  final int? year;
  final Group? group;
  final int role;
  final bool confirmed;
  final bool deleted;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.scores,
    required this.year,
    required this.group,
    required this.role,
    required this.confirmed,
    required this.deleted,
  });

  factory Student.converter(dynamic json) {

    final map = json;

    return Student(
      id: map['id'] as int,
      name: map['name'] as String?,
      surname: map['surname'] as String?,
      scores: (map['scores'] as num?)?.toInt() ?? 0,
      year: map['year'] as int?,
      group: map['group'] != null 
          ? Group.converter(map['group'] as Map<String, dynamic>) 
          : null,
      role: map['role'] as int? ?? 3,
      confirmed: map['confirmed'] as bool? ?? false,
      deleted: map['deleted'] as bool? ?? false,
    );
}

Student copyWith({
    int? id,
    String? Function()? name,
    String? Function()? surname,
    int? scores,
    int? Function()? year,
    Group? Function()? group,
    int? role,
    bool? confirmed,
    bool? deleted,
  }) {
    return Student(
      id: id ?? this.id,
      name: name != null ? name() : this.name,
      surname: surname != null ? surname() : this.surname,
      scores: scores ?? this.scores,
      year: year != null ? year() : this.year,
      group: group != null ? group() : this.group,
      role: role ?? this.role,
      confirmed: confirmed ?? this.confirmed,
      deleted: deleted ?? this.deleted,
    );
  }
}

class StudentsResponse {
  final int total;
  final List<Student> students; 
  
  StudentsResponse({
    required this.total,
    required this.students 
  });
  
  factory StudentsResponse.converter(dynamic json){
    final map = json as Map<String,dynamic>;

    return StudentsResponse(
      total: map["total"] as int, 
      students: (map["students"] as List<dynamic>? ?? [])
        .map((item) => Student.converter(item))
        .toList()

    );
  }
} 


class StudentBulkOperRequest extends ToJsonable {
  final List<int> ids;

  StudentBulkOperRequest({required this.ids});

  @override
    Map<String, dynamic> toJson() {
      return {
        "ids":ids
      };
    }
}


class StudentBulkOperResponse {
  final List<int> completed;
  final List<int> faileds;
  
  StudentBulkOperResponse({
    required this.completed,
    required this.faileds
  });

  factory StudentBulkOperResponse.converter(dynamic data){
    final map = data as Map<String,dynamic>;

    return StudentBulkOperResponse(
      completed: map["completed"] ?? [], 
      faileds: map["faileds"] ?? []
    );
  }
}




class StudentUpdate extends ToJsonable {
  final String surname;
  final String name;
  final int groupId;
  final int year;
  final int scores;

  StudentUpdate({
    required this.surname,
    required this.name,
    required this.groupId,
    required this.year,
    required this.scores,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "surname": surname,
      "name": name,
      "group_id": groupId,         // Matches Python's snake_case group_id
      "year": year, // Serializes the enum to its raw primitive type
      "scores": scores,
    };
  }
}
