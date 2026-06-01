abstract class Validators {
  Validators._();

  static String? required(String? value, [String message = 'Champ requis']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Au moins 8 caractères';
    return null;
  }

  static String? Function(String?) matches(String Function() other, [String? message]) =>
      (value) {
        if (value != other()) return message ?? 'Les valeurs ne correspondent pas';
        return null;
      };

  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) return 'Montant requis';
    final n = num.tryParse(value.replaceAll(',', '.'));
    if (n == null) return 'Montant invalide';
    if (n < 0) return 'Doit être positif';
    return null;
  }

  static String? code6(String? value) {
    if (value == null || value.isEmpty) return 'Code requis';
    if (value.length != 6) return 'Code à 6 chiffres';
    if (int.tryParse(value) == null) return 'Chiffres uniquement';
    return null;
  }
}
