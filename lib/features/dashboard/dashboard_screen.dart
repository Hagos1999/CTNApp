import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/providers/sensor_providers.dart';
import 'widgets/reading_card.dart';
import 'widgets/status_indicator.dart';
import 'widgets/last_updated_text.dart';

/// Main dashboard screen showing live sensor readings in a 2-column grid.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(latestReadingProvider);
    final isOnline = ref.watch(deviceOnlineProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          // Data source badge
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.md),
            child: StatusIndicator(isOnline: isOnline),
          ),
        ],
      ),
      body: readingAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, ref, error),
        data: (reading) => RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.cardBg,
          onRefresh: () async {
            ref.invalidate(latestReadingProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Demo mode banner
                if (reading.isMock) _buildDemoBanner(context),
                // Last updated
                LastUpdatedText(
                  lastUpdated: reading.createdAt,
                  isMock: reading.isMock,
                ),
                const SizedBox(height: AppDimensions.md),
                // Reading cards grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.md,
                  mainAxisSpacing: AppDimensions.md,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.15,
                  children: [
                    ReadingCard(
                      icon: Icons.bolt_rounded,
                      label: AppStrings.voltage,
                      value: reading.voltage.toStringAsFixed(1),
                      unit: AppStrings.unitVoltage,
                      accentColor: const Color(0xFFFFD700),
                    ),
                    ReadingCard(
                      icon: Icons.power_rounded,
                      label: AppStrings.current,
                      value: reading.current.toStringAsFixed(2),
                      unit: AppStrings.unitCurrent,
                      accentColor: const Color(0xFF4FC3F7),
                    ),
                    ReadingCard(
                      icon: Icons.lightbulb_rounded,
                      label: AppStrings.power,
                      value: reading.power.toStringAsFixed(1),
                      unit: AppStrings.unitPower,
                      accentColor: const Color(0xFFFFA726),
                    ),
                    ReadingCard(
                      icon: Icons.battery_charging_full_rounded,
                      label: AppStrings.energy,
                      value: reading.energy.toStringAsFixed(3),
                      unit: AppStrings.unitEnergy,
                      accentColor: const Color(0xFF66BB6A),
                    ),
                    ReadingCard(
                      icon: Icons.waves_rounded,
                      label: AppStrings.frequency,
                      value: reading.frequency.toStringAsFixed(1),
                      unit: AppStrings.unitFrequency,
                      accentColor: const Color(0xFFAB47BC),
                    ),
                    ReadingCard(
                      icon: Icons.speed_rounded,
                      label: AppStrings.powerFactor,
                      value: reading.powerFactor.toStringAsFixed(2),
                      unit: AppStrings.unitPowerFactor,
                      accentColor: const Color(0xFFEF5350),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),

                // Data source info
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reading.isMock
                            ? Icons.science_rounded
                            : Icons.cloud_done_rounded,
                        color: AppColors.gold.withValues(alpha: 0.7),
                        size: AppDimensions.iconSm,
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        reading.isMock
                            ? 'Demo mode — connect ESP32 for live data'
                            : 'Device: ${reading.deviceId}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Shimmer.fromColors(
        baseColor: AppColors.cardBg,
        highlightColor: AppColors.surfaceDark,
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.md,
          mainAxisSpacing: AppDimensions.md,
          childAspectRatio: 1.15,
          children: List.generate(
            6,
            (index) => Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.offline.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: AppColors.offline,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              AppStrings.connectionError,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(latestReadingProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.science_rounded,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'Demo mode — showing realistic sample readings. Connect ESP32 for live data.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
