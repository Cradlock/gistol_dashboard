


// lib/core/api/auth_interceptor.dart

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth.dart';

class AuthInterceptor extends Interceptor {
  // Нам нужен отдельный чистый экземпляр Dio для запроса /refresh.
  // Если использовать тот же самый Dio, где висит этот интерцептор,
  // мы уйдем в бесконечную рекурсию (зациклимся).
  final Dio _refreshDio = Dio(BaseOptions(baseUrl: dotenv.get("BASE_URL")));
  
  Completer<void>? _refreshCompleter;
  bool _isRefreshing = false;
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    
    // Если токен есть в базе, автоматически лепим его ко всем запросам
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options); // Пускаем запрос дальше
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Если ошибка НЕ связана с авторизацией (не 401), просто прокидываем её дальше
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }// Если кто-то уже обновляет токен, ждем завершения его Completer'а
  if (_isRefreshing) {
    // Если комплитер еще жив — ждем его завершения
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return _retryRequest(err, handler);
    }
    return handler.next(err);
  }
    
    _isRefreshing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      // Если рефреш-токена нет, то и обновлять нечего — отправляем разлогинивать юзера
      if (refreshToken == null || refreshToken.isEmpty) {
        _handleLogout();
        return handler.next(err);
      }

      // 1. Пытаемся обновить токены на бэкенде
      final response = await _refreshDio.post<Map<String,dynamic>>(
        '/api/auth/refresh',
        options: Options( 
          headers: {
            'Authorization': 'Bearer $refreshToken'
          }
        ), 
        data: RefreshRequest(refresh_token: refreshToken).toJson()
      );     
      if (response.statusCode == 200 || response.statusCode == 201) {
        final tokens = RefreshResponse.converter(response.data);

        await prefs.setString('access_token', tokens.access_token);
        await prefs.setString('refresh_token', tokens.refresh_token);

        // Повторяем текущий упавший запрос
        return await _retryRequest(err, handler, newToken: tokens.access_token);
      }
    } catch (e) {
      // Если даже ручка /refresh упала (например, рефреш токен тоже устарел или отозван)
      // Значит сессия полностью мертва — принудительно разлогиниваем пользователя
      await _handleLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }

  }
  
  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler, {
    String? newToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = newToken ?? prefs.getString('access_token');

    final requestOptions = err.requestOptions;
    requestOptions.headers['Authorization'] = 'Bearer $token';

    final cloneDio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
    try {
      final response = await cloneDio.request(
        requestOptions.path,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
        ),
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    
    ErrorHandler.handle(SessionExpired());
  }
}
