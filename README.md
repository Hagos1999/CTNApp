# WATT

WATT is a smart meter application and hardware ecosystem built to monitor and analyze sensor readings. It allows users to register devices, track energy usage metrics securely, and view real-time statistics directly from their smartphone devices. This robust solution couples a powerful Flutter mobile app with performant C++ ESP hardware.

## Architecture
- **Mobile Application**: Flutter (Android & iOS support)
- **Hardware**: C++ based ESP code ensuring seamless data transmission.
- **Backend Services**: Supabase (Database/Authentication) and Firebase (Realtime updates/push notifications).
- **Security**: Environmental variables (`.env`) usage for securing all critical API endpoints, keys, and tokens.

## Setup Instructions

### Environment Variables (.env)
Create a `.env` file at the root of the project to securely provide necessary backend credentials. Use the provided variables:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
FIREBASE_DATABASE_URL=your_firebase_database_url
```
*Note: Make sure your `.env` file is excluded from version control (checked in `.gitignore`).*

### Mobile App (Flutter)
1. Ensure you have [Flutter installed](https://flutter.dev/docs/get-started/install).
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Hardware Deployment
1. Navigate to the `WATT Hardware/WATT HARDWARE` directory.
2. Ensure you have the [PlatformIO extension](https://platformio.org/install/ide?install=vscode) or Arduino IDE.
3. Open `src/main.cpp` and populate the WiFi and database constants with your credentials (these have been omitted for security).
4. Build and flash to your ESP board.

## Security Practices
- No secrets or API credentials (WiFi passwords, Firebase Database URLs, Supabase API Keys) are ever checked into this repository. 
- All deployment-specific secrets have been replaced with placeholders (`YOUR_WIFI_SSID`, `YOUR_SUPABASE_API_KEY`, etc.) in the hardware code.
- Always use the local `.env` configuration file for the Flutter build.

## Contributing
Thank you for considering contributing to the WATT project. Please create a pull request with any improvements.