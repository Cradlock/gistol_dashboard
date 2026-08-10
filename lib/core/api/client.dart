

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gistol_dashboard/core/api/domain.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'domain.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() => _instance;
  
  final Dio _dio;

  ApiClient._internal() : _dio = Dio() {
    final baseUrl = dotenv.env['BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError(
        '[ApiClient Error]: not found BASE_URL in .env file '
      );
    }

    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 5)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  }
  
   void addInterceptor(Interceptor interceptor) {
     _dio.interceptors.add(interceptor);
  }

  
  Future<WrResponse<T>> _guardRequest<T>(
    Future<Response<dynamic>> Function() request,
    FromJson<T> fromJson
  ) async {
    try {
      final response = await request();
      return WrResponse.success(
        data: fromJson(response.data),
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      int statusCode = e.response?.statusCode ?? 500;
      String msg = e.message ?? 'Unknown error';
      if(e.type == DioException.connectionError || e.type == DioException.connectionTimeout || e.error is SocketException){
        statusCode = 0;
        msg = "Connection error";
      }

      return WrResponse.error(
        statusCode: statusCode,
        message: msg,
      );
    } catch (e) {
      return WrResponse.error(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
  
  dynamic _formatData(dynamic data) {
    return data is ToJsonable ? data.toJson() : data;
  }


    Future<WrResponse<T>> get<T>(String path,{required FromJson<T> fromJson ,Map<String, dynamic>? queryParameters, Options? options}) async  {
      return _guardRequest(
        () => _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters, options: options),
        fromJson,
      );   
    }

  Future<WrResponse<T>> post<T>(
    String path, {
    required FromJson<T> fromJson,
    required ToJsonable data,
    Options? options,
  }) {
    return _guardRequest(
      () => _dio.post<Map<String, dynamic>>(path, data: _formatData(data), options: options),
      fromJson,
    );
  }

  Future<WrResponse<T>> put<T>(
    String path, {
    required FromJson<T> fromJson,
    required ToJsonable data,
    Options? options,
  }) {
    return _guardRequest(
      () => _dio.put<Map<String, dynamic>>(path, data: _formatData(data), options: options),
      fromJson,
    );
  }

  Future<WrResponse<T>> patch<T>(
    String path, {
    required FromJson<T> fromJson,
    dynamic data,
    Options? options,
  }) {
    return _guardRequest(
      () => _dio.patch<Map<String, dynamic>>(path, data: _formatData(data), options: options),
      fromJson,
    );
  }

  Future<WrResponse<T>> delete<T>(
    String path, {
    required FromJson<T> fromJson,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) {
    return _guardRequest(
      () => _dio.delete<Map<String, dynamic>>(path, queryParameters: queryParameters, data: _formatData(data), options: options),
      fromJson,
    );
  }
}





