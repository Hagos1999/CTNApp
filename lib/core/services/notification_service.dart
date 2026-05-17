import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_strings.dart';

/// Centralized service for managing local push notifications.
///
/// Handles initialization, permission requests, and dispatching
/// notifications for various sensor alert conditions.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Notification channel IDs ───────────────────────────────
  static const String _channelId = 'watt_alerts';
  static const String _channelName = 'WATT Alerts';
  static const String _channelDesc =
      'Alerts for device status and abnormal readings';

  // ── Notification IDs (unique per type) ─────────────────────
  static const int idDeviceOffline = 1;
  static const int idHighVoltage = 2;
  static const int idLowPowerFactor = 3;
  static const int idEnergyMilestone = 4;
  static const int idTest = 99;

  // ── Thresholds ─────────────────────────────────────────────
  static const double highVoltageThreshold = 250.0;
  static const double lowPowerFactorThreshold = 0.85;
  static const double energyMilestoneKwh = 5.0;

  /// Initialize the notification plugin and request permissions.
  Future<void> init() async {
    if (_initialized) return;

    // Android initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('[NotificationService] Initialized successfully');
  }

  /// Callback when user taps a notification.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
      '[NotificationService] Notification tapped: ${response.payload}',
    );
  }

  // ── Notification details ───────────────────────────────────

  NotificationDetails _buildDetails({String? ticker}) {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: ticker,
      icon: '@mipmap/launcher_icon',
      color: const Color(0xFFFFD700), // Gold
      enableLights: true,
      ledColor: const Color(0xFFFFD700),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // ── Helper to show a notification ──────────────────────────

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    String? ticker,
    String? payload,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _buildDetails(ticker: ticker),
      payload: payload,
    );
  }

  // ── Public notification methods ────────────────────────────

  /// Send a test notification to verify the system works.
  Future<void> sendTestNotification() async {
    await _show(
      id: idTest,
      title: '⚡ ${AppStrings.appName}',
      body:
          'Notifications are working! You will receive alerts for abnormal readings.',
      ticker: 'WATT Test',
      payload: 'test',
    );
  }

  /// Alert: Device has gone offline.
  Future<void> notifyDeviceOffline(String deviceId) async {
    await _show(
      id: idDeviceOffline,
      title: '🔴 Device Offline',
      body:
          'Device "$deviceId" has stopped sending data. Check your ESP32 connection.',
      ticker: 'Device Offline',
      payload: 'device_offline',
    );
  }

  /// Alert: Device is back online.
  Future<void> notifyDeviceOnline(String deviceId) async {
    await _plugin.cancel(id: idDeviceOffline);
    await _show(
      id: idDeviceOffline,
      title: '🟢 Device Online',
      body: 'Device "$deviceId" is transmitting data again.',
      ticker: 'Device Online',
      payload: 'device_online',
    );
  }

  /// Alert: Voltage exceeded the safe threshold.
  Future<void> notifyHighVoltage(double voltage) async {
    await _show(
      id: idHighVoltage,
      title: '⚠️ High Voltage Detected',
      body:
          'Voltage reading: ${voltage.toStringAsFixed(1)}V exceeds the ${highVoltageThreshold.toStringAsFixed(0)}V safety threshold.',
      ticker: 'High Voltage',
      payload: 'high_voltage',
    );
  }

  /// Alert: Power factor dropped below acceptable range.
  Future<void> notifyLowPowerFactor(double pf) async {
    await _show(
      id: idLowPowerFactor,
      title: '⚠️ Low Power Factor',
      body:
          'Power factor dropped to ${pf.toStringAsFixed(2)}, below the $lowPowerFactorThreshold threshold. Check your load.',
      ticker: 'Low Power Factor',
      payload: 'low_power_factor',
    );
  }

  /// Alert: Daily energy milestone reached.
  Future<void> notifyEnergyMilestone(double energy) async {
    await _show(
      id: idEnergyMilestone,
      title: '🎉 Energy Milestone!',
      body:
          'Your solar system has generated ${energy.toStringAsFixed(2)} kWh today!',
      ticker: 'Energy Milestone',
      payload: 'energy_milestone',
    );
  }

  /// Cancel all active notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
