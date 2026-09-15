import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor()
    : _refreshDio = Dio(
        BaseOptions(
          baseUrl: dotenv.get('BASE_URL'),
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  final Dio _refreshDio;
  Future<String>? _ongoingRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (_isRefreshCall(err.requestOptions) ||
        err.requestOptions.extra['auth_retried'] == true) {
      await _handleLogout();
      return handler.next(err);
    }

    try {
      final accessToken = await _queuedRefresh();
      return _retryRequest(err, handler, accessToken);
    } on _RefreshAuthFailure {
      await _handleLogout();
      return handler.next(err);
    } catch (_) {
      return handler.next(err);
    }
  }

  bool _isRefreshCall(RequestOptions options) =>
      options.path.contains('auth/refresh');

  Future<String> _queuedRefresh() {
    final existing = _ongoingRefresh;
    if (existing != null) return existing;

    final future = _refreshAccessToken();
    _ongoingRefresh = future;
    future.whenComplete(() {
      if (identical(_ongoingRefresh, future)) {
        _ongoingRefresh = null;
      }
    });
    return future;
  }

  Future<String> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null || refreshToken.isEmpty) {
      throw _RefreshAuthFailure();
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
        data: RefreshRequest(refresh_token: refreshToken).toJson(),
      );

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        if (status == 401 || status == 403) {
          throw _RefreshAuthFailure();
        }
        throw StateError('Refresh failed with $status');
      }

      final tokens = RefreshResponse.converter(response.data);
      await prefs.setString('access_token', tokens.access_token);
      if (tokens.refresh_token.isNotEmpty) {
        await prefs.setString('refresh_token', tokens.refresh_token);
      }
      return tokens.access_token;
    } on _RefreshAuthFailure {
      rethrow;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        throw _RefreshAuthFailure();
      }
      rethrow;
    }
  }

  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
    String accessToken,
  ) async {
    final requestOptions = err.requestOptions;
    requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    requestOptions.extra['auth_retried'] = true;

    final cloneDio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    try {
      final response = await cloneDio.request(
        requestOptions.path,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          extra: requestOptions.extra,
          contentType: requestOptions.contentType,
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

class _RefreshAuthFailure implements Exception {}
