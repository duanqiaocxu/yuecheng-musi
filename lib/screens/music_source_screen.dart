import 'package:flutter/material.dart';
import '../models/music_source.dart';

class MusicSourceScreen extends StatefulWidget {
  const MusicSourceScreen({super.key});

  @override
  State<MusicSourceScreen> createState() => _MusicSourceScreenState();
}

class _MusicSourceScreenState extends State<MusicSourceScreen> {
  final List<MusicSource> _sources = [
    MusicSource(
      name: 'YueC Default',
      description: 'Built-in music source powered by YueC',
      url: 'https://example.com/source.js',
      enabled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Music Sources',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Music sources provide search and playback capabilities. Add custom JS source scripts to extend YueC.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        ..._sources.map((source) => Card(
              color: const Color(0xFF2A2A2A),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: source.enabled
                        ? const Color(0xFF1DB954).withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.source,
                    color: source.enabled
                        ? const Color(0xFF1DB954)
                        : Colors.grey,
                  ),
                ),
                title: Text(
                  source.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  source.description,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                trailing: Switch(
                  value: source.enabled,
                  activeColor: const Color(0xFF1DB954),
                  onChanged: (val) {
                    setState(() => source.enabled = val);
                  },
                ),
              ),
            )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add Source'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1DB954),
            side: const BorderSide(color: Color(0xFF1DB954)),
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
