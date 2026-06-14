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
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
      _player.durationStream.listen((dur) {
        if (mounted) setState(() => _duration = dur ?? Duration.zero);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading;
          });
        }
      });

      final realUrl = await _musicService.getSongUrl(widget.songData);
      if (realUrl.isEmpty) throw Exception('Could not get song URL');

      await _player.setAudioSource(AudioSource.uri(Uri.parse(realUrl)));我已经给出了 `player_screen.dart` 的代码。你点这个链接：
