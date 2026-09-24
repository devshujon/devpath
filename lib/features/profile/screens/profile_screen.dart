import 'package:flutter/material.dart';

import '../../../core/services/battery_service.dart';
import '../../../core/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (StorageService.instance.didRecoverFromCorruption)
            Card(
              margin: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Storage recovered from an issue. Some data may have reset.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Daily reminder'),
            subtitle: const Text('Enable notification permission'),
            onTap: () {
              // TODO: NotificationPermissionFlow.requestWithRationale(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.battery_charging_full),
            title: const Text('Battery whitelist'),
            subtitle: const Text('Keep reminders on time'),
            onTap: () => BatteryService.instance.requestIgnoreOptimizations(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            onTap: () {
              // TODO: open privacy policy URL
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('DevPath v1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'DevPath',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Learn HTML, CSS, JavaScript, and PHP on your phone.',
            ),
          ),
        ],
      ),
    );
  }
}
