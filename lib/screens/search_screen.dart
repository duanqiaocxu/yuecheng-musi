import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/music_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _musicService = MusicService();
  final _player = AudioPlayer();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  bool _isPlaying = false;
  bool _isPlayerLoading = false;
  String _error = '';
  String _currentTitle = '';
  String _currentArtist = '';

  Future<void> _search() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() { _isLoading = true; _error = ''; _results = []; });
    try {
      final r = await _musicService.search(q);
      setState(() { _results = r; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _play(String title, String artist, Map<String, String> data) async {
    setState(() { _isPlayerLoading = true; _currentTitle = title; _currentArtist = artist; });
    try {
      final url = await _musicService.getSongUrl(data);
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _player.play();
      setState(() { _isPlaying = true; _isPlayerLoading = false; });
    } catch (e) {
      setState(() { _error = 'Playback failed: $e'; _isPlayerLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Color(0xFFE8EEFF)),
          decoration: InputDecoration(
            hintText: 'Search songs...',
            hintStyle: const TextStyle(color: Color(0xFF7799CC)),
            filled: true, fillColor: const Color(0xFF1A1F4E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF7799CC)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF4080FF)),
              onPressed: _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      if (_isLoading)
        const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF4080FF))))
      else if (_error.isNotEmpty && !_isPlayerLoading)
        Expanded(child: Center(child: Text(_error, style: const TextStyle(color: Colors.red))))
      else
        Expanded(child: ListView.builder(itemCount: _results.length + (_currentTitle.isNotEmpty ? 1 : 0), itemBuilder: (ctx, i) {
          if (_currentTitle.isNotEmpty && i == 0) {
            return Card(
              color: const Color(0xFF1A1F4E),
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  const Icon(Icons.music_note, size: 48, color: Color(0xFF4080FF)),
                  const SizedBox(height: 8),
                  Text(_currentTitle, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_currentArtist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 14)),
                  const SizedBox(height: 8),
                  _isPlayerLoading
                    ? const CircularProgressIndicator(color: Color(0xFF4080FF))
                    : IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 48, color: const Color(0xFF4080FF)),
                        onPressed: () { if (_isPlaying) { _player.pause(); setState(() => _isPlaying = false); } else { _player.play(); setState(() => _isPlaying = true); } },
                      ),
                ]),
              ),
            );
          }
          final idx = _currentTitle.isNotEmpty ? i - 1 : i;
          final s = _results[idx];
          return ListTile(
            leading: const Icon(Icons.music_note, color: Color(0xFF4080FF)),
            title: Text(s['title'] ?? '', style: const TextStyle(color: Color(0xFFE8EEFF))),
            subtitle: Text('${s['artist'] ?? ''}', style: const TextStyle(color: Color(0xFF7799CC))),
            onTap: () => _play(s['title'] ?? '', s['artist'] ?? '', s),
          );
        })),
    ]);
  }

  @override
  void dispose() { _searchController.dispose(); _player.dispose(); super.dispose(); }
}
