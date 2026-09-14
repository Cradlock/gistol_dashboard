



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

}


