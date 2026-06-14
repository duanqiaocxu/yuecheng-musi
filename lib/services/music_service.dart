  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://music.163.com/api/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 20, 'offset': 0},
      );
      final data = response.data;
      if (data == null || data['result'] == null) {
        return [
          {
            'title': query,
            'artist': 'Demo Artist',
            'album': '',
            'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            'source': 'demo',
          },
        ];
      }
      final songs = data['result']['songs'] as List? ?? [];
      if (songs.isEmpty) {
        return [
          {
            'title': query,
            'artist': 'Demo Artist',
            'album': '',
            'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            'source': 'demo',
          },
        ];
      }
      final List<Map<String, String>> results = [];
      for (final s in songs) {
        if (s['id'] == null) continue;
        String artist = '';
        if (s['artists'] is List && (s['artists'] as List).isNotEmpty) {
          for (final a in s['artists']) {
            if (artist.isNotEmpty) artist += ' / ';
            artist += a['name']?.toString() ?? '';
          }
        }
        results.add({
          'title': s['name']?.toString() ?? 'Unknown',
          'artist': artist.isNotEmpty ? artist : 'Unknown Artist',
          'album': s['album']?['name']?.toString() ?? '',
          'url': 'netease:${s['id']}',
          'source': 'netease',
        });
      }
      if (results.isEmpty) {
        return [
          {
            'title': query,
            'artist': 'Demo',
            'album': '',
            'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
            'source': 'demo',
          },
        ];
      }
      return results;
    } catch (e) {
      return [
        {
          'title': query,
          'artist': 'Demo Artist',
          'album': '',
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'source': 'demo',
        },
      ];
    }
  }
