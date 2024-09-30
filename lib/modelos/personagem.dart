class Character {
  final int id;
  final String name;
  final String description;
  final String thumbnailUrl;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? 'Sem descrição',
      thumbnailUrl:
          '${json['thumbnail']['path']}.${json['thumbnail']['extension']}',
    );
  }
}
