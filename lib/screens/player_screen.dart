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

      // Get real playable URL
      final realUrl = await _musicService.getSongUrl(widget.songData);
      if (realUrl.isEmpty) throw Exception('Could not get song URL');

      await _player.setAudioSource(AudioSource.uri(Uri.parse(realUrl)));
      await _player.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Playback failed: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1535),
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4080FF)))
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Album art placeholder
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A3060), Color(0xFF3A40A0)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF4A50C0)),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 80,
                          color: Color(0xFF4080FF),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFFE8EEFF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.artist,
                        style: const TextStyle(
                          color: Color(0xFF7799CC),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF4080FF),
                              inactiveTrackColor: const Color(0xFF2A3060),
                              thumbColor: const Color(0xFF4080FF),
                              overlayColor: const Color(0x294080FF),
                            ),
                            child: Slider(
                              value: _duration.inMilliseconds > 0
                                  ? _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble())
                                  : 0,
                              max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                              onChanged: (v) {
                                _player.seek(Duration(milliseconds: v.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(_position), style: const TextStyle(color: Color(0xFF5566AA), fontSize: 12)),
                                Text(_formatDuration(_duration), style: const TextStyle(color: Color(0xFF5566AA), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous, size: 40, color: Color(0xFFE8EEFF)),
                            onPressed: () {},
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF4080FF), Color(0xFF6060FF)]),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: Color(0x404080FF), blurRadius: 20, spreadRadius: 2),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 48,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (_isPlaying) {
                                  _player.pause();
                                } else {
                                  _player.play();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next, size: 40, color: Color(0xFFE8EEFF)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
