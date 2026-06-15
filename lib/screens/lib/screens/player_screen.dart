import 'package:flutter/material.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final Map<String, String> songData;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.songData,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1535),
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.music_note, size: 100, color: Color(0xFF4080FF)),
            const SizedBox(height: 32),
            Text(widget.title, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 22)),
            const SizedBox(height: 8),
            Text(widget.artist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
