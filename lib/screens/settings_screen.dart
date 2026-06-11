import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildSection('About', [
          _buildInfoTile('App Name', 'YueC'),
          _buildInfoTile('Version', '1.0.0'),
          _buildInfoTile('License', 'MIT'),
        ]),
        const SizedBox(height: 16),
        _buildSection('Playback', [
          SwitchListTile(
            title: const Text(
              'Auto Play',
              style: TextStyle(color: Colors.white),
            ),
            value: true,
            activeColor: const Color(0xFF1DB954),
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text(
              'Background Play',
              style: TextStyle(color: Colors.white),
            ),
            value: true,
            activeColor: const Color(0xFF1DB954),
            onChanged: (_) {},
          ),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Card(
          color: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
