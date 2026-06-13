import 'package:dio/dio.dart';

class MusicService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'User-Agent': 'YueC/1.0',
    },
  ));

  /// 搜索结果
  Future<List<Map<String, String>>> search(String query) async {
    // 尝试多个音源，第一个成功的返回
    try {
      return await _searchNetease(query);
    } catch (_) {}
    try {
      return await _searchQQ(query);
    } catch (_) {}
    return _getDemoResults(query);
  }

  /// 网易云音乐搜索
  Future<List<Map<String, String>>> _searchNetease(String query) async {
    final response = await _dio.get(
      'https://music.163.com/api/search/get',
      queryParameters: {
        's': query,
        'type': 1,
        'limit': 20,
        'offset': 0,
      },
    );

    final data = response.data;
    if (data == null || data['result'] == null) {
      throw Exception('No results from Netease');
    }

    final songs = data['result']['songs'] as List? ?? [];
    final results = <Map<String, String>>[];

    for (final song in songs) {
      final id = song['id']?.toString() ?? '';
      if (id.isEmpty) continue;

      results.add({
        'title': song['name']?.toString() ?? 'Unknown',
        'artist': (song['artists'] as List? ?? [])
            .map((a) => a['name']?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .join(', '),
        'album': song['album']?['name']?.toString() ?? '',
        'url': 'netease:$id',
        'source': 'netease',
      });
    }

    if (results.isEmpty) throw Exception('No results');
    return results;
  }

  /// QQ音乐搜索
  Future<List<Map<String, String>>> _searchQQ(String query) async {
    final response = await _dio.get(
      'https://c.y.qq.com/soso/fcgi-bin/client_search_cp',
      queryParameters: {
        'w': query,
        'p': 1,
        'n': 20,
        'format': 'json',
      },
    );

    final data = response.data;
    if (data == null || data['data']?['song']?['list'] == null) {
      throw Exception('No results from QQ Music');
    }

    final songs = data['data']['song']['list'] as List? ?? [];
    final results = <Map<String, String>>[];

    for (final song in songs) {
      final mid = song['songmid']?.toString() ?? '';
      if (mid.isEmpty) continue;

      results.add({
        'title': song['songname']?.toString() ?? 'Unknown',
        'artist': (song['singer'] as List? ?? [])
            .map((s) => s['name']?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .join(', '),
        'album': song['albumname']?.toString() ?? '',
        'url': 'qq:$mid',
        'source': 'qq',
      });
    }

    if (results.isEmpty) throw Exception('No results');
    return results;
  }

  /// 获取歌曲播放URL
  Future<String> getSongUrl(Map<String, String> song) async {
    final url = song['url'] ?? '';
    final source = song['source'] ?? '';

    if (url.contains('soundhelix.com')) {
      return url;
    }

    if (source == 'netease') {
      final id = url.replaceFirst('netease:', '');
      try {
        final response = await _dio.get(
          'https://music.163.com/song/media/outer/url?id=$id.mp3',
          options: Options(
            followRedirects: false,
            validateStatus: (s) => s! < 400,
          ),
        );
        // 网易云返回重定向到真实CDN地址
        final realUrl = response.headers.value('location') ?? '';
        if (realUrl.isNotEmpty) return realUrl;
      } catch (_) {}
      // 备选：直接返回标准格式
      return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
    }

    if (source == 'qq') {
      final mid = url.replaceFirst('qq:', '');
      try {
        final response = await _dio.get(
          'https://u.y.qq.com/cgi-bin/musicu.fcg',
          queryParameters: {
            'format': 'json',
            'data': '{"req":{"module":"CDN.SrfCdnDispatchServer","method":"GetCdnDispatch","param":{"guid":"1234567890","calltype":0,"userip":""}},"req_0":{"module":"vkey.GetVkeyServer","method":"CgiGetVkey","param":{"guid":"1234567890","songmid":["$mid"],"songtype":[0],"uin":"0","loginflag":0,"platform":"20"}}}',
          },
        );
        final data = response.data;
        final purl = data?['req_0']?['data']?['midurlinfo']?[0]?['purl']?.toString() ?? '';
        if (purl.isNotEmpty) {
          return 'https://isure.stream.qqmusic.qq.com/$purl';
        }
      } catch (_) {}
      return 'https://y.qq.com/n/ryqq/songDetail/$mid';
    }

    // 默认返回 demo
    return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  }

  List<Map<String, String>> _getDemoResults(String query) {
    return [
      {
        'title': query,
        'artist': 'Demo Artist',
        'album': 'Demo Album',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        'source': 'demo',
      },
      {
        'title': '$query (Remix)',
        'artist': 'Demo Artist',
        'album': 'Remixes',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        'source': 'demo',
      },
    ];
  }
}
