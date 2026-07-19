class CheckIn {
  final String id;
  final String note;
  final String photoPath;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.note,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      note: json['note'] as String,
      photoPath: json['photoPath'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
