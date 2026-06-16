import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String url;
  final String songId;
  final String sourceKey;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.url,
    this.songId = '',
    this.sourceKey = '',
  });
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();
  bool _isPlaying = false;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      String playUrl = widget.url;

      // 如果不是demo，尝试获取真实播放URL
      if (widget.sourceKey.isNotEmpty && widget.songId.isNotEmpty) {
        try {
          final resp = await _dio.get(
            'https://lxmusicapi.onrender.com/url/${widget.sourceKey}/${widget.songId}/128k',
            options: Options(headers: {'X-Request-Key': 'share-v3'}),
          );
          if (resp.data != null && resp.data['code'] == 0 && resp.data['url'] != null) {
            playUrl = resp.data['url'].toString();
          }
        } catch (_) {}
      }

      await _player.play(UrlSource(playUrl));
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
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error, style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
                ]),
              )
            : Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.music_note, size: 120, color: Color(0xFF4080FF)),
                const SizedBox(height: 32),
                Text(widget.title, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 24)),
                const SizedBox(height: 8),
                Text(widget.artist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 18)),
                const SizedBox(height: 48),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 72, color: const Color(0xFF4080FF)),
                  onPressed: () {
                    if (_isPlaying) { _player.pause(); setState(() => _isPlaying = false); }
                    else { _player.resume(); setState(() => _isPlaying = true); }
                  },
                ),
              ]),
      ),
    );
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }
}
