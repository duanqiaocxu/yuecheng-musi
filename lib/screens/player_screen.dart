import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String songId;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
  });
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
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
      // 手动获取302重定向后的真实MP3地址
      final uri = Uri.parse('https://music.163.com/song/media/outer/url?id=${widget.songId}.mp3');
      final resp = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
        'Referer': 'https://music.163.com/',
      }).timeout(const Duration(seconds: 10));

      // 获取重定向后的最终URL
      Uri realUrl = uri;
      if (resp.statusCode == 302 || resp.statusCode == 301) {
        final location = resp.headers['location'];
        if (location != null && location.isNotEmpty) {
          realUrl = Uri.parse(location);
        }
      }

      await _player.play(UrlSource(realUrl.toString()));
      if (mounted) setState(() { _isPlaying = true; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '播放失败：$e'; _isLoading = false; });
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
