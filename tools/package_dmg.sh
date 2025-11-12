#!/usr/bin/env bash
set -euo pipefail

# Empaqueta la app macOS (Release) en un .dmg comprimido.
# Uso (en macOS):
#   flutter build macos --release
#   ./tools/package_dmg.sh [APP_NAME] [DMG_NAME]
# Si APP_NAME no se pasa, se detecta automáticamente el primer .app en
# build/macos/Build/Products/Release/.

APP_NAME="${1:-}"
DMG_NAME="${2:-Flutter-UI-Bench.dmg}"

RELEASE_DIR="build/macos/Build/Products/Release"

if [[ -z "$APP_NAME" ]]; then
  # Detectar automáticamente la .app generada
  DETECTED_APP=$(ls -1 "$RELEASE_DIR"/*.app 2>/dev/null | head -n 1 || true)
  if [[ -z "$DETECTED_APP" ]]; then
    echo "No se encontró ningún .app en $RELEASE_DIR"
    echo "Construya primero: flutter build macos --release"
    exit 1
  fi
  APP_PATH="$DETECTED_APP"
  APP_NAME=$(basename "$APP_PATH" ".app")
else
  APP_PATH="$RELEASE_DIR/${APP_NAME}.app"
fi

DMG_DIR="build/release_dmg"

if [[ ! -d "$APP_PATH" ]]; then
  echo "No existe la app en: $APP_PATH"
  echo "Construya primero: flutter build macos --release"
  exit 1
fi

mkdir -p "$DMG_DIR"
rm -rf "$DMG_DIR/${APP_NAME}.app"
cp -R "$APP_PATH" "$DMG_DIR/"

hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"
echo "Listo: $DMG_NAME"
