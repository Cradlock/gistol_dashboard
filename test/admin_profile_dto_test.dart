import 'package:flutter_test/flutter_test.dart';
import 'package:gistol_dashboard/features/auth/domain/user.dart';

void main() {
  test('admin profile parses login without a student group', () {
    final profile = AdminProfile.converter({
      'id': 4,
      'code': 'admin',
      'name': 'Ada',
      'surname': 'Admin',
      'role': 20,
    });

    expect(profile.code, 'admin');
    expect(profile.role, 20);
  });

  test('user converter accepts null admin name fields', () {
    final user = User.converter({
      'id': 4,
      'name': null,
      'surname': null,
      'scores': 0,
      'year': null,
      'group': null,
    });

    expect(user.name, '');
    expect(user.surname, '');
  });
}
