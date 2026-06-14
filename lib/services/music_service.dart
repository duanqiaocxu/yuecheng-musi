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
      if (data == null || data['result'] == null) {
        throw Exception('no result');
      }
      final songs = data['result']['songs'] as List? ?? [];
      if (songs.isEmpty) {
        throw Exception('empty');
      }
      final List<Map<String, String>> results = [];
      for (final s in songs) {
        if (s['id'] == null) continue;
        String artist = '';
        if (s['artists'] is List) {
          final artists = s['artists'] as List;
          for (int i = 0; i < artists.length; i++) {
            if (i > 0) artist += ', ';
            artist += artists[i]['name']?.toString() ?? '';
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
      throw Exception('no results');
    } catch (e) {
      return [
        {
          'title': query,
          'artist': 'Demo Artist',
          'album': 'Demo Album',
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'source': 'demo',
        },
      ];
    }
  }

  Future<String> getSongUrl(Map<String, String> song) async {
    if (song['source'] == 'demo') {
      return song['url'] ?? 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    }
    if (song['source'] == 'netease') {
      final id = (song['url'] ?? '').replaceFirst('netease:', '');
      return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
    }
    return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  }
}
