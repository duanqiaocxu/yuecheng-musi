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
      return songs.map<Map<String, String>>((s) => {
        'title': s['name']?.toString() ?? 'Unknown',
        'artist': (s['artists'] as List?).let((l) => l?.map((a) => a['name']?.toString() ?? '').join(', ') ?? ''),
        'album': s['album']?['name']?.toString() ?? '',
        'url': 'netease:${s['id']}',
        'source': 'netease',
      }).toList();
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
