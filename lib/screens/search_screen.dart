import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;

  final List<Map<String, String>> _allSongs = [
    {'title': '晴天', 'artist': '周杰伦', 'album': '叶惠美'},
    {'title': '七里香', 'artist': '周杰伦', 'album': '七里香'},
    {'title': '夜曲', 'artist': '周杰伦', 'album': '十一月的萧邦'},
    {'title': '稻香', 'artist': '周杰伦', 'album': '魔杰座'},
    {'title': '青花瓷', 'artist': '周杰伦', 'album': '我很忙'},
    {'title': '简单爱', 'artist': '周杰伦', 'album': '范特西'},
    {'title': '发如雪', 'artist': '周杰伦', 'album': '十一月的萧邦'},
    {'title': '一路向北', 'artist': '周杰伦', 'album': '头文字D'},
    {'title': '告白气球', 'artist': '周杰伦', 'album': '周杰伦的床边故事'},
    {'title': '等你下课', 'artist': '周杰伦', 'album': '等你下课'},
    {'title': '起风了', 'artist': '买辣椒也用券', 'album': '起风了'},
    {'title': '光年之外', 'artist': '邓紫棋', 'album': '光年之外'},
    {'title': '泡沫', 'artist': '邓紫棋', 'album': 'Xposed'},
    {'title': '后来', 'artist': '刘若英', 'album': '我等你'},
    {'title': '蓝莲花', 'artist': '许巍', 'album': '时光·漫步'},
    {'title': '平凡之路', 'artist': '朴树', 'album': '猎户星座'},
    {'title': '演员', 'artist': '薛之谦', 'album': '绅士'},
    {'title': '年少有为', 'artist': '李荣浩', 'album': '耳朵'},
    {'title': '倒数', 'artist': '邓紫棋', 'album': '童话的休止符'},
    {'title': '李白', 'artist': '李荣浩', 'album': '模特'},
    {'title': '像我这样的人', 'artist': '毛不易', 'album': '平凡的一天'},
    {'title': '消愁', 'artist': '毛不易', 'album': '平凡的一天'},
    {'title': '成都', 'artist': '赵雷', 'album': '无法长大'},
    {'title': '南山南', 'artist': '马頔', 'album': '孤岛'},
    {'title': '认真的雪', 'artist': '薛之谦', 'album': '薛之谦'},
    {'title': '体面', 'artist': '于文文', 'album': '体面'},
    {'title': '刚好遇见你', 'artist': '李玉刚', 'album': '刚好遇见你'},
    {'title': '凉凉', 'artist': '杨宗纬/张碧晨', 'album': '三生三世十里桃花'},
    {'title': '追光者', 'artist': '岑宁儿', 'album': '追光者'},
    {'title': '学猫叫', 'artist': '小潘潘/小峰峰', 'album': '学猫叫'},
    {'title': '纸短情长', 'artist': '烟把儿', 'album': '纸短情长'},
    {'title': '沙漠骆驼', 'artist': '展展与罗罗', 'album': '沙漠骆驼'},
    {'title': '可能否', 'artist': '木小雅', 'album': '可能否'},
    {'title': '答案', 'artist': '杨坤/郭采洁', 'album': '答案'},
    {'title': '时间煮雨', 'artist': '郁可唯', 'album': '小时代'},
    {'title': '明天你好', 'artist': '牛奶咖啡', 'album': '去寻找'},
    {'title': '你曾是少年', 'artist': 'S.H.E', 'album': '你曾是少年'},
    {'title': '老男孩', 'artist': '筷子兄弟', 'album': '父亲'},
    {'title': '父亲', 'artist': '筷子兄弟', 'album': '父亲'},
    {'title': '匆匆那年', 'artist': '王菲', 'album': '匆匆那年'},
    {'title': '因为爱情', 'artist': '陈奕迅/王菲', 'album': 'Stranger Under My Skin'},
    {'title': '十年', 'artist': '陈奕迅', 'album': '黑白灰'},
    {'title': '富士山下', 'artist': '陈奕迅', 'album': 'What\'s Going On...?'},
    {'title': '好久不见', 'artist': '陈奕迅', 'album': '认了吧'},
    {'title': '浮夸', 'artist': '陈奕迅', 'album': 'U87'},
    {'title': '红玫瑰', 'artist': '陈奕迅', 'album': '认了吧'},
    {'title': '海阔天空', 'artist': 'Beyond', 'album': '海阔天空'},
    {'title': '光辉岁月', 'artist': 'Beyond', 'album': '命运派对'},
    {'title': '真的爱你', 'artist': 'Beyond', 'album': 'Beyond IV'},
    {'title': '喜欢你', 'artist': 'Beyond', 'album': '秘密警察'},
  ];

  Future<void> _search() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;
    setState(() { _isLoading = true; });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _results = _allSongs.where((s) {
        final title = (s['title'] ?? '').toLowerCase();
        final artist = (s['artist'] ?? '').toLowerCase();
        return title.contains(query) || artist.contains(query);
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Color(0xFFE8EEFF)),
          decoration: InputDecoration(
            hintText: 'Search songs...',
            hintStyle: const TextStyle(color: Color(0xFF7799CC)),
            filled: true, fillColor: const Color(0xFF1A1F4E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF7799CC)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF4080FF)),
              onPressed: _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      if (_isLoading)
        const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF4080FF))))
      else
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (ctx, i) {
              final s = _results[i];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Color(0xFF4080FF)),
                title: Text(s['title'] ?? '', style: const TextStyle(color: Color(0xFFE8EEFF))),
                subtitle: Text('${s['artist'] ?? ''} · ${s['album'] ?? ''}', style: const TextStyle(color: Color(0xFF7799CC))),
              );
            },
          ),
        ),
    ]);
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }
}
