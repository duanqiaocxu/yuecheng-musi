import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// 播放源解析器接口。
///
/// 把"如何拿到一个 songId 对应的真实可播放 URL"这件事单独抽出来，
/// 方便你接入自己的合法音频源（自有服务器 / 已授权 API）而不用改动播放页面的其他逻辑。
///
/// 用法：在 main.dart 或依赖注入处，把 PlayerScreen.resolver 设置成你自己的实现：
///   PlayerScreen.resolver = MyOwnSourceResolver();
abstract class SongUrlResolver {
  /// 根据 songId 返回一个可直接播放的音频 URL。
  /// 解析失败时应抛出异常（不要返回空字符串），方便上层统一捕获处理。
  Future<String> resolve(String songId);
}

/// 默认实现：占位符，未配置真实播放源时会明确报错，而不是静默失败或播放空音频。
class _UnconfiguredResolver implements SongUrlResolver {
  @override
  Future<String> resolve(String songId) async {
    throw Exception('尚未配置播放源（SongUrlResolver），请在 main.dart 中设置 PlayerScreen.resolver');
  }
}

class PlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String songId;

  /// 全局播放源解析器，启动时由调用方注入。
  static SongUrlResolver resolver = _UnconfiguredResolver();

  const PlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

enum _PlayState { loading, playing, paused, error }

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  _PlayState _state = _PlayState.loading;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _listenToPlayerState();
    _start();
  }

  void _listenToPlayerState() {
    // 监听底层播放器状态变化（缓冲失败、播放完成等），而不是只在发起播放那一刻判断成功与否。
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      switch (state) {
        case PlayerState.playing:
          setState(() => _state = _PlayState.playing);
          break;
        case PlayerState.paused:
          setState(() => _state = _PlayState.paused);
          break;
        case PlayerState.completed:
          setState(() => _state = _PlayState.paused);
          break;
        case PlayerState.stopped:
        case PlayerState.disposed:
          break;
      }
    });

    // audioplayers 在底层播放失败（如 URL 404 / 解码失败）时会通过这个流上报，
    // 之前的实现完全没有监听它，导致播放失败时界面没有任何反馈。
    _player.onLog.listen((msg) {
      // 仅用于调试排查，不在界面上展示原始日志。
      debugPrint('[AudioPlayer] $msg');
    });
  }

  Future<void> _start() async {
    setState(() {
      _state = _PlayState.loading;
      _error = '';
    });

    try {
      final url = await PlayerScreen.resolver.resolve(widget.songId);

      if (url.isEmpty) {
        throw Exception('播放源返回了空地址');
      }

      await _player.play(UrlSource(url));

      if (!mounted) return;
      setState(() => _state = _PlayState.playing);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _PlayState.error;
        _error = '播放失败：$e';
      });
    }
  }

  void _togglePlayPause() {
    if (_state == _PlayState.playing) {
      _player.pause();
    } else if (_state == _PlayState.paused) {
      _player.resume();
    } else if (_state == _PlayState.error) {
      // 出错后允许用户手动重试，而不是卡死在错误页面。
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1535),
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_state == _PlayState.loading) {
      return const CircularProgressIndicator(color: Color(0xFF4080FF));
    }

    if (_state == _PlayState.error) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final isPlaying = _state == _PlayState.playing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.music_note, size: 120, color: Color(0xFF4080FF)),
        const SizedBox(height: 32),
        Text(widget.title, style: const TextStyle(color: Color(0xFFE8EEFF), fontSize: 24)),
        const SizedBox(height: 8),
        Text(widget.artist, style: const TextStyle(color: Color(0xFF7799CC), fontSize: 18)),
        const SizedBox(height: 48),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 72,
            color: const Color(0xFF4080FF),
          ),
          onPressed: _togglePlayPause,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
