import 'package:dio/dio.dart';

import '../models/api_envelope.dart';
import '../models/user_model.dart';

class AuthProvider {
  final Dio _dio;
  AuthProvider(this._dio);

  Future<void> sendClientCode({required String email, required String password}) async {
    await _dio.post('/auth/send-code/client', data: {'email': email, 'password': password});
  }

  Future<void> sendAdminCode({required String email, required String password}) async {
    await _dio.post('/auth/send-code/admin', data: {'email': email, 'password': password});
  }

  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    required String code,
  }) async {
    await _dio.post(
      '/auth/register/client',
      queryParameters: {'code': code},
      data: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<void> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String code,
  }) async {
    await _dio.post(
      '/auth/register/admin',
      queryParameters: {'code': code},
      data: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<AuthResponse> login({required String email, required String password}) async {
    final resp = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final env = ApiEnvelope<AuthResponse>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => AuthResponse.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final resp = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    final env = ApiEnvelope<AuthResponse>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => AuthResponse.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }
}
