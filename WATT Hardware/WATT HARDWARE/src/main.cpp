#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <HardwareSerial.h>
#include <PZEM004Tv30.h>
#include <time.h>

// ─────────────────────────────────────────────
//  CONFIGURATION — edit these before flashing
// ─────────────────────────────────────────────

// WiFi
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// Supabase
const char* SUPABASE_URL     = "YOUR_SUPABASE_URL";
const char* SUPABASE_API_KEY = "YOUR_SUPABASE_API_KEY";
const char* SUPABASE_TABLE   = "sensor_readings";

// Firebase Realtime Database
const char* FIREBASE_URL     = "YOUR_FIREBASE_URL";
const char* FIREBASE_SECRET  = ""; // optional auth

// Device identity — must match what is set in the Flutter app
const char* DEVICE_ID = "esp32_001";

// Reading interval in milliseconds (15 seconds)
const unsigned long READ_INTERVAL = 15000;


// NTP for timestamps
const char* NTP_SERVER   = "pool.ntp.org";
const long  GMT_OFFSET   = 3600;  // adjust to your timezone (seconds). WAT = 3600
const int   DST_OFFSET   = 0;

// ─────────────────────────────────────────────
//  PZEM UART PINS
//  Connect PZEM TX → ESP32 GPIO16 (RX2)
//          PZEM RX → ESP32 GPIO17 (TX2)
// ─────────────────────────────────────────────
#define PZEM_RX_PIN 16
#define PZEM_TX_PIN 17

HardwareSerial pzemSerial(2); // UART2
PZEM004Tv30 pzem(pzemSerial, PZEM_RX_PIN, PZEM_TX_PIN);

// ─────────────────────────────────────────────
//  LED status pin (built-in LED on most ESP32 boards)
// ─────────────────────────────────────────────
#define STATUS_LED 2

unsigned long lastReadTime = 0;

// ─────────────────────────────────────────────
//  FUNCTION DECLARATIONS
// ─────────────────────────────────────────────
void connectWiFi();
String getISOTimestamp();
bool sendToSupabase(float voltage, float current, float power,
                    float energy, float frequency, float pf);
bool sendToFirebase(float voltage, float current, float power,
                    float energy, float frequency, float pf);
void blinkLED(int times, int delayMs);

// ─────────────────────────────────────────────
//  SETUP
// ─────────────────────────────────────────────
void setup() {
  Serial.begin(9600);
  pinMode(STATUS_LED, OUTPUT);

  Serial.println("\n=============================");
  Serial.println("  WATT Smart Meter — ESP32  ");
  Serial.println("=============================\n");

  connectWiFi();

  // Sync time via NTP
  configTime(GMT_OFFSET, DST_OFFSET, NTP_SERVER);
  Serial.print("Syncing NTP time");
  struct tm timeinfo;
  int attempts = 0;
  while (!getLocalTime(&timeinfo) && attempts < 10) {
    Serial.print(".");
    delay(1000);
    attempts++;
  }
  Serial.println(attempts < 10 ? " OK" : " FAILED (will retry)");

  Serial.println("Device ID : " + String(DEVICE_ID));
  Serial.println("Interval  : " + String(READ_INTERVAL / 1000) + "s");
  Serial.println("Ready.\n");
}

// ─────────────────────────────────────────────
//  LOOP
// ─────────────────────────────────────────────
void loop() {
  // Reconnect WiFi if dropped
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi lost — reconnecting...");
    connectWiFi();
  }

  unsigned long now = millis();
  if (now - lastReadTime >= READ_INTERVAL) {
    lastReadTime = now;

    // ── Read PZEM ──
    float voltage   = pzem.voltage();
    float current   = pzem.current();
    float power     = pzem.power();
    float energy    = pzem.energy();
    float frequency = pzem.frequency();
    float pf        = pzem.pf();

    // Validate readings (NaN means no sensor response)
    if (isnan(voltage)) {
      Serial.println("[PZEM] No response from sensor. Check wiring.");
      blinkLED(3, 200);
      return;
    }

    // Print to Serial monitor
    Serial.println("─────────────────────────────");
    Serial.printf("Voltage    : %.2f V\n",   voltage);
    Serial.printf("Current    : %.3f A\n",   current);
    Serial.printf("Power      : %.2f W\n",   power);
    Serial.printf("Energy     : %.3f kWh\n", energy);
    Serial.printf("Frequency  : %.1f Hz\n",  frequency);
    Serial.printf("Power Fac. : %.2f\n",     pf);
    Serial.println("─────────────────────────────");

    // ── Push to Supabase (primary) ──
    bool supabaseOK = sendToSupabase(voltage, current, power, energy, frequency, pf);

    // ── Push to Firebase (always — acts as realtime fallback for app) ──
    bool firebaseOK = sendToFirebase(voltage, current, power, energy, frequency, pf);

    if (supabaseOK || firebaseOK) {
      blinkLED(1, 100); // single blink = success
    } else {
      blinkLED(5, 100); // rapid blink = both failed
    }
  }
}

