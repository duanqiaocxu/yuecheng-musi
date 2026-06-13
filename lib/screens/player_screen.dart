import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart';

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
  final AudioPlayer _player = AudioPlayer();
  final MusicService _musicService = MusicService();
  bool _isPlaying = false;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final url = await _musicService.getSongUrl(widget.songData);
      if (url.isEmpty) throw Exception('No URL');
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _player.play();
      if (mounted) setState(() { _isPlaying = true; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1535),
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4080FF)))
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note, size: 100, color: Color(0xFF4080FF)),
                      const SizedBox(height: 24),
                      Text(widget.title, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 22)),
                      const SizedBox(height: 8),
                      Text(widget.artist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 16)),
                      const SizedBox(height: 24),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: const Color(0xFF4080FF)),
                        onPressed: () {
                          if (_isPlaying) { _player.pause(); setState(() => _isPlaying = false); }
                          else { _player.play(); setState(() => _isPlaying = true); }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }
}
