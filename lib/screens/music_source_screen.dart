import 'package:flutter/material.dart';

class MusicSourceScreen extends StatefulWidget {
  const MusicSourceScreen({super.key});
  @override
  State<MusicSourceScreen> createState() => _MusicSourceScreenState();
}

class _MusicSourceScreenState extends State<MusicSourceScreen> {
  List<Map<String, dynamic>> _sources = [];

  @override
  void initState() {
    super.initState();
    _sources = [
      {'name': 'YueC Default', 'url': 'builtin', 'enabled': true, 'builtin': true},
    ];
  }

  void _addSource() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F4E),
          title: const Text('Add Music Source', style: TextStyle(color: Color(0xFFE8EEFF))),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Color(0xFFE8EEFF)),
            decoration: const InputDecoration(
              hintText: 'Source URL or name',
              hintStyle: TextStyle(color: Color(0xFF7799CC)),
              filled: true, fillColor: Color(0xFF0F1535),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF7799CC)))),
            TextButton(onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _sources.add({'name': controller.text.trim(), 'url': controller.text.trim(), 'enabled': true, 'builtin': false});
                });
              }
              Navigator.pop(ctx);
            }, child: const Text('Add', style: TextStyle(color: Color(0xFF4080FF)))),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.source, color: Color(0xFF4080FF)),
            const SizedBox(width: 8),
            const Text('Music Sources', style: TextStyle(color: Color(0xFFE8EEFF), fontSize: 18)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF4080FF)),
              onPressed: _addSource,
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _sources.length,
          itemBuilder: (ctx, i) {
            final s = _sources[i];
            return ListTile(
              leading: Icon(
                s['builtin'] == true ? Icons.star : Icons.link,
                color: s['enabled'] ? const Color(0xFF4080FF) : const Color(0xFF5566AA),
              ),
              title: Text(s['name'] ?? '', style: TextStyle(color: s['enabled'] ? const Color(0xFFE8EEFF) : const Color(0xFF5566AA))),
              subtitle: Text(s['url'] ?? '', style: const TextStyle(color: Color(0xFF7799CC), fontSize: 12)),
              trailing: Switch(
                value: s['enabled'],
                activeColor: const Color(0xFF4080FF),
                onChanged: (v) {
                  setState(() { s['enabled'] = v; });
                },
              ),
            );
          },
        ),
      ),
    ]);
  }
}
