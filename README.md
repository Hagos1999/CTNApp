# WATT

WATT is a smart meter application and hardware ecosystem built to monitor and analyze sensor readings. It allows users to register devices, track energy usage metrics securely, and view real-time statistics directly from their smartphone devices. This robust solution couples a powerful Flutter mobile app with performant C++ ESP hardware.

## Architecture
- **Mobile Application**: Flutter (Android & iOS support)
- **Hardware**: C++ based ESP code ensuring seamless data transmission.
- **Backend Services**: Supabase (Database/Authentication) and Firebase (Realtime updates/push notifications).
- **Security**: Environmental variables (`.env`) usage for securing all critical API endpoints, keys, tokens, and Wi-Fi credentials.

## Setup Instructions

### Environment Variables (.env)
Create a `.env` file at the root of the project by copying the example file:
```bash
cp .env.example .env
```
Fill in all values in `.env`:
```env
# Flutter + Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
FIREBASE_DATABASE_URL=your_firebase_database_url

# ESP32 Hardware
WIFI_SSID=your_wifi_ssid
WIFI_PASSWORD=your_wifi_password
SUPABASE_TABLE=sensor_readings
DEVICE_ID=your_device_id
DEVICE_SECRET=your_device_secret
READ_INTERVAL=15000
```
*Note: The real `.env` file is excluded from version control. Never commit it.*

### Mobile App (Flutter)
1. Ensure you have [Flutter installed](https://flutter.dev/docs/get-started/install).
2. Place your Firebase Android config:
   - Copy `android/app/google-services.json.example` to `android/app/google-services.json`
   - Replace the placeholders with your Firebase project values (download the real file from the Firebase console).
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Hardware Deployment
1. Navigate to the `CTN HARDWARE/CTN HARDWARE` directory.
2. Ensure you have the [PlatformIO extension](https://platformio.org/install/ide?install=vscode) or CLI installed.
3. Make sure the root `.env` file contains your Wi-Fi and Supabase credentials.
4. Build and flash to your ESP board:
   ```bash
   pio run -t upload
   ```
   The PlatformIO project reads the root `.env` file automatically via `load_env.py` and injects the values as compile-time macros. Do not edit `src/main.cpp` directly.

## Security Practices
- No secrets or API credentials (WiFi passwords, Firebase Database URLs, Supabase API Keys) are ever checked into this repository.
- Deployment-specific secrets are loaded from the local `.env` file at build time.
- `google-services.json` is excluded from version control; only the `.example` template is committed.
- Always rotate any credentials that were previously committed before production use.

## Contributing
Thank you for considering contributing to the WATT project. Please create a pull request with any improvements.
