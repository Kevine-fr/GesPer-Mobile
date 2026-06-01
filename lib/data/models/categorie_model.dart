class CategorieModel {
  final int id;
  final String title;
  final String subtitle;
  final bool isOrganized;
  /// true = catégorie de dépense, false = catégorie de gain
  final bool isSpent;

  CategorieModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isOrganized = false,
    this.isSpent = true,
  });

  bool get isGainCategory => !isSpent;
  bool get isSpentCategory => isSpent;

  factory CategorieModel.fromJson(Map<String, dynamic> json) => CategorieModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        isOrganized: json['isOrganized'] as bool? ?? json['organized'] as bool? ?? false,
        isSpent: json['isSpent'] as bool? ?? json['spentCategory'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'isOrganized': isOrganized,
        'isSpent': isSpent,
      };
}
