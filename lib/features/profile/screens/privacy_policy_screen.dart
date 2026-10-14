import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-app privacy policy (bundled asset — not a remote URL).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: _error != null
          ? Center(child: Text(_error!))
          : _text.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(
                      _text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                    ),
                  ),
                ),
    );
  }
}
