import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late AppSettings _settings;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadSettings();
    }
  }

  void _loadSettings() {
    final storage = context.read<StorageService>();
    _settings = storage.getSettings();
    _apiKeyController = TextEditingController(text: _settings.apiKey ?? '');
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    _settings.apiKey = _apiKeyController.text.trim();
    await _settings.save();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'API Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'Gemini API Key',
              border: OutlineInputBorder(),
              hintText: 'AIza...',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your API key is stored locally on your device.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: _settings.isDarkMode,
              onChanged: (val) {
                setState(() => _settings.isDarkMode = val);
                _saveSettings();
              },
            ),
          ),
          const Divider(height: 48),
          FilledButton.icon(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text('Save & Close'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
