import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _error = ''; _results = []; });

    try {
      // QQ音乐搜索
      final response = await _dio.get(
        'https://c.y.qq.com/soso/fcgi-bin/client_search_cp',
        queryParameters: {'w': query, 'p': 1, 'n': 20, 'format': 'json'},
      );
      final songList = response.data?['data']?['song']?['list'] as List? ?? [];
      if (songList.isEmpty) throw Exception('No results');

      final List<Map<String, String>> results = [];
      for (final s in songList) {
        String artist = '';
        if (s['singer'] is List) {
          for (int i = 0; i < (s['singer'] as List).length; i++) {
            if (i > 0) artist += ', ';
            artist += (s['singer'] as List)[i]['name']?.toString() ?? '';
          }
        }
        results.add({
          'title': s['songname']?.toString() ?? '',
          'artist': artist,
          'album': s['albumname']?.toString() ?? '',
        });
      }
      setState(() { _results = results; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Search failed'; _isLoading = false; });
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
                subtitle: Text(s['artist'] ?? '', style: const TextStyle(color: Color(0xFF7799CC))),
              );
            },
          ),
        ),
    ]);
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }
}
