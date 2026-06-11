class MusicSource {
  final String name;
  final String description;
  final String url;
  bool enabled;

  MusicSource({
    required this.name,
    required this.description,
    required this.url,
    this.enabled = true,
  });
}
