class SpentModel {
  final int id;
  final int userId;
  final int? gainId;
  final int categorieId;
  final String? libelle;
  final num value;
  final bool isSpent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SpentModel({
    required this.id,
    required this.userId,
    this.gainId,
    required this.categorieId,
    this.libelle,
    required this.value,
    this.isSpent = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SpentModel.fromJson(Map<String, dynamic> json) => SpentModel(
        id: json['id'] as int,
        userId: (json['userId'] as num).toInt(),
        gainId: (json['gainId'] as num?)?.toInt(),
        categorieId: (json['categorieId'] as num).toInt(),
        libelle: json['libelle'] as String?,
        value: (json['value'] as num?) ?? 0,
        isSpent: json['isSpent'] as bool? ?? json['spent'] as bool? ?? true,
        createdAt: _parseDate(json['createdAt']),
        updatedAt: _parseDate(json['updatedAt']),
      );

  static DateTime? _parseDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
