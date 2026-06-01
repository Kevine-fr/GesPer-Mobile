import 'package:dio/dio.dart';

import '../models/api_envelope.dart';
import '../models/spent_model.dart';

class SpentProvider {
  final Dio _dio;
  SpentProvider(this._dio);

  Future<PageEnvelope<SpentModel>> mine({int page = 0, int size = 50}) async {
    final resp = await _dio.get('/spents/me', queryParameters: {'page': page, 'size': size});
    final env = ApiEnvelope<PageEnvelope<SpentModel>>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => PageEnvelope<SpentModel>.fromJson(d as Map<String, dynamic>, SpentModel.fromJson),
    );
    return env.data!;
  }

  Future<SpentModel> create({
    int? gainId,
    required int categorieId,
    required String libelle,
    required num value,
    required bool isSpent,
  }) async {
    final resp = await _dio.post('/spents', data: {
      'gainId': gainId,
      'categorieId': categorieId,
      'libelle': libelle,
      'value': value,
      'isSpent': isSpent,
    });
    final env = ApiEnvelope<SpentModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => SpentModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<SpentModel> updateMine({
    required int id,
    int? gainId,
    required int categorieId,
    required String libelle,
    required num value,
    required bool isSpent,
  }) async {
    final resp = await _dio.put('/spents/me/$id', data: {
      'gainId': gainId,
      'categorieId': categorieId,
      'libelle': libelle,
      'value': value,
      'isSpent': isSpent,
    });
    final env = ApiEnvelope<SpentModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => SpentModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<void> softDelete(int id) async => _dio.patch('/spents/me/$id/soft-delete');
}
