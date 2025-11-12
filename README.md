# Flutter UI Bench

MVP para probar y medir rendimiento de componentes de UI en Flutter: botones, listas, inputs, animaciones, navegación y un “stress test”. Funciona offline con datos mock, expone overlay de rendimiento y logs internos.

## Requisitos

- Flutter 3.x / Dart 3.x
- Android SDK para compilar APK
- Para macOS: Xcode y toolchain Flutter con soporte macOS

## Estructura

```
lib/
	main.dart
	core/
		perf_monitor.dart
		metrics_log.dart
	screens/
		home_screen.dart
		buttons_test.dart
		lists_test.dart
		inputs_test.dart
		animations_test.dart
		navigation_test.dart
		stress_test.dart
	utils/
		mock_data.dart
```

## Ejecutar y medir

Modo recomendado: profile.

```
flutter run --profile
```

- Toggle del Performance Overlay: botón de “ojo” en la AppBar del Home.
- Logs: botón “Ver logs” en la AppBar del Home (mostrar/limpiar).
- Resumen en vivo: barra superior con frames, >16ms, >32ms y promedios.

### Cómo probar rápido (para otra persona)

Requisitos mínimos: Flutter 3.x (o solo Android SDK para instalar el APK) y un dispositivo/emulador.

- Opción A: Android (instalación directa)
	1. Descarga el APK de Releases (o genera uno con `flutter build apk --release`).
	2. Instálalo en un dispositivo o emulador Android.
	3. Abre la app, desde Home activa el “ojo” para ver FPS/Jank y entra a cada prueba.

- Opción B: Ejecutar en profile con Flutter
	1. Conecta un dispositivo o lanza un emulador (`flutter emulators --launch <id>`).
	2. Ejecuta:
		 ```
		 flutter run --profile
		 ```
	3. Abre DevTools (enlace en la consola) si deseas ver Timeline detallado.

- Opción C: macOS (.dmg)
	1. En un Mac con Xcode/Flutter: `flutter build macos --release`.
	2. Empaqueta (opcional):
		 ```
		 chmod +x tools/package_dmg.sh
		 ./tools/package_dmg.sh "Flutter UI Bench" "Flutter-UI-Bench.dmg"
		 ```
	3. Comparte el `.dmg` generado.

## Builds

Android (.apk):

```
flutter build apk --release
# Salida: build/app/outputs/flutter-apk/app-release.apk
```

macOS (.app) y empaquetado .dmg (ejecutar en macOS):

```
flutter build macos --release
APP_PATH="build/macos/Build/Products/Release/Flutter UI Bench.app"
DMG_DIR="build/release_dmg"; DMG_NAME="Flutter-UI-Bench.dmg"
mkdir -p "$DMG_DIR" && cp -R "$APP_PATH" "$DMG_DIR/"
hdiutil create -volname "Flutter UI Bench" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"
```

Notas macOS: En entornos sin firma, Gatekeeper puede requerir “Open Anyway”. Uso interno recomendado.

## Qué probar en la app

En la pantalla Home:

- “Ojo”: Performance Overlay (FPS/jank). 
- “Ver logs”: métrica de frames y navegación (limpiable).
- “Reset contadores”: reinicia contadores del monitor.

Pantallas:
- Buttons: taps con/ sin debounce; botón “Auto burst x50”.
- Lists: 1k/5k/10k ítems; alternar Grid; scroll rápido/lento.
- Inputs: tipeo continuo con validación diferida.
- Animations: 300/800/1500 ms; observar micro-stutters.
- Navigation: N ciclos push→auto-pop; medias push/pop.
- Stress Test: scroll + animación superpuesta por N segundos.

## Métricas capturadas

- Por frame: buildDuration, rasterDuration, totalMs (via `SchedulerBinding.addTimingsCallback`).
- Navegación: latencia push (inicio en Home, fin en `initState` de la pantalla destino); latencia pop (hasta el siguiente frame tras cerrar ruta).
- Overlay/FPS/Jank: Performance Overlay nativo de Flutter.

## Guía de pruebas (script)

1) Buttons
- [ ] 50 taps rápidos con debounce OFF, observar lag.
- [ ] 50 taps con debounce ON (150ms), observar cambios.

2) Lists
- [ ] List 1k ítems, scroll rápido/lento; registrar frames >16ms/>32ms.
- [ ] List 5k ítems.
- [ ] List 10k ítems.
- [ ] Alternar Grid ON/OFF y repetir.

3) Inputs
- [ ] Tipear 100 chars en 5s con validación; observar latencia teclado/validación.

4) Animations
- [ ] Ejecutar animación 300/800/1500ms y contar micro-stutters.

5) Navigation
- [ ] Correr 20 ciclos push→auto-pop y registrar medias de push/pop.

6) Stress Test
- [ ] Scroll 30s con animación superpuesta; anotar avgTotal y picos.

## Tabla de métricas

Rellena por dispositivo/OS y modo (profile/release):

| Test | Dispositivo/OS | Modo | FPS/Jank (overlay) | Frames >16ms | >32ms | avgTotal (ms) | Push avg (ms) | Pop avg (ms) | Notas |
|------|-----------------|------|--------------------|--------------|-------|---------------|---------------|--------------|-------|
| Buttons | | | | | | | | | |
| Lists 1k | | | | | | | | | |
| Lists 5k | | | | | | | | | |
| Lists 10k | | | | | | | | | |
| Inputs | | | | | | | | | |
| Anim 300 | | | | | | | | | |
| Anim 800 | | | | | | | | | |
| Anim 1500 | | | | | | | | | |
| Navigation x20 | | | | | | | | | |
| Stress 30s | | | | | | | | | |

## Notas

- Este MVP no incluye backend, persistencia ni analítica externa.
- Los contadores del resumen se pueden resetear desde el Home.
- Variabilidad: documenta hardware y OS. Para reproducibilidad, cierra apps en segundo plano y usa `--profile` o `--release`.
 
