#!/usr/bin/env bash
set -euo pipefail

# Empaqueta la app macOS (Release) en un .dmg comprimido.
# Uso (en macOS):
#   flutter build macos --release
#   ./tools/package_dmg.sh "Flutter UI Bench" "Flutter-UI-Bench.dmg"

APP_NAME="${1:-Flutter UI Bench}"
DMG_NAME="${2:-Flutter-UI-Bench.dmg}"

APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
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
