import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String url;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.url,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
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
        setState(() => _position = pos);
      });
      _player.durationStream.listen((dur) {
        setState(() => _duration = dur ?? Duration.zero);
      });
      _player.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading;
        });
      });

      await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.url)));
      await _player.play();
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Playback failed: $e';
        _isLoading = false;
      });
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 80,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
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
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF1DB954),
                              inactiveTrackColor: Colors.grey[800],
                              thumbColor: const Color(0xFF1DB954),
                              overlayColor: const Color(0x291DB954),
                            ),
                            child: Slider(
                              value: _duration.inMilliseconds > 0
                                  ? _position.inMilliseconds
                                      .toDouble()
                                      .clamp(0, _duration.inMilliseconds.toDouble())
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
                                Text(
                                  _formatDuration(_position),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
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
                            icon: const Icon(Icons.skip_previous, size: 40),
                            color: Colors.white,
                            onPressed: () {},
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DB954),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 48,
                              ),
                              color: Colors.black,
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
                            icon: const Icon(Icons.skip_next, size: 40),
                            color: Colors.white,
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
