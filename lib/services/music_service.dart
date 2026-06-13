import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
      );
      final songs = response.data?['result']?['songs'] as List? ?? [];
      final results = <Map<String, String>>[];
      for (final s in songs) {
        final id = s['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final artists = s['artists'] as List? ?? [];
        final artistNames = artists.map((a) => a['name']?.toString() ?? '').join(', ');
        results.add({
          'title': s['name']?.toString() ?? 'Unknown',
          'artist': artistNames,
          'album': s['album']?['name']?.toString() ?? '',
          'url': 'netease:$id',
          'source': 'netease',
        });
      }
      if (results.isNotEmpty) return results;
      throw Exception('No results');
    } catch (_) {
      return [
        {'title': query, 'artist': 'Demo', 'album': 'Album', 'url': 'demo', 'source': 'demo'},
        {'title': '$query (Remix)', 'artist': 'Demo', 'album': 'Album', 'url': 'demo', 'source': 'demo'},
      ];
    }
  }

  Future<String> getSongUrl(Map<String, String> song) async {
    final url = song['url'] ?? '';
    if (url == 'demo') return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    final id = url.replaceFirst('netease:', '');
    return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
  }
}
