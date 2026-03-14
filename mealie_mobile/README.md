# Mealie Mobile (Local & Google Drive Backup)

Dit is de nieuwe, volledig lokale mobiele versie van Mealie, specifiek geoptimaliseerd voor Android (Samsung S24 Ultra). De app maakt gebruik van Flutter en SQLite om al je recepten lokaal op te slaan zonder een server. Tevens zit er een geautomatiseerde back-up naar jouw Google Drive in gebouwd!

## Functionaliteiten in deze versie
1. **Volledig Lokaal:** Recepten staan in een SQLite database (`recipes.db`).
2. **Recepten Scrapen (Zonder fluff):** Plak een URL en de app pikt de `schema.org/Recipe` data op.
3. **Google Drive Backup:** De database wordt automatisch naar de root of de AppData folder van je Google Drive geüpload zodat je nooit iets kwijtraakt.

---

## Setup Instructies voor "Antigravity IDE" / Lokaal

Omdat we hier in een AI Sandbox werken, heb ik de broncode voor je klaargezet. Volg deze stappen om het project op je eigen PC (met je Antigravity IDE of Android Studio) in te laden en naar je Samsung S24 Ultra te sturen:

### 1. Download de broncode
Kopieer de map `mealie_mobile` uit deze repository naar je eigen lokale ontwikkelmachine.

### 2. Flutter installeren
Zorg dat je [Flutter geïnstalleerd hebt](https://docs.flutter.dev/get-started/install).

### 3. Dependencies ophalen
Open de map `mealie_mobile` in je terminal (of je IDE) en run:
```bash
flutter pub get
```

### 4. Google Drive OAuth Configureren
Voordat de app kan inloggen op jouw Google Drive, moet je een Client ID aanmaken:
1. Ga naar de [Google Cloud Console](https://console.cloud.google.com/).
2. Maak een nieuw project aan (bijv. "Mealie Mobile Backup").
3. Ga naar **APIs & Services > Credentials**.
4. Maak een **OAuth client ID** aan. Kies als Application Type: **Android**.
5. Vul je package name in (dit kun je vinden/aanpassen in `android/app/build.gradle`, standaard vaak `com.example.mealie_mobile`).
6. Genereer een SHA-1 certificaat vingerafdruk (via Java `keytool` of Gradle) en vul deze in.
7. Zodra je dit gedaan hebt, zal de `google_sign_in` package in de app (in `lib/services/google_drive_service.dart`) out-of-the-box werken op je Android apparaat!

*Let op: zorg ervoor dat je in de Google Cloud Console ook de "Google Drive API" inschakelt!*

### 5. App draaien op je Samsung S24 Ultra
1. Zet **Developer Mode** en **USB Debugging** aan op je Samsung.
2. Sluit hem aan via USB.
3. In je IDE (Antigravity/Android Studio/VSCode), selecteer je Samsung als "Target device".
4. Klik op de "Run" of "Play" knop (of run `flutter run` in je terminal).

De app zal nu gecompileerd worden en opstarten op je telefoon!

---
## Archief
De originele Python server en Vue web-app staan in de map `archive_mealie_web/` in de root van de repository. Je kunt deze map raadplegen als je logica wilt overnemen of als naslagwerk.
