import 'package:dio/dio.dart';

import '../models/api_envelope.dart';
import '../models/categorie_model.dart';

class CategorieProvider {
  final Dio _dio;
  CategorieProvider(this._dio);

  Future<PageEnvelope<CategorieModel>> list({int page = 0, int size = 50}) async {
    final resp = await _dio.get('/categories', queryParameters: {'page': page, 'size': size});
    final env = ApiEnvelope<PageEnvelope<CategorieModel>>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => PageEnvelope<CategorieModel>.fromJson(
        d as Map<String, dynamic>,
        CategorieModel.fromJson,
      ),
    );
    return env.data!;
  }

  Future<CategorieModel> create(CategorieModel c) async {
    final resp = await _dio.post('/categories', data: c.toJson());
    final env = ApiEnvelope<CategorieModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => CategorieModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<CategorieModel> update(int id, CategorieModel c) async {
    final resp = await _dio.put('/categories/$id', data: c.toJson());
    final env = ApiEnvelope<CategorieModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => CategorieModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<void> delete(int id) async => _dio.delete('/categories/$id');
}
