import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sensor_reading.dart';
import 'supabase_data_repository.dart';

/// Which backend is currently serving data.
enum DataSource { supabase, none }

/// Fetches sensor data from Supabase with mock fallback when offline.
class SensorRepository {
  final SupabaseDataRepository _supabaseRepo;

  SensorRepository({
    required SupabaseDataRepository supabaseRepo,
  }) : _supabaseRepo = supabaseRepo;

  /// Fetch the latest reading.
  Future<SensorReading?> getLatestReading(String deviceId) async {
    try {
      final reading = await _supabaseRepo
          .getLatestReading(deviceId)
          .timeout(const Duration(seconds: 10));
      return reading;
    } catch (e) {
      debugPrint('[SensorRepository] Supabase failed: $e');
    }
    return null;
  }

  /// Stream the latest reading with mock fallback when the device is offline.
  /// Polls Supabase every 10s. Switches between real and mock based on
  /// whether fresh data is detected (last reading within 30s).
  Stream<SensorReading> streamLatestReading(String deviceId) {
    final controller = StreamController<SensorReading>();
    Timer? pollTimer;
    Timer? mockTimer;
    StreamSubscription<SensorReading>? realSub;
    DateTime? lastRealTimestamp;
    var inMockMode = true;

    void emitReal(SensorReading reading) {
      lastRealTimestamp = reading.createdAt;
      if (inMockMode) {
        inMockMode = false;
        mockTimer?.cancel();
        debugPrint('[SensorRepository] Switched to real data');
      }
      if (!controller.isClosed) {
        controller.add(reading);
      }
    }

    void emitMock() {
      if (inMockMode && !controller.isClosed) {
        controller.add(SensorReading.mock(deviceId));
      }
    }

    void checkFreshness() {
      final isStale = lastRealTimestamp == null ||
          DateTime.now().difference(lastRealTimestamp!).inSeconds > 30;
      if (isStale && !inMockMode) {
        debugPrint('[SensorRepository] Data stale — switching to mock');
        inMockMode = true;
        mockTimer = Timer.periodic(const Duration(seconds: 3), (_) => emitMock());
        emitMock();
      }
    }

    void poll() async {
      try {
        final reading = await _supabaseRepo
            .getLatestReading(deviceId)
            .timeout(const Duration(seconds: 8));
        if (reading != null) {
          emitReal(reading);
          checkFreshness();
          return;
        }
      } catch (_) {}
      checkFreshness();
    }

    // Realtime stream for low-latency updates
    realSub = _supabaseRepo.streamLatestReading(deviceId).listen(
      (reading) {
        debugPrint('[SensorRepository] Realtime event received');
        emitReal(reading);
      },
      onError: (error) {
        debugPrint('[SensorRepository] Stream error: $error');
      },
    );

    // Start in mock mode, poll immediately to check for existing data
    inMockMode = true;
    mockTimer = Timer.periodic(const Duration(seconds: 3), (_) => emitMock());
    poll();

    // Continuous polling every 10s
    pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => poll());

    controller.onCancel = () {
      pollTimer?.cancel();
      mockTimer?.cancel();
      realSub?.cancel();
    };

    return controller.stream;
  }

  /// Fetch historical readings.
  Future<List<SensorReading>> getReadings(
    String deviceId, {
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final readings = await _supabaseRepo
          .getReadings(deviceId, from: from, to: to)
          .timeout(const Duration(seconds: 15));
      return readings;
    } catch (e) {
      debugPrint('[SensorRepository] Supabase history failed: $e');
    }
    return [];
  }
}
