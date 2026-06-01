import 'package:dio/dio.dart';

import '../models/api_envelope.dart';
import '../models/gain_model.dart';

class GainProvider {
  final Dio _dio;
  GainProvider(this._dio);

  Future<PageEnvelope<GainModel>> mine({int page = 0, int size = 50}) async {
    final resp = await _dio.get('/gains/me', queryParameters: {'page': page, 'size': size});
    final env = ApiEnvelope<PageEnvelope<GainModel>>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => PageEnvelope<GainModel>.fromJson(d as Map<String, dynamic>, GainModel.fromJson),
    );
    return env.data!;
  }

  Future<GainModel> create({
    required int categorieId,
    required String libelle,
    required num sum,
    required bool isReccurent,
  }) async {
    final resp = await _dio.post('/gains', data: {
      'categorieId': categorieId,
      'libelle': libelle,
      'sum': sum,
      'isReccurent': isReccurent,
    });
    final env = ApiEnvelope<GainModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => GainModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<GainModel> updateMine({
    required int id,
    required int categorieId,
    required String libelle,
    required num sum,
    required bool isReccurent,
  }) async {
    final resp = await _dio.put('/gains/me/$id', data: {
      'categorieId': categorieId,
      'libelle': libelle,
      'sum': sum,
      'isReccurent': isReccurent,
    });
    final env = ApiEnvelope<GainModel>.fromJson(
      resp.data as Map<String, dynamic>,
      (d) => GainModel.fromJson(d as Map<String, dynamic>),
    );
    return env.data!;
  }

  Future<void> softDelete(int id) async => _dio.patch('/gains/me/$id/soft-delete');
}
