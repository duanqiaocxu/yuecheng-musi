import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Map<String, String>>> search(String query) async {
    try {
      return await _searchLxMusic(query);
    } catch (e) {
      return _getDemoResults(query);
    }
  }

  Future<List<Map<String, String>>> _searchLxMusic(String query) async {
    final response = await _dio.get(
      'https://api.music.example.com/search',
      queryParameters: {'q': query, 'limit': '20'},
    );
    final results = <Map<String, String>>[];
    return results;
  }

  List<Map<String, String>> _getDemoResults(String query) {
    return [
      {
        'title': query,
        'artist': 'Demo Artist',
        'album': 'Demo Album',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      },
      {
        'title': '$query (Remix)',
        'artist': 'Demo Artist',
        'album': 'Remixes',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      },
    ];
  }
}
