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
    setState(() { _isLoading = true; _error = ''; _results = []; });
    try {
      final results = await _musicService.search(query);
      setState(() { _results = results; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Search failed: $e'; _isLoading = false; });
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
        const Expanded(child: Center(child: CircularProgressIndicator()))
      else if (_error.isNotEmpty)
        Expanded(child: Center(child: Text(_error, style: const TextStyle(color: Colors.red))))
      else
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (ctx, i) {
              final s = _results[i];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Color(0xFF4080FF)),
                title: Text(s['title'] ?? '', style: const TextStyle(color: Color(0xFFE8EEFF))),
                subtitle: Text('${s['artist'] ?? ''} - ${s['album'] ?? ''}', style: const TextStyle(color: Color(0xFF7799CC))),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
                  title: s['title'] ?? '', artist: s['artist'] ?? '', url: s['url'] ?? '',
                ))),
              );
            },
          ),
        ),
    ]);
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }
}
