
import 'package:gistol_dashboard/core/api/domain.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/domain/auth.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:gistol_dashboard/features/auth/domain/user.dart';
import 'package:gistol_dashboard/features/auth/services/main.dart';


import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class AuthProvider extends ChangeNotifier{
  User? user;

  bool _isLoading = false;

  
  AppException? currentError;
    
  bool get isLoading => _isLoading;


  final AuthService _service = AuthService(); 

  Future<void> saveTokens(String access,String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  } 
  


  Future<bool> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

  
    try {
      final response = await _service.me();
      
      if (response.statusCode != 200 || response.data == null) {
        if (response.statusCode == 0) {
          currentError = NoConnectionException();
        } 
        
        
        _isLoading = false;
        notifyListeners();
        return false; // Ошибка — пользователя на логин!
      }      

      user = response.data;
      _isLoading = false;
      notifyListeners();
      return true;
    

    } catch (e) {
      debugPrint(e.toString()); 
      _isLoading = false;
      notifyListeners();
      return false;
    }

  } 
  
  Future<void> login(String username,String password) async {
    _isLoading = true;
    currentError = null;
    notifyListeners();

    final response = await _service.login(username,password); 
      
    if(response.isSuccess){
      final data = response.data;

      await saveTokens(data!.accessToken, data!.refreshToken);
      
      this.currentError = null;
    } else {
      
      final int statusCode = response.statusCode;

      switch (statusCode) {
        case 0:
          this.currentError = NoConnectionException();
        case 401:
            this.currentError = InvalidSignDataException();
        default:
      } 

    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    
    notifyListeners();
  }
  
  void _clearData() {
  
  }

  AuthProvider(){}
}

