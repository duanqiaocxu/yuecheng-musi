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
      body: Center(
        child: _isLoading
          ? const CircularProgressIndicator(color: Color(0xFF4080FF))
          : _error.isNotEmpty
            ? Text(_error, style: const TextStyle(color: Colors.red, fontSize: 16))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.music_note, size: 100, color: Color(0xFF4080FF)),
                  const SizedBox(height: 32),
                  Text(widget.title, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(widget.artist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 16)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 40, color: Color(0xFF7799CC)),
                        onPressed: null,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF4080FF), Color(0xFF6060FF)]),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 48, color: Colors.white),
                          onPressed: () {
                            if (_isPlaying) { _player.pause(); setState(() => _isPlaying = false); }
                            else { _player.play(); setState(() => _isPlaying = true); }
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 40, color: Color(0xFF7799CC)),
                        onPressed: null,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }
}
