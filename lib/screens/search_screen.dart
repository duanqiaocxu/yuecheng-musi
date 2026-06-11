import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/music_service.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MusicService _musicService = MusicService();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _results = [];
    });

    try {
      final results = await _musicService.search(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search songs...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF1DB954)),
                onPressed: _search,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error.isNotEmpty)
          Expanded(
            child: Center(
              child: Text(_error, style: const TextStyle(color: Colors.red)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final song = _results[index];
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
                  title: Text(
                    song['title'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${song['artist'] ?? 'Unknown'} - ${song['album'] ?? ''}',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          title: song['title'] ?? 'Unknown',
                          artist: song['artist'] ?? 'Unknown',
                          url: song['url'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
