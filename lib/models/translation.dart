class Translation {
  final String id;
  final String original;
  final String translated;
  final String direction;
  final DateTime timestamp;
  final bool isFavorite;

  Translation({
    required this.id,
    required this.original,
    required this.translated,
    required this.direction,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original': original,
      'translated': translated,
      'direction': direction,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      id: map['id'],
      original: map['original'],
      translated: map['translated'],
      direction: map['direction'],
      timestamp: DateTime.parse(map['timestamp']),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Translation copyWith({
    String? id,
    String? original,
    String? translated,
    String? direction,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return Translation(
      id: id ?? this.id,
      original: original ?? this.original,
      translated: translated ?? this.translated,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}