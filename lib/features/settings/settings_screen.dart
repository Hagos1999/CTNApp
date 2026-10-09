import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/sensor_providers.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../routing/app_router.dart';
import '../../core/services/notification_service.dart';
import 'widgets/device_id_input.dart';

/// Settings screen with device config, data source info, and logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider) ?? 'Unknown';
    final dataSource = ref.watch(dataSourceProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Device Configuration ──────────────────────────
            _SectionHeader(title: AppStrings.deviceConfig),
            const SizedBox(height: AppDimensions.md),
            _SettingsCard(
              child: Column(
                children: [
                  const DeviceIdInput(),
                  const SizedBox(height: AppDimensions.md),
                  _InfoRow(
                    icon: Icons.wifi_tethering_rounded,
                    label: 'Connection',
                    value: _connectionStatus(dataSource),
                    valueColor: _connectionColor(dataSource),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── Data Source ───────────────────────────────────
            _SectionHeader(title: AppStrings.dataSource),
            const SizedBox(height: AppDimensions.md),
            _SettingsCard(
              child: _InfoRow(
                icon: Icons.cloud_rounded,
                label: 'Active Backend',
                value: _dataSourceLabel(dataSource),
                valueColor: AppColors.gold,
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── Account ──────────────────────────────────────
            _SectionHeader(title: AppStrings.account),
            const SizedBox(height: AppDimensions.md),
            _SettingsCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context, ref),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(AppStrings.logout),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.offline,
                        side: const BorderSide(color: AppColors.offline),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── Notifications ─────────────────────────────────
            _SectionHeader(title: 'Notifications'),
            const SizedBox(height: AppDimensions.md),
            _SettingsCard(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _sendTestNotification(context),
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('Send Test Notification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'SIMULATE ALERTS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _SimulateButton(
                          label: 'Offline',
                          icon: Icons.wifi_off_rounded,
                          color: AppColors.offline,
                          onTap: () => _simulateOffline(context),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: _SimulateButton(
                          label: 'High V',
                          icon: Icons.electric_bolt_rounded,
                          color: const Color(0xFFFF6B35),
                          onTap: () => _simulateHighVoltage(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _SimulateButton(
                          label: 'Low PF',
                          icon: Icons.trending_down_rounded,
                          color: const Color(0xFFFF6B35),
                          onTap: () => _simulateLowPF(context),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: _SimulateButton(
                          label: 'Milestone',
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.gold,
                          onTap: () => _simulateMilestone(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.lg),

            // ── About ────────────────────────────────────────
            _SectionHeader(title: AppStrings.about),
            const SizedBox(height: AppDimensions.md),
            _SettingsCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.version,
                    value: '1.0.0',
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.08),
                          AppColors.gold.withValues(alpha: 0.02),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: AppColors.gold.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          AppStrings.poweredBy,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.gold.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: AppColors.offline)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  void _sendTestNotification(BuildContext context) {
    NotificationService.instance.sendTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent! Check your notification shade.'),
        backgroundColor: AppColors.gold,
      ),
    );
  }

  void _simulateOffline(BuildContext context) {
    NotificationService.instance.notifyDeviceOffline('ESP32-PZEM');
    _showSimulatedSnack(context, 'Device Offline alert sent');
  }

  void _simulateHighVoltage(BuildContext context) {
    NotificationService.instance.notifyHighVoltage(263.5);
    _showSimulatedSnack(context, 'High Voltage alert sent');
  }

  void _simulateLowPF(BuildContext context) {
    NotificationService.instance.notifyLowPowerFactor(0.72);
    _showSimulatedSnack(context, 'Low Power Factor alert sent');
  }

  void _simulateMilestone(BuildContext context) {
    NotificationService.instance.notifyEnergyMilestone(5.23);
    _showSimulatedSnack(context, 'Energy Milestone alert sent');
  }

  void _showSimulatedSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardBgElevated,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _dataSourceLabel(DataSource source) {
    switch (source) {
      case DataSource.supabase:
        return 'Supabase';
      case DataSource.none:
        return 'Disconnected';
    }
  }

  String _connectionStatus(DataSource source) {
    switch (source) {
      case DataSource.supabase:
        return 'Connected';
      case DataSource.none:
        return 'Disconnected';
    }
  }

  Color _connectionColor(DataSource source) {
    switch (source) {
      case DataSource.supabase:
        return AppColors.online;
      case DataSource.none:
        return AppColors.offline;
    }
  }
}

/// Section header text.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.gold.withValues(alpha: 0.7),
            letterSpacing: 1.5,
            fontSize: 12,
          ),
    );
  }
}

/// Card wrapper for settings groups.
class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

/// A row showing a label and value with an icon.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppDimensions.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Compact simulate button for triggering test alerts.
class _SimulateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SimulateButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.md,
            horizontal: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
