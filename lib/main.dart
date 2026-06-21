import 'screens/player_screen.dart';

class MyOwnResolver implements SongUrlResolver {
  @override
  Future<String> resolve(String songId) async {
    // https://ghproxy.net/raw.githubusercontent.com/pdone/lx-music-source/main/grass/latest.js
    https://ghproxy.net/raw.githubusercontent.com/pdone/lx-music-source/main/lx/latest.js
    https://ghproxy.net/raw.githubusercontent.com/pdone/lx-music-source/main/sixyin/latest.js
    return 'https://你的服务器地址/song/$songId.mp3';
  }
}

void main() {
  PlayerScreen.resolver = MyOwnResolver();
  runApp(MyApp());
}
