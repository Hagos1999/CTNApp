import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_reading.dart';
import '../../core/config/supabase_config.dart';

/// Primary data source — reads sensor data from Supabase PostgreSQL.
class SupabaseDataRepository {
  final SupabaseClient _client;

  SupabaseDataRepository(this._client);

  /// Fetch the most recent reading for a device.
  Future<SensorReading?> getLatestReading(String deviceId) async {
    final response = await _client
        .from(SupabaseConfig.sensorReadingsTable)
        .select()
        .eq('device_id', deviceId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SensorReading.fromJson(response);
  }

  /// Stream the latest reading using Supabase Realtime (Postgres Changes).
  Stream<SensorReading> streamLatestReading(String deviceId) {
    return _client
        .from(SupabaseConfig.sensorReadingsTable)
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .order('created_at', ascending: false)
        .limit(1)
        .where((rows) => rows.isNotEmpty)
        .map((rows) => SensorReading.fromJson(rows.first));
  }

  /// Fetch readings within a date range for charts/history.
  Future<List<SensorReading>> getReadings(
    String deviceId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _client
        .from(SupabaseConfig.sensorReadingsTable)
        .select()
        .eq('device_id', deviceId)
        .gte('created_at', from.toIso8601String())
        .lte('created_at', to.toIso8601String())
        .order('created_at', ascending: true);

    return (response as List)
        .map((row) => SensorReading.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
