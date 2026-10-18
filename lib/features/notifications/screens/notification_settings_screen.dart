import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notifications_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  static const route = '/notification-settings';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final s = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (!provider.permGrantedHint) ...[
            _PermissionBanner(
              onRequest: () => provider.ensurePermission(),
            ),
            const SizedBox(height: 4),
          ],
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('All notifications'),
            subtitle: const Text('Turn every reminder on or off.'),
            value: s.enabled,
            onChanged: (v) => provider.setEnabled(v),
          ),
          const Divider(height: 1),
          _ChannelTile(
            icon: Icons.school_outlined,
            title: 'Daily learning reminder',
            subtitle: '"Continue your DevPath journey"',
            enabled: s.dailyReminderEnabled,
            disabled: !s.enabled,
            time: s.dailyReminderTime,
            onToggle: (v) => provider.setDailyReminder(enabled: v),
            onPickTime: (t) => provider.setDailyReminder(time: t),
          ),
          _ChannelTile(
            icon: Icons.bolt_outlined,
            title: 'Daily challenge',
            subtitle: "\"Today's challenge is available\"",
            enabled: s.challengeReminderEnabled,
            disabled: !s.enabled,
            time: s.challengeReminderTime,
            onToggle: (v) => provider.setChallengeReminder(enabled: v),
            onPickTime: (t) => provider.setChallengeReminder(time: t),
          ),
          _ChannelTile(
            icon: Icons.local_fire_department_outlined,
            title: 'Streak warning',
            subtitle:
                '"Complete a lesson today to keep your streak"',
            enabled: s.streakWarningEnabled,
            disabled: !s.enabled,
            time: s.streakWarningTime,
            onToggle: (v) => provider.setStreakWarning(enabled: v),
            onPickTime: (t) => provider.setStreakWarning(time: t),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Notifications use inexact scheduling to conserve battery '
              'and comply with Play Store policy. Exact-minute delivery '
              'is not guaranteed.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool disabled;
  final TimeOfDay time;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onPickTime;

  const _ChannelTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.disabled,
    required this.time,
    required this.onToggle,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted =
        isDark ? const Color(0xFF8A929D) : const Color(0xFF5D6670);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: muted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: muted, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: enabled,
                      onChanged: disabled ? null : onToggle,
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: muted),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(_formatTime(context, time)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: (disabled || !enabled)
                      ? null
                      : () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (picked != null) onPickTime(picked);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay t) {
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(t, alwaysUse24HourFormat: false);
  }
}

class _PermissionBanner extends StatelessWidget {
  final VoidCallback onRequest;
  const _PermissionBanner({required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB020).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_paused_outlined,
              color: Color(0xFFB37800)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Permission needed to deliver reminders.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRequest,
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }
}
