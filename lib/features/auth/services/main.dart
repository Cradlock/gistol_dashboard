



import 'package:gistol_dashboard/core/api/domain.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:gistol_dashboard/features/auth/domain/user.dart';

class AuthService {
  
  final ApiClient _api = ApiClient();
  
  Future<WrResponse<AuthSignResponse>> login(String username,String password) async {
    AuthSignRequest data = AuthSignRequest(username: username, password: password);
    
    return await _api.post<AuthSignResponse>("auth/admin", converter: AuthSignResponse.converter,data: data);     

  }
  
  Future<WrResponse<User>> me() async {
    return await _api.get<User>("student/me", converter: User.converter);
  }

  Future<WrResponse<AdminProfile>> adminMe() async {
    return await _api.get<AdminProfile>(
      "auth/admin/me",
      converter: AdminProfile.converter,
    );
  }

  Future<WrResponse<AdminProfile>> updateAdminCode(
    AdminCodeUpdateRequest data,
  ) async {
    final response = await _api.patch<AdminProfile>(
      "auth/admin/code",
      converter: AdminProfile.converter,
      data: data,
    );
    if (response.statusCode == 401) {
      throw InvalidCurrentPasswordException();
    }
    if (response.statusCode == 409) {
      throw DuplicateAdminLoginException();
    }
    if (!response.isSuccess || response.data == null) {
      throw InvalidCurrentPasswordException();
    }
    return response;
  }

  Future<WrResponse<AdminProfile>> updateAdminPassword(
    AdminPasswordUpdateRequest data,
  ) async {
    final response = await _api.patch<AdminProfile>(
      "auth/admin/password",
      converter: AdminProfile.converter,
      data: data,
    );
    if (response.statusCode == 401) {
      throw InvalidCurrentPasswordException();
    }
    if (response.statusCode == 422) {
      throw WeakPasswordException();
    }
    if (!response.isSuccess || response.data == null) {
      throw InvalidCurrentPasswordException();
    }
    return response;
  }

}


