import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
      );
      final data = response.data;
      if (data == null || data['result'] == null) {
        throw Exception('No results');
      }
      final songs = data['result']['songs'] as List? ?? [];
      final results = <Map<String, String>>[];
      for (final s in songs) {
        final id = s['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        String artist = '';
        if (s['artists'] is List) {
          artist = (s['artists'] as List).map((a) => a['name']?.toString() ?? '').join(', ');
        }
        results.add({
          'title': s['name']?.toString() ?? 'Unknown',
          'artist': artist,
          'album': s['album']?['name']?.toString() ?? '',
          'url': 'netease:$id',
          'source': 'netease',
        });
      }
      if (results.isNotEmpty) return results;
      throw Exception('No results');
    } catch (e) {
      return [
        {'title': query, 'artist': 'Demo', 'album': 'Album', 'url': 'demo', 'source': 'demo'},
      ];
    }
  }

  Future<String> getSongUrl(Map<String, String> song) async {
    if (song['source'] == 'demo') return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    final id = (song['url'] ?? '').replaceFirst('netease:', '');
    return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
  }
}
