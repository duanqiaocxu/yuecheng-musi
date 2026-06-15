import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio();

  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
      );
      final data = response.data;
      if (data != null && data['result'] != null) {
        final songs = data['result']['songs'] as List? ?? [];
        final results = <Map<String, String>>[];
        for (final s in songs) {
          if (s['id'] == null) continue;
          String artist = '';
          if (s['artists'] is List) {
            for (int i = 0; i < (s['artists'] as List).length; i++) {
              if (i > 0) artist += ', ';
              artist += (s['artists'] as List)[i]['name']?.toString() ?? '';
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
      }
    } catch (_) {}
    return [{'title': query, 'artist': 'Demo', 'album': 'Album', 'url': 'demo', 'source': 'demo'}];
  }

  Future<String> getSongUrl(Map<String, String> song) async {
    if (song['source'] == 'demo') return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    final id = (song['url'] ?? '').replaceFirst('netease:', '');
    return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
  }
}
