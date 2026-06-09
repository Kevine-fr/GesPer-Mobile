import 'package:get/get.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'token_storage.dart';

/// Service d'authentification global (singleton injecté par GetX).
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final AuthProvider _authProvider;
  final UserProvider _userProvider;
  final TokenStorage _tokens;

  AuthService(this._authProvider, this._userProvider, this._tokens);

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isAuthenticated = false.obs;

  Future<bool> bootstrap() async {
    try {
      final access = await _tokens.readAccessToken();
      if (access == null || access.isEmpty) {
        isAuthenticated.value = false;
        return false;
      }
      final user = await _userProvider.me();
      currentUser.value = user;
      isAuthenticated.value = true;
      return true;
    } catch (_) {
      await _tokens.clear();
      isAuthenticated.value = false;
      return false;
    }
  }

  Future<UserModel> login({required String email, required String password}) async {
    final resp = await _authProvider.login(email: email, password: password);
    await _tokens.saveTokens(accessToken: resp.accessToken, refreshToken: resp.refreshToken);
    final user = resp.user ?? await _userProvider.me();
    currentUser.value = user;
    isAuthenticated.value = true;
    return user;
  }

  /// Utilisé par le deep link OAuth2 : tokens reçus depuis le backend après login Google.
  Future<UserModel> loginWithTokens({required String accessToken, required String refreshToken}) async {
    await _tokens.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    final user = await _userProvider.me();
    currentUser.value = user;
    isAuthenticated.value = true;
    return user;
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (_) {
      // Best effort
    } finally {
      await _tokens.clear();
      currentUser.value = null;
      isAuthenticated.value = false;
    }
  }

  Future<void> refreshUser() async {
    if (!isAuthenticated.value) return;
    try {
      currentUser.value = await _userProvider.me();
    } catch (_) {}
  }
}
