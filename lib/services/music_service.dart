import 'dart:convert';
import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
      );
      final data = response.data;
      if (data == null || data['result'] == null) throw Exception('no result');
      final songs = data['result']['songs'] as List? ?? [];
      final List<Map<String, String>> results = [];
      for (final s in songs) {
        if (s['id'] == null) continue;
        String artist = '';
        if (s['artists'] is List) {
          for (final a in s['artists']) {
            if (artist.isNotEmpty) artist += ', ';
            artist += a['name']?.toString() ?? '';
          }
        }
        results.add({
          'title': s['name']?.toString() ?? '',
          'artist': artist,
          'album': s['album']?['name']?.toString() ?? '',
          'url': 'netease:${s['id']}',
          'source': 'netease',
        });
      }
      if (results.isNotEmpty) return results;
      throw Exception('empty');
    } catch (_) {
      return [
        {'title': query, 'artist': 'Demo', 'album': 'Album', 'url': 'demo', 'source': 'demo'},
      ];
    }
  }

  Future<String> getSongUrl(Map<String, String> song) async {
    if (song['source'] == 'demo') {
      return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    }
    final id = (song['url'] ?? '').replaceFirst('netease:', '');
    return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
  }
}
