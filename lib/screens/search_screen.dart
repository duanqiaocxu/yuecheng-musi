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

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; _error = ''; _results = []; });

    try {
      final uri = Uri.parse('https://music.163.com/api/search/get')
          .replace(queryParameters: {'s': query, 'type': 1, 'limit': 30, 'offset': 0});
      final resp = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 14; HarmonyOS) AppleWebKit/537.36',
        'Referer': 'https://music.163.com/',
        'Cookie': 'appver=1.5.2; os=android;',
      }).timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        setState(() { _error = '网络错误：${resp.statusCode}'; _isLoading = false; });
        return;
      }

      final Map<String, dynamic> data = jsonDecode(resp.body);
      if (data['code'] != 200) {
        setState(() { _error = '搜索服务异常'; _isLoading = false; });
        return;
      }

      final result = data['result'];
      if (result == null || result is! Map) {
        setState(() { _error = '搜索无返回'; _isLoading = false; });
        return;
      }

      final songs = result['songs'];
      if (songs == null || songs is! List) {
        setState(() { _error = '未找到相关歌曲'; _isLoading = false; });
        return;
      }

      final results = <Map<String, dynamic>>[];
      for (final s in songs) {
        if (s is! Map || s['id'] == null || s['name'] == null) continue;
        try {
          String artist = '';
          final artists = s['artists'];
          if (artists is List) {
            final names = <String>[];
            for (final a in artists) {
              if (a is Map && a['name'] is String) {
                names.add(a['name']);
              }
            }
            artist = names.join(' / ');
          }
          String album = '';
          if (s['album'] is Map && s['album']['name'] is String) {
            album = s['album']['name'];
          }
          results.add({
            'title': s['name'].toString(),
            'artist': artist,
            'album': album,
            'songId': s['id'].toString(),
          });
        } catch (_) {
          continue;
        }
      }

      if (results.isEmpty) {
        setState(() { _error = '未找到相关歌曲'; _isLoading = false; });
      } else {
        setState(() { _results = results; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = '搜索失败：$e'; _isLoading = false; });
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
                    subtitle: Text(s['artist'] ?? '', style: const TextStyle(color: Color(0xFF7799CC))),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
                      title: s['title'] ?? '',
                      artist: s['artist'] ?? '',
                      songId: s['songId'] ?? '',
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
