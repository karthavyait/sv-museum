class Exhibit {
  Exhibit({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.audioPath,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final String? imagePath;
  final String? audioPath;
  final String createdAt;

  Exhibit copyWith({
    int? id,
    String? title,
    String? description,
    String? imagePath,
    String? audioPath,
    String? createdAt,
  }) {
    return Exhibit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'createdAt': createdAt,
    };
  }

  static Exhibit fromMap(Map<String, Object?> map) {
    return Exhibit(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      audioPath: map['audioPath'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}
