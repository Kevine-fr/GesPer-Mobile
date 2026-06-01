# GesPer App — Application Flutter

> Client mobile pour l'API **GesPer Server** (Spring Boot).
> Architecture **GetX**, animations soignées, graphiques `fl_chart`,
> thème clair/sombre persistant, authentification JWT + Google OAuth2.

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-blue)](https://dart.dev)
[![GetX](https://img.shields.io/badge/GetX-4.6-purple)](https://pub.dev/packages/get)

---

## Sommaire

- [Aperçu](#aperçu)
- [Architecture](#architecture)
- [Démarrage](#démarrage)
- [Configuration du backend](#configuration-du-backend)
- [Configuration Google OAuth2](#configuration-google-oauth2)
- [Théming & UI](#théming--ui)
- [Structure des dossiers](#structure-des-dossiers)
- [Stack technique](#stack-technique)

---

## Aperçu

L'app consomme **exactement** l'API REST `gesper-server` :

- **Auth** : inscription avec code email à 6 chiffres, login JWT, refresh token rotatif automatique sur 401, login Google via OAuth2 deep link (`gesper://oauth2/redirect`).
- **Dashboard** animé : solde, totaux, courbe gains/dépenses 6 mois, pie chart par catégorie, bar chart de solde mensuel, transactions récentes.
- **Gains / Dépenses** : liste paginée, swipe-to-delete, formulaire de création/édition, lien optionnel d'une dépense vers un gain.
- **Catégories** : tabs Dépenses / Revenus, CRUD pour les admins.
- **Profil** : avatar gradient, choix du thème (Clair / Sombre / Système), déconnexion.
- **Theme toggle persistant** (GetStorage) ; tous les écrans réagissent en live.
- **Animations** : `flutter_animate` (fade, slide, scale, elastic), animated bottom nav avec label expansible, fond dégradé animé sur le splash, hero transitions.

---

## Architecture

Pattern **MVC GetX** clair, séparation stricte data ↔ business ↔ UI :

```
lib/
├── app/                      Routing, bindings globaux, config
│   ├── config/app_config.dart
│   ├── routes/                app_pages.dart (GetPage list) + app_routes.dart
│   └── bindings/initial_binding.dart
│
├── core/                     Code transverse réutilisable
│   ├── theme/                AppTheme (light/dark) + ThemeController (Get + GetStorage)
│   ├── utils/                Formatters, validators, AppToast
│   ├── values/               AppColors, AppStrings
│   ├── errors/               AppException hiérarchie
│   └── widgets/              Boutons, charts, shimmer, stat cards, transaction tile…
│
├── data/                     Couche réseau / modèles / services
│   ├── models/               UserModel, GainModel, SpentModel, ApiEnvelope<T>, PageEnvelope<T>…
│   ├── providers/            Appels HTTP via Dio (AuthProvider, UserProvider, …)
│   └── services/             DioClient (avec interceptors auth + refresh), AuthService,
│                             TokenStorage (FlutterSecureStorage), OAuthDeepLinkHandler
│
└── modules/                  Écrans (1 dossier par feature)
    ├── splash/               page + controller + binding
    ├── auth/login, register, verify_code
    ├── home/                 Shell avec bottom nav animée
    ├── dashboard/            Graphiques + résumé
    ├── gains/                Liste + form
    ├── spents/               Liste + form
    ├── categories/           Tabs + form bottom sheet
    └── profile/              Avatar + paramètres + thème
```

### Flux de données

```
[Page (GetView<Controller>)]
        ↓ user action
[Controller GetxController]   ← .obs, Rx, isLoading
        ↓ appel
[Provider]                    ← Dio
        ↓
[DioClient]                   ← interceptor JWT + refresh + error mapping
        ↓
[API Spring Boot]
```

L'**AuthInterceptor** tente un refresh automatique sur 401 (en file d'attente) ; en cas d'échec, il vide le secure storage et redirige sur `/login`.

---

## Démarrage

### 1. Prérequis

- Flutter SDK ≥ **3.22.0** (Dart 3.4+)
- Backend `gesper-server` qui tourne — voir le projet Java.

### 2. Bootstrap

```bash
cd gesper_app
./bootstrap.sh
```

Le script :
1. exécute `flutter create .` pour générer les dossiers `android/`, `ios/`, `web/`,
2. appelle `flutter pub get`,
3. affiche un rappel pour insérer les patchs OAuth2 (voir ci-dessous).

### 3. Configuration des deep links OAuth2

Patchs à appliquer **manuellement** après `flutter create .` :

- `android/app/src/main/AndroidManifest.xml` :
  voir `platform-config/android_manifest_snippet.xml`
  → ajout de la permission Internet, du scheme custom `gesper://oauth2`,
  et de `android:usesCleartextTraffic="true"` (DEV uniquement).

- `ios/Runner/Info.plist` :
  voir `platform-config/ios_info_plist_snippet.xml`
  → déclaration du scheme `gesper` et `NSAppTransportSecurity` (DEV uniquement).

### 4. Lancer

```bash
# Émulateur Android (10.0.2.2 = host depuis l'émulateur)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1

# Device physique sur le même WiFi
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:8080/api/v1

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Par défaut (sans `--dart-define`), l'app pointe sur `http://10.0.2.2:8080/api/v1`.

---

## Configuration du backend

L'app **consomme tels quels** les endpoints `gesper-server` :

| Feature        | Endpoints utilisés                                                  |
| -------------- | ------------------------------------------------------------------- |
| Auth           | `/auth/send-code/client`, `/auth/register/client?code=`, `/auth/login`, `/auth/refresh`, `/auth/logout` |
| OAuth2 Google  | `/oauth2/authorize/google?redirect_uri=gesper://oauth2/redirect`    |
| Profil         | `/users/me` (GET / PUT)                                             |
| Admin Users    | `/users/admin?page=&size=`, `/users/admin/{id}/disable`, etc.       |
| Catégories     | `/categories` (CRUD)                                                |
| Gains          | `/gains/me`, `/gains` (POST), `/gains/me/{id}` (PUT), `/gains/me/{id}/soft-delete` (PATCH) |
| Dépenses       | Symétrique : `/spents/me`, `/spents`, `/spents/me/{id}`, …         |

L'enveloppe `ApiEnvelope<T>` reflète exactement le `ApiResponse<T>` Java et la pagination `PageEnvelope<T>` reflète `PageResponse<T>`.

---

## Configuration Google OAuth2

1. Côté **backend** Spring Boot, ajouter dans `.env` :
   ```
   OAUTH2_REDIRECT_URIS=gesper://oauth2/redirect
   ```
2. Côté **Flutter**, c'est déjà câblé :
   - `LoginController.loginWithGoogle()` lance le navigateur sur
     `http://<API>/oauth2/authorize/google?redirect_uri=gesper://oauth2/redirect`
   - Google → backend → backend redirige vers `gesper://oauth2/redirect?token=...&refreshToken=...`
   - L'OS rappelle l'app via le scheme `gesper://`
   - `OAuthDeepLinkHandler` (initialisé dans `main.dart`) capture l'URL, extrait les tokens et appelle `AuthService.loginWithTokens(...)`.

---

## Théming & UI

- **Material 3** + palette indigo + accents vert (gains) / rouge (dépenses).
- `ThemeController` persiste le choix dans GetStorage (`theme_mode` = `system|light|dark`).
- Le `ThemeToggle` est présent dans toutes les pages principales.
- Composants stylisés cohérents : `AppPrimaryButton` avec gradient + loading + animation, `StatCard` avec compteur animé (`TweenAnimationBuilder`), `TotalBanner`, `TransactionTile`, etc.
- Animations : `flutter_animate` pour fade/slide/scale, transitions GetX par route (`Transition.downToUp` pour les forms, `fadeIn` pour le splash).

---

## Stack technique

| Domaine          | Choix                                         |
| ---------------- | --------------------------------------------- |
| State management | `get` 4.6 (RxN, Obx, GetxController)          |
| Routing & DI     | `Get.toNamed`, `Bindings`, `GetPage`          |
| HTTP             | `dio` + `pretty_dio_logger`                   |
| Stockage tokens  | `flutter_secure_storage` (Keystore / Keychain)|
| Préférences      | `get_storage`                                 |
| Charts           | `fl_chart`                                    |
| Animations       | `flutter_animate`, `shimmer`                  |
| Fonts            | `google_fonts` (Inter)                        |
| Validation       | `Validators` maison + `flutter_form_builder`  |
| i18n             | `intl` (fr_FR)                                |
| Deep links       | `app_links`                                   |
| Browser launch   | `url_launcher`                                |

---

## Sécurité (côté client)

- Tokens stockés via `flutter_secure_storage` (chiffrés via Keystore Android / Keychain iOS).
- Refresh token rotatif : chaque appel à `/auth/refresh` remplace les deux tokens. L'access token est court (15 min).
- L'access token est ajouté en `Authorization: Bearer …` par un interceptor Dio, jamais persisté côté JS/web sans chiffrement.
- Sur 401, refresh transparent en file d'attente (`QueuedInterceptorsWrapper`) puis rejeu de la requête.

---

## Production

Pour build l'APK / IPA :

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.gesper.com/api/v1

flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.gesper.com/api/v1
```

Penser à :
- retirer `android:usesCleartextTraffic` et `NSAllowsArbitraryLoads` (HTTPS uniquement),
- générer un keystore Android et `--obfuscate --split-debug-info`,
- mettre à jour le scheme OAuth2 si besoin (et l'URI autorisée côté Google Cloud Console).

---

## Licence

MIT
