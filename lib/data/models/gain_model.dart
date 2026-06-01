class GainModel {
  final int id;
  final int userId;
  final int categorieId;
  final String? libelle;
  /// Montant — stocké comme num pour rester précis côté UI.
  final num sum;
  final bool isReccurent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GainModel({
    required this.id,
    required this.userId,
    required this.categorieId,
    this.libelle,
    required this.sum,
    this.isReccurent = false,
    this.createdAt,
    this.updatedAt,
  });

  factory GainModel.fromJson(Map<String, dynamic> json) => GainModel(
        id: json['id'] as int,
        userId: (json['userId'] as num).toInt(),
        categorieId: (json['categorieId'] as num).toInt(),
        libelle: json['libelle'] as String?,
        sum: (json['sum'] as num?) ?? 0,
        isReccurent: json['isReccurent'] as bool? ?? json['recurrent'] as bool? ?? false,
        createdAt: _parseDate(json['createdAt']),
        updatedAt: _parseDate(json['updatedAt']),
      );

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
