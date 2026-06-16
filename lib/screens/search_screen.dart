import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String _error = '';

  final List<String> _sources = ['wy', 'tx', 'kg', 'kw', 'mg'];
  final Map<String, String> _sourceNames = {
    'wy': '网易云', 'tx': 'QQ音乐', 'kg': '酷狗', 'kw': '酷我', 'mg': '咪咕'
  };

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _error = ''; _results = []; });

    for (final src in _sources) {
      try {
        final uri = Uri.parse('https://lxmusicapi.onrender.com/search/$src/$query/1/20');
        final resp = await http.get(uri, headers: {
          'Content-Type': 'application/json',
          'X-Request-Key': 'share-v3',
        }).timeout(const Duration(seconds: 10));

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data['code'] == 0 && data['data'] != null) {
            final songs = data['data'] is List ? data['data'] : (data['data']['list'] ?? []);
            if (songs is List && songs.isNotEmpty) {
              final results = <Map<String, dynamic>>[];
              for (final s in songs) {
                final id = s['songmid'] ?? s['hash'] ?? s['id']?.toString() ?? '';
                if (id.isEmpty) continue;
                results.add({
                  'title': s['name'] ?? s['songname'] ?? '',
                  'artist': s['singer'] ?? s['singername'] ?? s['artist'] ?? '',
                  'album': s['album'] ?? s['albumname'] ?? '',
                  'url': 'https://lxmusicapi.onrender.com/url/$src/$id/128k',
                  'source': _sourceNames[src] ?? src,
                  'songId': id,
                  'sourceKey': src,
                });
              }
              if (results.isNotEmpty) {
                setState(() { _results = results; _isLoading = false; });
                return;
              }
            }
          }
        }
      } catch (_) {}
    }

    // 全部失败
    setState(() {
      _error = '所有音源都无法连接，检查网络或代理设置';
      _isLoading = false;
    });
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
            suffixIcon: IconButton(icon: const Icon(Icons.send, color: Color(0xFF4080FF)), onPressed: _search),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      if (_isLoading)
        const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF4080FF))))
      else if (_error.isNotEmpty)
        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 16), textAlign: TextAlign.center),
        )))
      else
        Expanded(
          child: _results.isEmpty
            ? const Center(child: Text('Enter a song or artist name', style: TextStyle(color: Color(0xFF7799CC))))
            : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (ctx, i) {
                  final s = _results[i];
                  return ListTile(
                    leading: const Icon(Icons.music_note, color: Color(0xFF4080FF)),
                    title: Text(s['title'] ?? '', style: const TextStyle(color: Color(0xFFE8EEFF))),
                    subtitle: Text('${s['artist'] ?? ''} · ${s['source'] ?? ''}', style: const TextStyle(color: Color(0xFF7799CC))),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
                      title: s['title'] ?? '',
                      artist: s['artist'] ?? '',
                      url: s['url'] ?? '',
                      songId: s['songId'] ?? '',
                      sourceKey: s['sourceKey'] ?? '',
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
