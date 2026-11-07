#!/usr/bin/env bash
# Run from the folder that contains this script (the NikSocial project root).
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# 1. Generate android/ platform folder if missing
if [ ! -d android ]; then
  flutter create . --project-name niksocial --org com.niksocial.app --platforms android
fi

# 2. Package name -> com.niksocial.app
OLD="com.niksocial.app.niksocial"
NEW="com.niksocial.app"
grep -rl "$OLD" android --include=*.gradle --include=*.kts --include=*.xml --include=*.kt --include=*.java 2>/dev/null \
  | xargs -r sed -i "s/$OLD/$NEW/g" || true
KT=$(find android/app/src/main -name MainActivity.kt | head -1)
if [ -n "$KT" ]; then
  mkdir -p android/app/src/main/kotlin/com/niksocial/app
  [ "$KT" != "android/app/src/main/kotlin/com/niksocial/app/MainActivity.kt" ] && \
    mv "$KT" android/app/src/main/kotlin/com/niksocial/app/MainActivity.kt
  sed -i "s/^package .*/package $NEW/" android/app/src/main/kotlin/com/niksocial/app/MainActivity.kt
  find android/app/src/main/kotlin -type d -empty -delete 2>/dev/null || true
fi

# 3. App name + INTERNET permission
MAN=android/app/src/main/AndroidManifest.xml
sed -i 's/android:label="[^"]*"/android:label="NikSocial"/' "$MAN"
grep -q "android.permission.INTERNET" "$MAN" || \
  sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' "$MAN"

# 4. Build
flutter clean
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter analyze || true
flutter build apk --debug
flutter build apk --release

ls -lh build/app/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/app-release.apk
echo "DONE: build/app/outputs/flutter-apk/app-release.apk"
