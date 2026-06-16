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
    setState(() { _isLoading = true; _error = ''; });

    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
        options: Options(headers: {
          'User-Agent': 'Mozilla/5.0',
          'Referer': 'https://music.163.com/',
        }),
      );
      final songs = response.data?['result']?['songs'] as List? ?? [];
      final results = <Map<String, String>>[];
      for (final s in songs) {
        if (s['id'] == null) continue;
        String artist = '';
        if (s['ar'] is List) {
          for (int i = 0; i < (s['ar'] as List).length; i++) {
            if (i > 0) artist += ' / ';
            artist += (s['ar'] as List)[i]['name']?.toString() ?? '';
          }
        }
        String album = '';
        if (s['al'] is Map) {
          album = (s['al'] as Map)['name']?.toString() ?? '';
        }
        results.add({
          'title': s['name']?.toString() ?? '',
          'artist': artist,
          'album': album,
          'url': 'https://music.163.com/song/media/outer/url?id=${s['id']}.mp3',
        });
      }
      if (results.isEmpty) throw Exception('no');
      setState(() { _results = results; _isLoading = false; });
    } catch (e) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = 'Search failed';
      });
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
                subtitle: Text('${s['artist'] ?? ''} · ${s['album'] ?? ''}', style: const TextStyle(color: Color(0xFF7799CC))),
              );
            },
          ),
        ),
    ]);
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }
}