// ─────────────────────────────────────────────
//  WIFI
// ─────────────────────────────────────────────
void connectWiFi() {
  Serial.printf("Connecting to %s ", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println(" Connected!");
    Serial.println("IP: " + WiFi.localIP().toString());
    blinkLED(2, 200);
  } else {
    Serial.println(" FAILED. Will retry on next loop.");
  }
}

// ─────────────────────────────────────────────
//  TIMESTAMP  (ISO 8601)
// ─────────────────────────────────────────────
String getISOTimestamp() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return "1970-01-01T00:00:00Z";
  }
  char buf[30];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  return String(buf);
}

// ─────────────────────────────────────────────
//  SEND TO SUPABASE
//  Inserts a row into the sensor_readings table
// ─────────────────────────────────────────────
bool sendToSupabase(float voltage, float current, float power,
                    float energy, float frequency, float pf) {
  if (WiFi.status() != WL_CONNECTED) return false;

  HTTPClient http;
  String url = String(SUPABASE_URL) + "/rest/v1/" + SUPABASE_TABLE;

  // Build JSON body
  StaticJsonDocument<256> doc;
  doc["device_id"]    = DEVICE_ID;
  doc["voltage"]      = round(voltage * 100.0) / 100.0;
  doc["current"]      = round(current * 1000.0) / 1000.0;
  doc["power"]        = round(power * 100.0) / 100.0;
  doc["energy"]       = round(energy * 1000.0) / 1000.0;
  doc["frequency"]    = round(frequency * 10.0) / 10.0;
  doc["power_factor"] = round(pf * 100.0) / 100.0;
  doc["created_at"]   = getISOTimestamp();

  String body;
  serializeJson(doc, body);

  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_API_KEY);
  http.addHeader("Authorization", "Bearer " + String(SUPABASE_API_KEY));
  http.addHeader("Prefer", "return=minimal");

  int code = http.POST(body);
  bool ok  = (code == 200 || code == 201);

  Serial.printf("[Supabase] HTTP %d %s\n", code, ok ? "OK" : "FAILED");
  http.end();
  return ok;
}

// ─────────────────────────────────────────────
//  SEND TO FIREBASE RTDB
//  Writes to /devices/{device_id}/latest  (PUT — overwrites)
//  so the Flutter app always reads fresh data here
// ─────────────────────────────────────────────
bool sendToFirebase(float voltage, float current, float power,
                    float energy, float frequency, float pf) {
  if (WiFi.status() != WL_CONNECTED) return false;

  HTTPClient http;
  String url = String(FIREBASE_URL) + "/devices/" + DEVICE_ID + "/latest.json";

  // Optionally append auth token
  if (strlen(FIREBASE_SECRET) > 0) {
    url += "?auth=" + String(FIREBASE_SECRET);
  }

  // Build JSON body
  StaticJsonDocument<256> doc;
  doc["device_id"]    = DEVICE_ID;
  doc["voltage"]      = round(voltage * 100.0) / 100.0;
  doc["current"]      = round(current * 1000.0) / 1000.0;
  doc["power"]        = round(power * 100.0) / 100.0;
  doc["energy"]       = round(energy * 1000.0) / 1000.0;
  doc["frequency"]    = round(frequency * 10.0) / 10.0;
  doc["power_factor"] = round(pf * 100.0) / 100.0;
  doc["timestamp"]    = getISOTimestamp();
  doc["online"]       = true;

  String body;
  serializeJson(doc, body);

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  int code = http.PUT(body); // PUT overwrites node cleanly
  bool ok  = (code == 200);

  Serial.printf("[Firebase] HTTP %d %s\n", code, ok ? "OK" : "FAILED");
  http.end();
  return ok;
}

// ─────────────────────────────────────────────
//  LED BLINK HELPER
// ─────────────────────────────────────────────
void blinkLED(int times, int delayMs) {
  for (int i = 0; i < times; i++) {
    digitalWrite(STATUS_LED, HIGH);
    delay(delayMs);
    digitalWrite(STATUS_LED, LOW);
    delay(delayMs);
  }
}

