  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
      );
      final data = response.data;
      if (data != null && data['result'] != null && data['result']['songs'] is List) {
        final songs = data['result']['songs'] as List;
        if (songs.isNotEmpty) {
          final List<Map<String, String>> results = [];
          for (final s in songs) {
            if (s['id'] == null) continue;
            String artist = '';
            if (s['artists'] is List) {
              for (final a in s['artists']) {
                if (artist.isNotEmpty) artist += ' / ';
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
        }
      }
    } catch (_) {}
    return [
      {'title': query, 'artist': 'YueC Demo', 'album': '', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'source': 'demo'},
      {'title': 'Test Song', 'artist': 'YueC Demo', 'album': '', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 'source': 'demo'},
      {'title': 'Sample Track', 'artist': 'YueC Demo', 'album': '', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', 'source': 'demo'},
    ];
  }
