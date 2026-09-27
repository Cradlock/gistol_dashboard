import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';




class User {
  final int id;
  final String name;
  final String surname;
  final int scores;
  final int? year;
  final Group? group;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.scores,
    required this.year,
    required this.group,
  });

  factory User.converter(dynamic json) {
    
    final map = json as Map<String, dynamic>;

    return User(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      surname: map['surname'] as String? ?? '',
      scores: (map['scores'] as num?)?.toInt() ?? 0,
      year: (map['year'] as num?)?.toInt(),
      group: map['group'] != null 
          ? Group.converter(map['group'] as Map<String, dynamic>) 
          : null,
    );  }
}

class AdminProfile {
  final int id;
  final String? code;
  final String? name;
  final String? surname;
  final int role;

  const AdminProfile({
    required this.id,
    required this.code,
    required this.name,
    required this.surname,
    required this.role,
  });

  factory AdminProfile.converter(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    return AdminProfile(
      id: map['id'] as int,
      code: map['code'] as String?,
      name: map['name'] as String?,
      surname: map['surname'] as String?,
      role: (map['role'] as num?)?.toInt() ?? 0,
    );
  }
}
