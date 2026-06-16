import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'player_screen.dart';

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

  static const String API_URL = 'https://lxmusicapi.onrender.com';

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _error = ''; _results = []; });

    // 尝试5个音源：网易云(wy), QQ(tx), 酷狗(kg), 酷我(kw), 咪咕(mg)
    final sources = ['wy', 'tx', 'kg', 'kw', 'mg'];
    final sourceNames = {'wy': '网易云', 'tx': 'QQ音乐', 'kg': '酷狗', 'kw': '酷我', 'mg': '咪咕'};

    for (final src in sources) {
      try {
        final response = await _dio.get(
          '$API_URL/search/$src/$query/1/20',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'X-Request-Key': 'share-v3',
          }),
        );
        final data = response.data;
        if (data != null && data['code'] == 0 && data['data'] != null) {
          final songs = data['data'] is List ? data['data'] : (data['data']['list'] ?? []);
          if (songs is List && songs.isNotEmpty) {
            final results = <Map<String, String>>[];
            for (final s in songs) {
              final id = s['songmid'] ?? s['hash'] ?? s['id']?.toString() ?? '';
              if (id.isEmpty) continue;
              results.add({
                'title': s['name']?.toString() ?? s['songname']?.toString() ?? '',
                'artist': s['singer']?.toString() ?? s['singername']?.toString() ?? s['artist']?.toString() ?? '',
                'album': s['album']?.toString() ?? s['albumname']?.toString() ?? '',
                'url': '$API_URL/url/$src/$id/128k',
                'source': sourceNames[src] ?? src,
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
      } catch (_) {}
    }

    // 全部失败，用demo
    setState(() {
      _results = [
        {'title': query, 'artist': 'Demo', 'album': '', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'source': 'demo', 'songId': '', 'sourceKey': ''},
      ];
      _isLoading = false;
      _error = '无法连接音源，显示Demo';
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
      else
        Expanded(
          child: _results.isEmpty
            ? const Center(child: Text('No results', style: TextStyle(color: Color(0xFF7799CC))))
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
