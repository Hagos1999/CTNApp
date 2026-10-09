import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_reading.dart';
import '../repositories/supabase_data_repository.dart';
import '../repositories/sensor_repository.dart';
import 'settings_providers.dart';

/// Supabase data repo instance.
final supabaseDataRepoProvider = Provider<SupabaseDataRepository>((ref) {
  return SupabaseDataRepository(Supabase.instance.client);
});

/// Sensor repository (Supabase only).
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepository(
    supabaseRepo: ref.watch(supabaseDataRepoProvider),
  );
});

/// Stream of the latest sensor reading, auto-refreshed in real time.
final latestReadingProvider = StreamProvider<SensorReading>((ref) {
  final deviceId = ref.watch(deviceIdProvider);
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.streamLatestReading(deviceId);
});

/// Active data source (always supabase).
final dataSourceProvider = Provider<DataSource>((ref) {
  return DataSource.supabase;
});

/// Whether the device is online (last reading within 30 seconds and not mock data).
final deviceOnlineProvider = Provider<bool>((ref) {
  final readingAsync = ref.watch(latestReadingProvider);
  return readingAsync.whenOrNull(
        data: (reading) {
          if (reading.isMock) return false;
          final diff = DateTime.now().difference(reading.createdAt);
          return diff.inSeconds < 30;
        },
      ) ??
      false;
});

/// Date range filter for history screen.
enum DateRangeFilter { today, last7Days, last30Days }

/// Currently selected date range filter.
final dateRangeFilterProvider =
    NotifierProvider<DateRangeFilterNotifier, DateRangeFilter>(
        DateRangeFilterNotifier.new);

class DateRangeFilterNotifier extends Notifier<DateRangeFilter> {
  @override
  DateRangeFilter build() => DateRangeFilter.today;

  void setFilter(DateRangeFilter filter) {
    state = filter;
  }
}

/// Historical readings for the selected date range.
final readingsHistoryProvider =
    FutureProvider<List<SensorReading>>((ref) async {
  final deviceId = ref.watch(deviceIdProvider);
  final filter = ref.watch(dateRangeFilterProvider);
  final repo = ref.watch(sensorRepositoryProvider);

  final now = DateTime.now();
  late DateTime from;

  switch (filter) {
    case DateRangeFilter.today:
      from = DateTime(now.year, now.month, now.day);
      break;
    case DateRangeFilter.last7Days:
      from = now.subtract(const Duration(days: 7));
      break;
    case DateRangeFilter.last30Days:
      from = now.subtract(const Duration(days: 30));
      break;
  }

  return repo.getReadings(deviceId, from: from, to: now);
});
