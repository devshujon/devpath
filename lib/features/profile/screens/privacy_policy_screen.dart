import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_urls.dart';

/// In-app privacy policy (bundled summary + link to canonical web page).
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _text = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final body = await rootBundle.loadString('assets/legal/privacy_policy.md');
      if (!mounted) return;
      setState(() => _text = body);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load privacy policy.');
    }
  }

  Future<void> _openWebPolicy() async {
    final uri = Uri.parse(AppUrls.privacyPolicy);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the web privacy policy.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy policy'),
        actions: [
          IconButton(
            tooltip: 'Open web privacy policy',
            onPressed: _openWebPolicy,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _text.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Full policy online',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                const SizedBox(height: 8),
                                const SelectableText(AppUrls.privacyPolicy),
                                const SizedBox(height: 12),
                                FilledButton.tonalIcon(
                                  onPressed: _openWebPolicy,
                                  icon: const Icon(Icons.public),
                                  label: const Text('Open in browser'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          _text,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
