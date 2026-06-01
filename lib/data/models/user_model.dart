class UserModel {
  final int id;
  final String name;
  final String email;
  final String? role;            // ROLE_ADMIN / ROLE_CLIENT
  final String? profilePictureUrl;
  final String? authProvider;    // LOCAL / GOOGLE
  final bool enabled;
  final bool? clientActif;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.profilePictureUrl,
    this.authProvider,
    this.enabled = true,
    this.clientActif,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'ROLE_ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String?,
        profilePictureUrl: json['profilePictureUrl'] as String?,
        authProvider: json['authProvider'] as String?,
        enabled: json['enabled'] as bool? ?? true,
        clientActif: json['clientActif'] as bool?,
        emailVerifiedAt: _parseDate(json['emailVerifiedAt']),
        createdAt: _parseDate(json['createdAt']),
        updatedAt: _parseDate(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'profilePictureUrl': profilePictureUrl,
        'authProvider': authProvider,
        'enabled': enabled,
        'clientActif': clientActif,
        'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserModel? user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 0,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        tokenType: json['tokenType'] as String? ?? 'Bearer',
        expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
        user: json['user'] != null
            ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}
