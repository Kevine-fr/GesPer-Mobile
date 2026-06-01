/// Exception applicative côté Flutter. Toujours porteuse d'un message lisible
/// par l'utilisateur (sous-classes pour les status code spéciaux).
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String>? fieldErrors;

  AppException(this.message, {this.statusCode, this.fieldErrors});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Connexion impossible. Vérifiez votre réseau.'])
      : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Session expirée. Veuillez vous reconnecter.'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends AppException {
  ForbiddenException([String message = 'Accès refusé.']) : super(message, statusCode: 403);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Ressource introuvable.']) : super(message, statusCode: 404);
}

class ConflictException extends AppException {
  ConflictException(String message) : super(message, statusCode: 409);
}

class ValidationException extends AppException {
  ValidationException(String message, Map<String, String>? errors)
      : super(message, statusCode: 400, fieldErrors: errors);
}

class ServerException extends AppException {
  ServerException([String message = 'Erreur serveur. Veuillez réessayer.'])
      : super(message, statusCode: 500);
}
