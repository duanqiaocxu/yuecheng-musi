import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final Map<String, String> songData;
  const PlayerScreen({super.key, required this.title, required this.artist, required this.songData});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  final MusicService _musicService = MusicService();
  bool _isPlaying = false;
  bool _isLoading = true;
  String _error = '';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() { super.initState(); _initPlayer(); }

  Future<void> _initPlayer() async {
    try {
      _player.positionStream.listen((pos) { if (mounted) setState(() => _position = pos); });
      _player.durationStream.listen((dur) { if (mounted) setState(() => _duration = dur ?? Duration.zero); });
      _player.playerStateStream.listen((state) {
        if (mounted) setState(() { _isPlaying = state.playing; _isLoading = state.processingState == ProcessingState.loading; });
      });
      final realUrl = await _musicService.getSongUrl(widget.songData);
      if (realUrl.isEmpty) throw Exception('no url');
      await _player.setAudioSource(AudioSource.uri(Uri.parse(realUrl)));
      await _player.play();
      if (mounted) setState(() { _isPlaying = true; _isLoading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  String _fmt(Duration d) { final m = (d.inMinutes % 60).toString().padLeft(2, '0'); final s = (d.inSeconds % 60).toString().padLeft(2, '0'); return '$m:$s'; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1535),
      appBar: AppBar(title: const Text('Now Playing'), backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF4080FF)))
        : _error.isNotEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center)))
          : Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 80),
                const Icon(Icons.music_note, size: 100, color: Color(0xFF4080FF)),
                const SizedBox(height: 24),
                Text(widget.title, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(widget.artist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 16)),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(icon: const Icon(Icons.skip_previous, size: 40, color: Color(0xFFE8EEFF)), onPressed: () {}),
                  Container(
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4080FF), Color(0xFF6060FF)]), shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 48, color: Colors.white),
                      onPressed: () { if (_isPlaying) _player.pause(); else _player.play(); },
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.skip_next, size: 40, color: Color(0xFFE8EEFF)), onPressed: () {}),
                ]),
              ]),
            ),
    );
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }
}
