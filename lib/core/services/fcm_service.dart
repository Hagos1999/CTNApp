import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[FCMService] User granted permission');
      
      // Get the token
      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCMService] FCM Token: $token');
        await _saveTokenToSupabase(token);
      }

      // Listen for token updates
      _messaging.onTokenRefresh.listen(_saveTokenToSupabase);
      
      // Setup foreground message handler (optional, if you want local alerts when app is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCMService] Got a message whilst in the foreground!');
        debugPrint('[FCMService] Message data: ${message.data}');
        if (message.notification != null) {
          debugPrint('[FCMService] Message also contained a notification: ${message.notification}');
        }
      });
    } else {
      debugPrint('[FCMService] User declined or has not accepted permission');
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Here we assume a 'user_profiles' or 'fcm_tokens' table exists.
        // For CTNApp, we will use the 'users' or a dedicated table.
        // Assuming a table 'fcm_tokens' with columns user_id and token.
        await Supabase.instance.client
            .from('fcm_tokens')
            .upsert({
              'user_id': user.id,
              'token': token,
              'updated_at': DateTime.now().toIso8601String(),
            });
        debugPrint('[FCMService] Token saved to Supabase');
      }
    } catch (e) {
      debugPrint('[FCMService] Failed to save token to Supabase: $e');
    }
  }
}
