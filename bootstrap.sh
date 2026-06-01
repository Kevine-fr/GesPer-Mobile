#!/usr/bin/env bash
# Bootstrap script for the GesPer Flutter app.
# Generates the missing platform folders (Android, iOS, web…) and installs deps.

set -euo pipefail

cd "$(dirname "$0")"

echo "→ Vérification de la version Flutter requise…"
flutter --version | head -1

echo "→ Génération des dossiers plateformes (Android, iOS, web)…"
# org reverse-domain → com.gesper.app, donc le package Android sera com.gesper.app
flutter create --org com.gesper --project-name gesper_app --platforms=android,ios,web .

echo "→ Application des patchs OAuth2 (gesper:// scheme)…"
echo "   ⚠️  À FAIRE MANUELLEMENT :"
echo "   1. Ouvrir android/app/src/main/AndroidManifest.xml"
echo "      Insérer les blocs depuis platform-config/android_manifest_snippet.xml"
echo ""
echo "   2. Ouvrir ios/Runner/Info.plist"
echo "      Insérer les blocs depuis platform-config/ios_info_plist_snippet.xml"
echo ""

echo "→ Installation des dépendances…"
flutter pub get

echo ""
echo "✔  Bootstrap terminé !"
echo ""
echo "   Lancement (émulateur Android) :"
echo "     flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1"
echo ""
echo "   Lancement (device physique sur même WiFi) :"
echo "     flutter run --dart-define=API_BASE_URL=http://<IP-PC>:8080/api/v1"
