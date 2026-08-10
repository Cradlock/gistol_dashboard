import 'package:gistol_dashboard/features/auth/domain/errors.dart';

class Group {
  final int id;
  final String title;
  final int year;
  final bool isActive;

  Group({
    required this.id,
    required this.title,
    required this.year,
    required this.isActive,
  });

  factory Group.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const ServerTroubleException();
    }

    return Group(
      id: json['id'] as int,
      title: json['title'] as String,
      year: json['year'] as int,
      isActive: json['is_active'] as bool,
    );
  }
}



class User {
  final int id;
  final String name;
  final String surname;
  final int scores;
  final int? year;
  final Group? group;
  final String code;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.scores,
    required this.year,
    required this.group,
    required this.code,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const ServerTroubleException();
    }

    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      surname: json['surname'] as String,
      scores: json['scores'] as int,
      year: json['year'] as int?,
      group: json['group'] != null ? 
          Group.fromJson(json['group'] as Map<String, dynamic>?) : null,
      code: json['code'] as String,
    );
  }
}
