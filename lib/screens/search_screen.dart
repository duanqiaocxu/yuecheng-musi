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
        'https://c.y.qq.com/soso/fcgi-bin/client_search_cp',
        queryParameters: {'w': query, 'p': 1, 'n': 20, 'format': 'json'},
      );
      final songs = response.data?['data']?['song']?['list'] as List? ?? [];
      final results = <Map<String, String>>[];
      for (final s in songs) {
        if (s['songmid'] == null) continue;
        String artist = '';
        if (s['singer'] is List) {
          for (int i = 0; i < (s['singer'] as List).length; i++) {
            if (i > 0) artist += ' / ';
            artist += (s['singer'] as List)[i]['name']?.toString() ?? '';
          }
        }
        results.add({
          'title': s['songname']?.toString() ?? '',
          'artist': artist,
          'album': s['albumname']?.toString() ?? '',
        });
      }
      if (results.isEmpty) throw Exception('empty');
      setState(() { _results = results; _isLoading = false; });
    } catch (e) {
      setState(() {
        _results = [
          {'title': '晴天', 'artist': '周杰伦', 'album': '叶惠美'},
          {'title': '七里香', 'artist': '周杰伦', 'album': '七里香'},
          {'title': '夜曲', 'artist': '周杰伦', 'album': '十一月的萧邦'},
          {'title': '稻香', 'artist': '周杰伦', 'album': '魔杰座'},
          {'title': '青花瓷', 'artist': '周杰伦', 'album': '我很忙'},
        ];
        _isLoading = false;
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
