import 'package:dio/dio.dart';

import '../models/api_envelope.dart';
import '../models/user_model.dart';

class UserProvider {
  final Dio _dio;
  UserProvider(this._dio);

  Future<UserModel> me() async {
    final resp = await _dio.get('/users/me');
    final env = ApiEnvelope<UserModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => UserModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<UserModel> updateMe({String? name, String? email, String? password}) async {
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (password != null && password.isNotEmpty) body['password'] = password;
    final resp = await _dio.put('/users/me', data: body);
    final env = ApiEnvelope<UserModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => UserModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  // --- Admin ---

  Future<PageEnvelope<UserModel>> adminListUsers({int page = 0, int size = 20}) async {
    final resp = await _dio.get('/users/admin', queryParameters: {'page': page, 'size': size});
    final env = ApiEnvelope<PageEnvelope<UserModel>>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => PageEnvelope<UserModel>.fromJson(d as Map<String, dynamic>, UserModel.fromJson),
    );
    return env.data!;
  }

  Future<void> adminDisable(int userId) async => _dio.put('/users/admin/$userId/disable');
  Future<void> adminEnable(int userId) async => _dio.put('/users/admin/$userId/enable');
  Future<void> adminDelete(int userId) async => _dio.delete('/users/admin/$userId');
}
